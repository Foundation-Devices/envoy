import UIKit
import Flutter

import UniformTypeIdentifiers
import Foundation
import AccessorySetupKit
import CoreBluetooth

private let methodChannel = "envoy"
private let sdCardEventChannel = "sd_card_events"
private var eventSink: FlutterEventSink? = nil

private let localSecretCloudStorageKey = "localSecret"
private let localSecretFileName = "local.secret"

private let primeSecretCloudStorageKey = "prime"
private let primeSecretsFileName = "prime.secrets"

private var folderAccessResult: FlutterResult? = nil

func getSdCardBookmark() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].appendingPathComponent("sd_card")
}

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate, FlutterStreamHandler {
    
    // tiny hidden textfield used to prevent screenshots (original idea kept)
    let secureTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    
    // Bluetooth management
    

    
    // MARK: - Application lifecycle
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        FlutterEventChannel(name: sdCardEventChannel, binaryMessenger: controller.binaryMessenger)
            .setStreamHandler(self)
        
        let envoyMethodChannel = FlutterMethodChannel(name: methodChannel,
                                                     binaryMessenger: controller.binaryMessenger)
        
        setUpSecureScreen(window: window)
        
        let bluetoothChannel = BluetoothChannel(flutterController: controller)


        
        envoyMethodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else {
                result(FlutterError(code: "internal", message: "self deallocated", details: nil))
                return
            }
            
            switch call.method {
            case "make_screen_secure":
                if let args = call.arguments as? [String: Any],
                   let secure = args["secure"] as? Bool,
                   let w = self.window {
                    self.makeSecure(window: w, secure: secure)
                    result(nil)
                } else {
                    result(FlutterError(code: "param", message: "data or format error", details: nil))
                }
            case "prompt_folder_access":
                folderAccessResult = result
                self.promptUserForFolderAccess()
                return
            case "get_time_zone":
                let id = TimeZone.current.identifier
                result(id)
                return
                
            case "access_folder":
                do {
                    let sdCardBookMarkUrl = getSdCardBookmark()
                    let bookmarkData = try Data(contentsOf: sdCardBookMarkUrl)
                    var isStale = false
                    let bookmarkUrl = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                    
                    guard !isStale else {
                        // TODO: handle stale bookmark (ask user to pick again)
                        result(false)
                        return
                    }
                    
                    let started = bookmarkUrl.startAccessingSecurityScopedResource()
                    result(started)
                } catch {
                    result(false)
                }
                
            case "data_changed":
                do {
                    let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                    let localSecretURL = paths[0].appendingPathComponent(localSecretFileName)
                    let localSecret = try String(contentsOf: localSecretURL)
                    
                    let primeSecretsURL = paths[0].appendingPathComponent(primeSecretsFileName)
                    let primeSecret = try String(contentsOf: primeSecretsURL)
                    
                    NSUbiquitousKeyValueStore.default.set(primeSecret, forKey: primeSecretCloudStorageKey)
                    NSUbiquitousKeyValueStore.default.set(localSecret, forKey: localSecretCloudStorageKey)
                    
                    NSUbiquitousKeyValueStore.default.synchronize()
                    
                    result(true)
                } catch {
                    result(false)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        
        if NSUbiquitousKeyValueStore.default.synchronize() == false {
            fatalError("This app was not built with the proper entitlement requests.")
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        // Bluetooth channel is already initialized in the property declaration
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Deep links
    override func application(_ application: UIApplication,
                              open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        let sendingAppID = options[.sourceApplication] ?? "Unknown"
        print("Source application: \(sendingAppID)")
        
        if let controller = window?.rootViewController as? FlutterViewController {
            controller.engine.navigationChannel.invokeMethod("pushRoute", arguments: url.absoluteString)
        }
        
        return true
    }
    
    @objc
    func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else { return }
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        guard keys.contains(localSecretCloudStorageKey) else { return }
        
        // Save the timestamp
        let path: URL
        do {
            path = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let localSecretTimestampURL = path.appendingPathComponent(localSecretFileName + ".backup_timestamp")
            try NSDate().timeIntervalSince1970.description.write(to: localSecretTimestampURL, atomically: true, encoding: .ascii)
        } catch {
            print(error)
            return
        }
        
        switch reasonForChange {
        case NSUbiquitousKeyValueStoreAccountChange, NSUbiquitousKeyValueStoreServerChange, NSUbiquitousKeyValueStoreInitialSyncChange:
            let localSecret = NSUbiquitousKeyValueStore.default.string(forKey: localSecretCloudStorageKey)
            let primeSecret = NSUbiquitousKeyValueStore.default.string(forKey: primeSecretCloudStorageKey)
            
            do {
                let localSecretURL = path.appendingPathComponent(localSecretFileName)
                let localPrimeSecretURL = path.appendingPathComponent(primeSecretsFileName)
                if let primeSecret = primeSecret {
                    try primeSecret.write(to: localPrimeSecretURL, atomically: true, encoding: .ascii)
                }
                if let localSecret = localSecret {
                    try localSecret.write(to: localSecretURL, atomically: true, encoding: .ascii)
                }
            } catch {
                print(error)
            }
        default:
            break
        }
    }
    
    // MARK: - Folder access
    
    private func promptUserForFolderAccess() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self

        // Always start from the top level (where SD card would be)
        let topLevelURL = URL.init(string: "file:///private/var/mobile/Library/LiveFiles/com.apple.filesystems.userfsd/");
        documentPicker.directoryURL = topLevelURL;
        
        // Present the picker
        controller.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            folderAccessResult?(nil)
            return
        }
        
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            try bookmarkData.write(to: getSdCardBookmark())
        } catch {
            print(error)
        }
        
        folderAccessResult?(url.absoluteString)
    }
    
    // MARK: - Secure screen
    
    func makeSecure(window: UIWindow, secure: Bool) {
        secureTextField.isSecureTextEntry = secure
    }
    
    func setUpSecureScreen(window: UIWindow?) {
        guard let _window = window else { return }
        secureTextField.isSecureTextEntry = false
        secureTextField.isHidden = true
        _window.addSubview(secureTextField)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    // keep your bundling stub (no changes)
    public func dummyMethodToEnforceBundling() {
        // This will never be called
        ur_decoder()
        tor_hello()
    }
}
