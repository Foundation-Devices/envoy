import UIKit
import Flutter

import UniformTypeIdentifiers
import Foundation
import AccessorySetupKit
import CoreBluetooth
import Security

private let methodChannel = "envoy"
private let sdCardEventChannel = "sd_card_events"
private var eventSink: FlutterEventSink? = nil

private let localSecretCloudStorageKey = "localSecret"
private let localSecretFileName = "local.secret"

private let primeSecretCloudStorageKey = "prime"
private let primeSecretsFileName = "prime.secrets"

private var folderAccessResult: FlutterResult? = nil

private let appGroupID = "group.com.foundationdevices.envoy"

func getSdCardBookmark() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].appendingPathComponent("sd_card")
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, UIDocumentPickerDelegate, FlutterStreamHandler {

    // tiny hidden textfield used to prevent screenshots (original idea kept)
    let secureTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

    // Retain BluetoothChannel to prevent deallocation during app lifecycle
    private var bluetoothChannel: BluetoothChannel?
    private var envoyMethodChannel: FlutterMethodChannel?
    private var sdCardFlutterEventChannel: FlutterEventChannel?
    private weak var activeWindow: UIWindow?
    private weak var flutterViewController: FlutterViewController?
    private var pendingAppClipHandoffURL: URL?

    // MARK: - Application lifecycle

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)

        if NSUbiquitousKeyValueStore.default.synchronize() == false {
            fatalError("This app was not built with the proper entitlement requests.")
        }

        pendingAppClipHandoffURL = checkAppClipHandoff()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        configureFlutterChannels(binaryMessenger: engineBridge.applicationRegistrar.messenger())
    }

    private func configureFlutterChannels(binaryMessenger: FlutterBinaryMessenger) {
        sdCardFlutterEventChannel = FlutterEventChannel(
            name: sdCardEventChannel,
            binaryMessenger: binaryMessenger
        )
        sdCardFlutterEventChannel?.setStreamHandler(self)

        envoyMethodChannel = FlutterMethodChannel(
            name: methodChannel,
            binaryMessenger: binaryMessenger
        )
        envoyMethodChannel?.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self else {
                result(FlutterError(code: "internal", message: "self deallocated", details: nil))
                return
            }

            switch call.method {
            case "make_screen_secure":
                if let args = call.arguments as? [String: Any],
                   let secure = args["secure"] as? Bool,
                   let window = self.activeWindow {
                    self.makeSecure(window: window, secure: secure)
                    result(nil)
                } else {
                    result(FlutterError(code: "param", message: "data or format error", details: nil))
                }
            case "prompt_folder_access":
                folderAccessResult = result
                self.promptUserForFolderAccess()
            case "get_time_zone":
                result(TimeZone.current.identifier)
            case "access_folder":
                do {
                    let sdCardBookMarkUrl = getSdCardBookmark()
                    let bookmarkData = try Data(contentsOf: sdCardBookMarkUrl)
                    var isStale = false
                    let bookmarkUrl = try URL(
                        resolvingBookmarkData: bookmarkData,
                        bookmarkDataIsStale: &isStale
                    )

                    guard !isStale else {
                        // TODO: handle stale bookmark (ask user to pick again)
                        result(false)
                        return
                    }

                    result(bookmarkUrl.startAccessingSecurityScopedResource())
                } catch {
                    result(false)
                }
            case "data_changed":
                do {
                    let paths = FileManager.default.urls(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask
                    )
                    let localSecretURL = paths[0].appendingPathComponent(localSecretFileName)
                    let localSecret = try String(contentsOf: localSecretURL)

                    let primeSecretsURL = paths[0].appendingPathComponent(primeSecretsFileName)
                    let primeSecrets = try String(contentsOf: primeSecretsURL)

                    NSUbiquitousKeyValueStore.default.set(
                        primeSecrets,
                        forKey: primeSecretCloudStorageKey
                    )
                    NSUbiquitousKeyValueStore.default.set(
                        localSecret,
                        forKey: localSecretCloudStorageKey
                    )
                    NSUbiquitousKeyValueStore.default.synchronize()
                    result(true)
                } catch {
                    result(false)
                }
            case "get_shard_path_icloud":
                // url(forUbiquityContainerIdentifier:) blocks until iCloud is ready — must run off main thread.
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let ubiquityURL = FileManager.default.url(
                        forUbiquityContainerIdentifier: "iCloud.com.foundationdevices.envoy"
                    ) else {
                        result(nil)
                        return
                    }
                    let docsURL = ubiquityURL.appendingPathComponent("Documents")
                    try? FileManager.default.createDirectory(
                        at: docsURL,
                        withIntermediateDirectories: true
                    )
                    let dst = docsURL.appendingPathComponent("prime.secret")

                    // Migrate from App Group container (previous approach)
                    if let container = FileManager.default.containerURL(
                        forSecurityApplicationGroupIdentifier: appGroupID
                    ) {
                        let src = container.appendingPathComponent("prime.secret")
                        if FileManager.default.fileExists(atPath: src.path),
                           !FileManager.default.fileExists(atPath: dst.path) {
                            try? FileManager.default.copyItem(at: src, to: dst)
                        }
                    }

                    // Migrate from applicationSupportDirectory (original location)
                    let appSupport = FileManager.default.urls(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask
                    )[0]
                    let legacySrc = appSupport.appendingPathComponent("prime.secret")
                    if FileManager.default.fileExists(atPath: legacySrc.path),
                       !FileManager.default.fileExists(atPath: dst.path) {
                        try? FileManager.default.copyItem(at: legacySrc, to: dst)
                    }

                    result(dst.path)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        bluetoothChannel?.cleanup()
        bluetoothChannel = BluetoothChannel(binaryMessenger: binaryMessenger)
        if let flutterViewController {
            bluetoothChannel?.attachFlutterController(flutterViewController)
        }
    }

    func sceneDidConnect(window: UIWindow) {
        activeWindow = window
        setUpSecureScreen(window: window)

        guard let controller = window.rootViewController as? FlutterViewController else {
            print("Unable to find FlutterViewController for connected scene")
            return
        }

        flutterViewController = controller
        bluetoothChannel?.attachFlutterController(controller)

        guard let handoffURL = pendingAppClipHandoffURL else {
            return
        }
        pendingAppClipHandoffURL = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak controller] in
            controller?.pushRoute(handoffURL.absoluteString)
        }
    }

    func sceneDidDisconnect(window: UIWindow?) {
        guard let window, activeWindow === window else {
            return
        }
        activeWindow = nil
        flutterViewController = nil
        bluetoothChannel?.attachFlutterController(nil)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Clean up Bluetooth resources before app termination to prevent
        // CoreBluetooth callbacks from firing after Flutter engine is destroyed
        bluetoothChannel?.cleanup()
        bluetoothChannel = nil
        super.applicationWillTerminate(application)
    }


    // Helper function to print Keychain attributes
    func auditKeychainItems() {
          print("\n--- STARTING KEYCHAIN AUDIT ---")

          // helper to run a query
          func runQuery(sync: Bool) {
              let typeLabel = sync ? "☁️ iCLOUD (Synchronizable)" : "🏠 LOCAL (Not-Synchronizable)"

              let query: [String: Any] = [
                  kSecClass as String: kSecClassGenericPassword,
                  kSecReturnAttributes as String: true,
                  kSecMatchLimit as String: kSecMatchLimitAll,
                  kSecAttrSynchronizable as String: sync // Explicitly targeting one partition
              ]

              var result: AnyObject?
              let status = SecItemCopyMatching(query as CFDictionary, &result)

              if status == errSecSuccess {
                  if let items = result as? [[String: Any]] {
                      print("\nChecking \(typeLabel): FOUND \(items.count) ITEMS")
                      for item in items {
                          let key = item[kSecAttrAccount as String] as? String ?? "Unknown"
                          let access = item[kSecAttrAccessible as String] as? String ?? "Unknown"
                          print("   • Key: '\(key)' | Access: \(access) ")
                      }
                  }
              } else if status == errSecItemNotFound {
                  print("\nChecking \(typeLabel): EMPTY (No items found)")
              } else {
                  print("\nChecking \(typeLabel): ERROR \(status)")
              }
          }

          // 1. Check Local
          runQuery(sync: false)

          // 2. Check iCloud
          runQuery(sync: true)

          print("\n--- AUDIT COMPLETE ---\n")
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
            let primeSecrets = NSUbiquitousKeyValueStore.default.string(forKey: primeSecretCloudStorageKey)

            do {
                let localSecretURL = path.appendingPathComponent(localSecretFileName)
                let localPrimeSecretURL = path.appendingPathComponent(primeSecretsFileName)
                if let primeSecrets = primeSecrets {
                    try primeSecrets.write(to: localPrimeSecretURL, atomically: true, encoding: .ascii)
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
        guard let controller = flutterViewController else {
            folderAccessResult?(
                FlutterError(
                    code: "SCENE_UNAVAILABLE",
                    message: "The Envoy window is not available.",
                    details: nil
                )
            )
            folderAccessResult = nil
            return
        }
        
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
        guard let _window = window, secureTextField.superview !== _window else { return }
        let secureTextFieldView = UIView(frame: CGRect(x: 0, y: 0, width: secureTextField.frame.self.width, height: secureTextField.frame.self.height))
        secureTextField.isSecureTextEntry = false
        _window.addSubview(secureTextField)
        _window.layer.superlayer?.addSublayer(secureTextField.layer)
        secureTextField.layer.sublayers?.last!.addSublayer(_window.layer)
        secureTextField.leftView = secureTextFieldView
        secureTextField.leftViewMode = .always
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
    

    /// Check for data passed from App Clip via shared App Groups UserDefaults
    /// Returns the deep link URL if handoff data exists, nil otherwise
    private func checkAppClipHandoff() -> URL? {
        
        /// Clear App Clip handoff data from shared UserDefaults
         func clearAppClipHandoffData() {
            guard let defaults = UserDefaults(suiteName: appGroupID) else { return }

            defaults.removeObject(forKey: "appClip_deepLinkURL")
            defaults.removeObject(forKey: "appClip_timestamp")

            defaults.synchronize()
        }
        
        
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            return nil
        }

        // Check if there's handoff data from App Clip
        guard let deepLinkString = defaults.string(forKey: "appClip_deepLinkURL"),
              let timestamp = defaults.object(forKey: "appClip_timestamp") as? Date else {
            return nil
        }

        // Only accept handoff data that's less than 6 hours old
        let maxAge: TimeInterval = 6 * 60 * 60 // 6 hours
        guard Date().timeIntervalSince(timestamp) < maxAge else {
            // Clear stale handoff data
            clearAppClipHandoffData()
            return nil
        }

        // Clear handoff data after reading
        clearAppClipHandoffData()

        return URL(string: deepLinkString)
    }

}
