use flutter_rust_bridge::frb;
use jni::objects::GlobalRef;
use jni::{AttachGuard, JNIEnv, JavaVM};
use std::cell::RefCell;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::OnceLock;

// use crate::api::ble::Error;

use super::RUNTIME;

static CLASS_LOADER: OnceLock<GlobalRef> = OnceLock::new();
pub static JAVAVM: OnceLock<JavaVM> = OnceLock::new();

std::thread_local! {
    static JNI_ENV: RefCell<Option<AttachGuard<'static>>> = RefCell::new(None);
}

#[frb(ignore)]
pub fn create_runtime() -> anyhow::Result<()> {
    tracing::info!("Create runtime");
    let vm = JAVAVM.get().ok_or(anyhow::anyhow!("Cannot get JavaVM"))?;
    let env = vm.attach_current_thread().unwrap();

    setup_class_loader(&env)?;
    let runtime = tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .thread_name_fn(|| {
            static ATOMIC_ID: AtomicUsize = AtomicUsize::new(0);
            let id = ATOMIC_ID.fetch_add(1, Ordering::SeqCst);
            format!("bluart-thread-{}", id)
        })
        .on_thread_stop(move || {
            tracing::debug!("Stopping runtime thread");
            JNI_ENV.with(|f| *f.borrow_mut() = None);
        })
        .on_thread_start(move || {
            tracing::debug!("Wrapping new thread in vm");

            // We now need to call the following code block via JNI calls. God help us.
            //
            //  java.lang.Thread.currentThread().setContextClassLoader(
            //    java.lang.ClassLoader.getSystemClassLoader()
            //  );
            tracing::debug!("Adding classloader to thread");

            let vm = JAVAVM.get().unwrap();
            let env = vm.attach_current_thread().unwrap();

            let thread = env
                .call_static_method(
                    "java/lang/Thread",
                    "currentThread",
                    "()Ljava/lang/Thread;",
                    &[],
                )
                .unwrap()
                .l()
                .unwrap();
            env.call_method(
                thread,
                "setContextClassLoader",
                "(Ljava/lang/ClassLoader;)V",
                &[CLASS_LOADER.get().unwrap().as_obj().into()],
            )
            .unwrap();
            tracing::debug!("Classloader added to thread");
            JNI_ENV.with(|f| *f.borrow_mut() = Some(env));
        })
        .build()
        .unwrap();
    RUNTIME
        .set(runtime)
        .map_err(|_| anyhow::anyhow!("Runtime is already set"))?;
    Ok(())
}

fn setup_class_loader(env: &JNIEnv) -> anyhow::Result<()> {
    let thread = env
        .call_static_method(
            "java/lang/Thread",
            "currentThread",
            "()Ljava/lang/Thread;",
            &[],
        )?
        .l()?;
    let class_loader = env
        .call_method(
            thread,
            "getContextClassLoader",
            "()Ljava/lang/ClassLoader;",
            &[],
        )?
        .l()?;

    CLASS_LOADER
        .set(env.new_global_ref(class_loader)?)
        .map_err(|_| anyhow::anyhow!("Cannot set class loader"))
}
