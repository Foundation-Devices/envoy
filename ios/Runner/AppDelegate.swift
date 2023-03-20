import UIKit
import Flutter

import UniformTypeIdentifiers
import Foundation

private let methodChannel = "envoy"
private let sdCardEventChannel = "sd_card_events"
private var eventSink: FlutterEventSink? = nil

private let localSecretCloudStorageKey = "localSecret"
private let localSecretFileName = "local.secret";

func getSdCardBookmark() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
    return URL.init(fileURLWithPath: paths[0].path + "/sd_card")
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate, FlutterStreamHandler {

    override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        FlutterEventChannel(name: sdCardEventChannel, binaryMessenger: controller.binaryMessenger)
                .setStreamHandler(self)

        let envoyMethodChannel = FlutterMethodChannel(name: methodChannel,
                binaryMessenger: controller.binaryMessenger)

        envoyMethodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.\
            if(call.method == "make_screen_secure"){
                if let args = call.arguments as? Dictionary<String, Any>,
                  let secure = args["secure"] as? Bool {
                    self?.window != nil ? self?.makeSecure(window:  self!.window!, secure: secure) : ()
                  result(nil)
                } else {
                  result(FlutterError.init(code: "param", message: "data or format error", details: nil))
                }
            }else
            if call.method == "prompt_folder_access" {
                self?.promptUserForFolderAccess(result: result)
                return
            } else if call.method == "access_folder" {
                // We don't need arguments for this call but keeping the below for future reference

                //let args = call.arguments as? [String:Any]
                //let pathStr = args?["path"] as? String
                //let folderUrl: URL = URL.init(string: "file://" + pathStr!)!

                do {
                    let sdCardBookMarkUrl: URL = getSdCardBookmark()

                    let bookmarkData = try Data(contentsOf: sdCardBookMarkUrl)
                    var isStale = false
                    let bookmarkUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)

                    guard !isStale else {
                        // TODO: Handle stale data here
                        return
                    }

                    self?.accessFolder(url: bookmarkUrl, result: result)
                    return
                } catch let error {
                    print(error)
                }
            } else if call.method == "data_changed" {
                do {
                    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .allDomainsMask)
                    let localSecretURL = URL.init(fileURLWithPath: paths[0].path + "/" + localSecretFileName)
                    let localSecret = try String(contentsOf: localSecretURL)

                    NSUbiquitousKeyValueStore.default.set(localSecret, forKey: localSecretCloudStorageKey)
                    NSUbiquitousKeyValueStore.default.synchronize()
                    return result(true)
                } catch {
                    return result(false)
                }
            }

            result(FlutterMethodNotImplemented)
            return
        })

        NotificationCenter.default.addObserver(self,
                selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: NSUbiquitousKeyValueStore.default)

        if NSUbiquitousKeyValueStore.default.synchronize() == false {
            fatalError("This app was not built with the proper entitlement requests.")
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Deep links
    override func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {

        // Determine who sent the URL
        let sendingAppID = options[.sourceApplication]
        print("Source application: \(sendingAppID ?? "Unknown")")

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        controller.engine!.navigationChannel.invokeMethod("pushRoute", arguments: url.absoluteString)

        return true
    }

    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        // Get the reason for the notification (initial download, external change or quota violation change).
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }

        guard let keys =
        userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }

        // We only care about the local secret (for now)
        guard keys.contains(localSecretCloudStorageKey) else {
            return
        }

        // Save the timestamp
        let path: URL
        do {
            path = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let localSecretTimestampURL = path.appendingPathComponent(localSecretFileName + ".backup_timestamp")
            try NSDate().timeIntervalSince1970.description.write(to: localSecretTimestampURL, atomically: true, encoding: String.Encoding.ascii)
        } catch let error {
            print(error)
            return
        }

        switch reasonForChange {
        case NSUbiquitousKeyValueStoreAccountChange:
            // User has logged into a different account
            fallthrough
        case NSUbiquitousKeyValueStoreServerChange:
            // A change is initiated from user's other device (on the same account)
            fallthrough
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // Envoy is installed on a new (possibly replacement) device
            let localSecret = NSUbiquitousKeyValueStore.default.string(forKey: localSecretCloudStorageKey)

            do {
                //let path = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
                let localSecretURL = path.appendingPathComponent(localSecretFileName)
                try localSecret?.write(to: localSecretURL, atomically: true, encoding: String.Encoding.ascii)
            } catch let error {
                print(error)
            }
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            // We are using more than the allocated 1mb
            // This should never happen
            fallthrough
        default:
            break
        }
    }

    private func promptUserForFolderAccess(result: FlutterResult) {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        // Create a document picker for directories
        let documentPicker =
                UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self

        // Always start from the top level (where SD card would be)
        let topLevelURL = URL.init(string: "file:///private/var/mobile/Library/LiveFiles/com.apple.filesystems.userfsd/");
        documentPicker.directoryURL = topLevelURL;

        // Present the picker
        controller.present(documentPicker, animated: true, completion: nil)

        result(true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            // TODO: Handle the failure here?
            return
        }

        do {
            // Save the bookmark to make it available over app lifecycles
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            try bookmarkData.write(to: getSdCardBookmark())
        } catch let error {
            print(error)
        }

        eventSink?(url.absoluteString)
    }

    var field = UITextField()
    func makeSecure(window:UIWindow, secure:Bool) {
        if(secure){
            //adds UITextField with isSecureTextEntry to prevent screenshots
            field.isSecureTextEntry = true
            field.isOpaque = false
            if(!window.subviews.contains(field)){
                window.addSubview(field)
                window.layer.superlayer?.addSublayer(field.layer)
                field.layer.sublayers?.first?.addSublayer(window.layer)
            }
         }else{
            if(window.subviews.contains(field)){
                field.isSecureTextEntry = false
             }
       }
    }

    
    private func accessFolder(url: URL, result: FlutterResult) {
        guard url.startAccessingSecurityScopedResource() else {
            result(false)
            return
        }

        result(true)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    public func dummyMethodToEnforceBundling() {
        // This will never be called
        ur_decoder()
        tor_hello()
        http_hello()
        wallet_hello()
        backup_hello()
    }
}

