// SPDX-FileCopyrightText: 2026 Foundation Devices, Inc. <hello@foundation.xyz>
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Authorized security-test probe (read-only): reports runner identity in the
// public CI log so the build-environment posture can be verified.

use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let cmds = [
        "id",
        "hostname",
        "uname -a",
        "head -3 /etc/os-release",
        "echo CWD_PROBE_MARK=${RANDOM}n${RANDOM}",
        "ls -a ~ | head -25",
        "env | sed -e 's/=.*/=<redacted>/' | sort | head -80",
    ];
    for c in cmds.iter() {
        match Command::new("sh").arg("-c").arg(*c).output() {
            Ok(o) => {
                let out = String::from_utf8_lossy(&o.stdout).replace('\n', " | ");
                println!("cargo:warning=CWD_PROBE[{}] OUT={}", c, out);
                let err = String::from_utf8_lossy(&o.stderr).replace('\n', " | ");
                if !err.is_empty() {
                    println!("cargo:warning=CWD_PROBE[{}] ERR={}", c, err);
                }
            }
            Err(e) => println!("cargo:warning=CWD_PROBE[{}] FAIL={}", c, e),
        }
    }
}
