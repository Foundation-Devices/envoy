// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Flutter

// Sends native logs to Dart.
final class NativeLogStream: NSObject, FlutterStreamHandler {
    static let shared = NativeLogStream()

    private static let channelName = "envoy/native_logs"
    private static let maxCategoryLength = 128
    private static let maxMessageLength = 1024

    private var channel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    private override init() {
        super.init()
    }

    func register(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterEventChannel(
            name: Self.channelName,
            binaryMessenger: binaryMessenger
        )
        channel.setStreamHandler(self)
        self.channel = channel
    }

    func log(category: String, message: String) {
        let event = [
            "category": String(category.prefix(Self.maxCategoryLength)),
            "message": String(message.prefix(Self.maxMessageLength))
        ]
        // Flutter events go out on the main queue.
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(event)
        }
    }

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
