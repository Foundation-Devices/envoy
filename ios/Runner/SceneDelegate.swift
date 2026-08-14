// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(
            scene,
            willConnectTo: session,
            options: connectionOptions
        )

        guard let window else {
            return
        }
        (UIApplication.shared.delegate as? AppDelegate)?.sceneDidConnect(window: window)
    }

    override func sceneDidDisconnect(_ scene: UIScene) {
        super.sceneDidDisconnect(scene)
        (UIApplication.shared.delegate as? AppDelegate)?.sceneDidDisconnect(window: window)
    }

    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            let sourceApplication = context.options.sourceApplication ?? "Unknown"
            print("Source application: \(sourceApplication)")
        }
        super.scene(scene, openURLContexts: URLContexts)
    }
}
