// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Flutter
import Security

/// Owns iOS-native Magic Backup behavior, including channel calls, v2
/// Keychain seed storage, v1 compatibility, and Prime backup paths.
/// Shared access group container will be used for magic seed and prime secrets
final class MagicBackup: NSObject {
    static let shared = MagicBackup()

    private static let channelName = "envoy/magic_backup"
    private static let seedAccount = "seed"
    private static let obsoleteSeedClearedAccount = "seed_cleared"
    private static let legacyBackupEnabledAccount = "backup_enabled"
    private static let keychainService = "flutter_secure_storage_service"
    private static let localKeychainService = "com.foundationdevices.magic-backup.v2.local"
    private static let previousLocalV2FileName = "magic_backup.v2.local"
    private static let v1KVSKey = "localSecret"
    private static let v1FileName = "local.secret"
    private static let v1PrimeKVSKey = "prime"
    private static let v1PrimeFileName = "prime.secrets"
    private static let sharedAccessGroupSuffix = "com.foundationdevices.shared"
    private static let accessGroupProbeService = "com.foundationdevices.envoy.magic-backup-probe"
    private static let appGroupID = "group.com.foundationdevices.envoy"

    private let ubiquitousStore = NSUbiquitousKeyValueStore.default
    private var channel: FlutterMethodChannel?
    private var started = false
    private var loggedLaunchStorageStatus = false
    private var loggedSeedSource = false
    private var resolvedPrivateAccessGroup: String?

    private override init() {
        super.init()
    }

    func start() {
        guard !started else { return }
        started = true

        // This marker is not used anymore.
        if let accessGroup = try? privateAccessGroup {
            try? deleteKeychainValue(
                accessGroup: accessGroup,
                service: Self.localKeychainService,
                synchronizable: false,
                account: Self.obsoleteSeedClearedAccount
            )
            try? deleteKeychainValue(
                accessGroup: accessGroup,
                service: Self.keychainService,
                synchronizable: kSecAttrSynchronizableAny,
                account: Self.obsoleteSeedClearedAccount
            )
        }

        // Keep old Prime KVS restores working.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ubiquitousKeyValueStoreDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousStore
        )

        if !ubiquitousStore.synchronize() {
            log("v1 storage is unavailable")
        }
        restoreV1PrimeDataFromKVS()
    }

    func register(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
        self.channel = channel
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "read_seed":
                let backupEnabled =
                    (call.arguments as? [String: Any])?["backup_enabled"] as? Bool ?? true
                let logLaunchStatus = _isDebugAssertConfiguration()
                    && !loggedLaunchStorageStatus
                if logLaunchStatus {
                    loggedLaunchStorageStatus = true
                    logStorageVersionStatus("before read")
                }
                let seed = try readSeed(
                    logSource: true,
                    backupEnabled: backupEnabled
                )
                if logLaunchStatus {
                    logStorageVersionStatus("after read")
                }
                result(seed)
            case "write_seed":
                guard let arguments = call.arguments as? [String: Any],
                      let seed = arguments["seed"] as? String,
                      !seed.isEmpty else {
                    result(
                        FlutterError(
                            code: "INVALID_SEED",
                            message: "A non-empty seed is required",
                            details: nil
                        )
                    )
                    return
                }
                let backupEnabled = arguments["backup_enabled"] as? Bool ?? true
                try writeV2Seed(seed, backupEnabled: backupEnabled)
                try removeV1SeedData()
                result(true)
            case "remove_v1_data":
                try removeV1SeedData()
                result(true)
            case "delete_seed":
                try deleteSharedV2Seed()
                try deletePrivateV2Data()
                try deletePreviousLocalV2Seed()
                result(true)
            case "get_backup_enabled":
                result(try readPrivateV2Record()?.backupEnabled)
            case "set_backup_enabled":
                guard let arguments = call.arguments as? [String: Any],
                      let enabled = arguments["enabled"] as? Bool else {
                    result(
                        FlutterError(
                            code: "INVALID_BACKUP_SETTING",
                            message: "A backup setting is required",
                            details: nil
                        )
                    )
                    return
                }
                try setBackupEnabled(enabled)
                result(true)
            case "data_changed":
                result(uploadV1PrimeDataToKVS())
            case "get_shard_path_icloud":
                resolvePrimeShardPath(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch {
            result(
                FlutterError(
                    code: "MAGIC_BACKUP_STORAGE_ERROR",
                    message: String(describing: error),
                    details: nil
                )
            )
        }
    }

    private func readSeed(logSource: Bool, backupEnabled: Bool) throws -> String? {
        let v2Seed: String?
        // The private record is the main copy.
        if let privateRecord = try readPrivateV2Record() {
            try reconcileSharedSeed(
                privateRecord.seed,
                backupEnabled: privateRecord.backupEnabled
            )
            try deletePreviousLocalV2Seed()
            v2Seed = privateRecord.seed
        } else if let previousLocalSeed = try readPreviousLocalV2Seed() {
            // Old local v2 copies come back with backup off.
            try writeV2Seed(previousLocalSeed, backupEnabled: false)
            v2Seed = previousLocalSeed
        } else if let sharedSeed = try readSharedV2Seed() {
            // A shared copy means Magic Backup was on.
            try writeV2Seed(sharedSeed, backupEnabled: true)
            v2Seed = sharedSeed
        } else {
            v2Seed = nil
        }

        if let v2Seed {
            if logSource {
                logRecoverySource(.v2)
            }
            do {
                try removeV1SeedData()
            } catch {
                log("v1 cleanup will be retried")
            }
            return v2Seed
        }

        return try readAndUpgradeV1Seed(
            logSource: logSource,
            backupEnabled: backupEnabled
        )
    }

    private func writeV2Seed(_ seed: String, backupEnabled: Bool) throws {
        // Seed and backup setting stay in the same record.
        let record = MagicBackupPrivateSeedRecord(
            seed: seed,
            backupEnabled: backupEnabled
        )
        try writePrivateV2Record(record)
        guard try readStoredPrivateV2Record() == record else {
            throw MagicBackupKeychainError.readbackFailed
        }
        try deleteLegacyPrivateBackupEnabled()
        try reconcileSharedSeed(seed, backupEnabled: backupEnabled)
        try deletePreviousLocalV2Seed()
    }

    private func reconcileSharedSeed(_ seed: String, backupEnabled: Bool) throws {
        // The shared copy exists only while Magic Backup is on.
        if backupEnabled {
            if try readSharedV2Seed() != seed {
                try writeKeychainValue(
                    seed,
                    accessGroup: sharedAccessGroup,
                    service: Self.keychainService,
                    synchronizable: true,
                    accessibility: kSecAttrAccessibleWhenUnlocked
                )
            }
            guard try readSharedV2Seed() == seed else {
                throw MagicBackupKeychainError.readbackFailed
            }
        } else {
            try deleteSharedV2Seed()
        }
    }

    private func readSharedV2Seed() throws -> String? {
        try readKeychainValue(
            accessGroup: sharedAccessGroup,
            service: Self.keychainService,
            synchronizable: true
        )
    }

    private func deleteSharedV2Seed() throws {
        try deleteKeychainValue(
            accessGroup: sharedAccessGroup,
            service: Self.keychainService,
            synchronizable: true
        )
    }

    private func deletePrivateV2Data() throws {
        try deleteLegacyPrivateBackupEnabled()
        try deleteKeychainValue(
            accessGroup: privateAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false
        )
    }

    private func setBackupEnabled(_ enabled: Bool) throws {
        guard let seed = try readPrivateV2Record()?.seed
            ?? readPreviousLocalV2Seed()
            ?? readSharedV2Seed() else {
            return
        }
        try writeV2Seed(seed, backupEnabled: enabled)
    }

    private func logStorageVersionStatus(_ phase: String) {
        do {
            let privateV2Present = try readKeychainValue(
                accessGroup: privateAccessGroup,
                service: Self.localKeychainService,
                synchronizable: false
            ) != nil
            let sharedV2Present = try readSharedV2Seed() != nil
            let previousLocalV2Present = try readPreviousLocalV2Seed() != nil
            let v2Present = privateV2Present
                || sharedV2Present
                || previousLocalV2Present
            let v1Present = try readV1Seed() != nil
            let v1State = v1Present ? "present" : "empty"
            let v2State = v2Present ? "present" : "empty"
            log(
                "storage versions (\(phase)): "
                    + "v1=\(v1State), v2=\(v2State)"
            )
        } catch {
            log("v1/v2 storage status unavailable")
        }
    }

    private func logRecoverySource(_ source: MagicBackupSeedSource) {
        guard !loggedSeedSource else { return }
        loggedSeedSource = true
        let message = "seed recovery source=\(source.rawValue)"
        NativeLogStream.shared.log(category: "Magic Backup", message: "iOS: \(message)")
        if _isDebugAssertConfiguration() {
            print("Magic Backup: \(message)")
        }
    }

    private func log(_ message: String) {
        print("Magic Backup: \(message)")
        NativeLogStream.shared.log(category: "Magic Backup", message: "iOS: \(message)")
    }

    private func readV1Seed() throws -> String? {
        if let privateSeed = try readKeychainValue(
            accessGroup: privateAccessGroup,
            service: Self.keychainService,
            synchronizable: kSecAttrSynchronizableAny
        ) {
            return privateSeed
        }
        if let kvsSeed = ubiquitousStore.string(forKey: Self.v1KVSKey),
           !kvsSeed.isEmpty {
            return kvsSeed
        }
        if let fileSeed = try readV1File() {
            return fileSeed
        }
        return nil
    }

    private func readAndUpgradeV1Seed(
        logSource: Bool,
        backupEnabled: Bool
    ) throws -> String? {
        guard let v1Seed = try readV1Seed() else {
            return nil
        }
        if logSource {
            logRecoverySource(.v1)
        }

        // Store v2 before removing any v1 copies.
        try writeV2Seed(v1Seed, backupEnabled: backupEnabled)
        do {
            try removeV1SeedData()
        } catch {
            log("v1 cleanup will be retried")
        }
        return v1Seed
    }

    private func removeV1SeedData() throws {
        // Try every old slot before returning an error.
        var firstError: Error?
        for operation in [
            {
                try self.deleteKeychainValue(
                    accessGroup: self.privateAccessGroup,
                    service: Self.keychainService,
                    synchronizable: kSecAttrSynchronizableAny
                )
            },
            { try self.deleteV1Files() }
        ] {
            do {
                try operation()
            } catch {
                firstError = firstError ?? error
            }
        }

        ubiquitousStore.removeObject(forKey: Self.v1KVSKey)
        ubiquitousStore.synchronize()

        if let firstError {
            throw firstError
        }
    }

    private func readKeychainValue(
        accessGroup: String,
        service: String,
        synchronizable: Any,
        account: String? = nil
    ) throws -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account ?? Self.seedAccount,
            kSecAttrService: service,
            kSecAttrAccessGroup: accessGroup,
            kSecAttrSynchronizable: synchronizable,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        switch status {
        case errSecSuccess:
            guard let data = item as? Data,
                  let seed = String(data: data, encoding: .utf8) else {
                throw MagicBackupKeychainError.invalidSeedEncoding
            }
            return seed
        case errSecItemNotFound:
            return nil
        default:
            throw MagicBackupKeychainError.keychain(status)
        }
    }

    private func writeKeychainValue(
        _ value: String,
        accessGroup: String,
        service: String,
        synchronizable: Bool,
        accessibility: CFString,
        account: String? = nil
    ) throws {
        guard let data = value.data(using: .utf8) else {
            throw MagicBackupKeychainError.invalidSeedEncoding
        }

        let lookup: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account ?? Self.seedAccount,
            kSecAttrService: service,
            kSecAttrAccessGroup: accessGroup,
            kSecAttrSynchronizable: synchronizable
        ]
        let updateAttributes: [CFString: Any] = [
            kSecValueData: data
        ]

        var status: OSStatus
        if try readKeychainValue(
            accessGroup: accessGroup,
            service: service,
            synchronizable: synchronizable,
            account: account
        ) == nil {
            var item = lookup
            updateAttributes.forEach { item[$0.key] = $0.value }
            item[kSecAttrAccessible] = accessibility
            status = SecItemAdd(item as CFDictionary, nil)
            if status == errSecDuplicateItem {
                status = SecItemUpdate(
                    lookup as CFDictionary,
                    updateAttributes as CFDictionary
                )
            }
        } else {
            status = SecItemUpdate(
                lookup as CFDictionary,
                updateAttributes as CFDictionary
            )
        }

        guard status == errSecSuccess else {
            throw MagicBackupKeychainError.keychain(status)
        }
    }

    private func deleteKeychainValue(
        accessGroup: String,
        service: String,
        synchronizable: Any,
        account: String? = nil
    ) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account ?? Self.seedAccount,
            kSecAttrService: service,
            kSecAttrAccessGroup: accessGroup,
            kSecAttrSynchronizable: synchronizable
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw MagicBackupKeychainError.keychain(status)
        }
    }

    private func readPrivateV2Record() throws -> MagicBackupPrivateSeedRecord? {
        guard let value = try readKeychainValue(
            accessGroup: privateAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false
        ) else {
            return nil
        }
        if let record = try decodePrivateV2Record(value) {
            return record
        }

        // Old split records migrate with backup off.
        let record = MagicBackupPrivateSeedRecord(
            seed: value,
            backupEnabled: false
        )
        try writePrivateV2Record(record)
        guard try readStoredPrivateV2Record() == record else {
            throw MagicBackupKeychainError.readbackFailed
        }
        try deleteLegacyPrivateBackupEnabled()
        return record
    }

    private func readStoredPrivateV2Record() throws -> MagicBackupPrivateSeedRecord? {
        guard let value = try readKeychainValue(
            accessGroup: privateAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false
        ) else {
            return nil
        }
        return try decodePrivateV2Record(value)
    }

    private func decodePrivateV2Record(
        _ value: String
    ) throws -> MagicBackupPrivateSeedRecord? {
        guard value.first == "{" else {
            return nil
        }
        guard let data = value.data(using: .utf8) else {
            throw MagicBackupKeychainError.invalidSeedEncoding
        }
        do {
            let record = try JSONDecoder().decode(
                MagicBackupPrivateSeedRecord.self,
                from: data
            )
            guard !record.seed.isEmpty else {
                throw MagicBackupKeychainError.invalidPrivateRecord
            }
            return record
        } catch let error as MagicBackupKeychainError {
            throw error
        } catch {
            throw MagicBackupKeychainError.invalidPrivateRecord
        }
    }

    private func writePrivateV2Record(
        _ record: MagicBackupPrivateSeedRecord
    ) throws {
        guard !record.seed.isEmpty else {
            throw MagicBackupKeychainError.invalidPrivateRecord
        }
        let data = try JSONEncoder().encode(record)
        guard let value = String(data: data, encoding: .utf8) else {
            throw MagicBackupKeychainError.invalidSeedEncoding
        }
        // ThisDeviceOnly keeps the main copy off iCloud.
        try writeKeychainValue(
            value,
            accessGroup: privateAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false,
            accessibility: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        )
    }

    private func deleteLegacyPrivateBackupEnabled() throws {
        try deleteKeychainValue(
            accessGroup: privateAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false,
            account: Self.legacyBackupEnabledAccount
        )
    }

    private func readPreviousLocalV2Seed() throws -> String? {
        if let fileSeed = try readPreviousLocalV2File() {
            return fileSeed
        }
        return try readKeychainValue(
            accessGroup: sharedAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false
        )
    }

    private func deletePreviousLocalV2Seed() throws {
        try deletePreviousLocalV2File()
        try deleteKeychainValue(
            accessGroup: sharedAccessGroup,
            service: Self.localKeychainService,
            synchronizable: false
        )
    }

    private func readPreviousLocalV2File() throws -> String? {
        let url = try previousLocalV2FileURL()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        guard let seed = String(data: data, encoding: .utf8) else {
            throw MagicBackupKeychainError.invalidSeedEncoding
        }
        return seed
    }

    private func deletePreviousLocalV2File() throws {
        let url = try previousLocalV2FileURL()
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func previousLocalV2FileURL() throws -> URL {
        try applicationSupportURL().appendingPathComponent(Self.previousLocalV2FileName)
    }

    private func readV1File() throws -> String? {
        let url = try applicationSupportURL().appendingPathComponent(Self.v1FileName)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func deleteV1Files() throws {
        let directory = try applicationSupportURL()
        for fileName in [
            Self.v1FileName,
            Self.v1FileName + ".backup_timestamp"
        ] {
            let url = directory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        }
    }

    private func applicationSupportURL() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    private func uploadV1PrimeDataToKVS() -> Bool {
        do {
            let url = try applicationSupportURL().appendingPathComponent(
                Self.v1PrimeFileName
            )
            let primeData = try String(contentsOf: url, encoding: .utf8)
            ubiquitousStore.set(primeData, forKey: Self.v1PrimeKVSKey)
            ubiquitousStore.synchronize()
            return true
        } catch {
            return false
        }
    }

    private func restoreV1PrimeDataFromKVS() {
        guard let primeData = ubiquitousStore.string(forKey: Self.v1PrimeKVSKey) else {
            return
        }
        do {
            let url = try applicationSupportURL().appendingPathComponent(
                Self.v1PrimeFileName
            )
            try primeData.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            log("v1 Prime data restore failed")
        }
    }

    private func resolvePrimeShardPath(result: @escaping FlutterResult) {
        // Prime keeps its shard in iCloud Documents.
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ubiquityURL = FileManager.default.url(
                forUbiquityContainerIdentifier: "iCloud.com.foundationdevices.envoy"
            ) else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            let documentsURL = ubiquityURL.appendingPathComponent("Documents")
            try? FileManager.default.createDirectory(
                at: documentsURL,
                withIntermediateDirectories: true
            )
            let destination = documentsURL.appendingPathComponent("prime.secret")

            // Copy old locations once if the new file is missing.
            if let container = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: Self.appGroupID
            ) {
                let source = container.appendingPathComponent("prime.secret")
                if FileManager.default.fileExists(atPath: source.path),
                   !FileManager.default.fileExists(atPath: destination.path) {
                    try? FileManager.default.copyItem(at: source, to: destination)
                }
            }

            if let applicationSupport = try? self.applicationSupportURL() {
                let source = applicationSupport.appendingPathComponent("prime.secret")
                if FileManager.default.fileExists(atPath: source.path),
                   !FileManager.default.fileExists(atPath: destination.path) {
                    try? FileManager.default.copyItem(at: source, to: destination)
                }
            }

            DispatchQueue.main.async {
                result(destination.path)
            }
        }
    }

    private var sharedAccessGroup: String {
        get throws {
            let privateGroup = try privateAccessGroup
            guard let bundleID = Bundle.main.bundleIdentifier,
                  privateGroup.hasSuffix(bundleID) else {
                throw MagicBackupKeychainError.unableToResolveAccessGroup
            }
            let prefix = privateGroup.dropLast(bundleID.count)
            return prefix + Self.sharedAccessGroupSuffix
        }
    }

    private var privateAccessGroup: String {
        get throws {
            if let resolvedPrivateAccessGroup {
                return resolvedPrivateAccessGroup
            }

            // Ask Keychain for the app's real access group.
            let account = UUID().uuidString
            let lookup: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: Self.accessGroupProbeService
            ]
            var item = lookup
            item[kSecValueData] = Data()
            item[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            let addStatus = SecItemAdd(item as CFDictionary, nil)
            defer {
                SecItemDelete(lookup as CFDictionary)
            }

            guard addStatus == errSecSuccess else {
                throw MagicBackupKeychainError.keychain(addStatus)
            }

            var query = lookup
            query[kSecReturnAttributes] = true
            query[kSecMatchLimit] = kSecMatchLimitOne
            var result: CFTypeRef?
            let readStatus = SecItemCopyMatching(query as CFDictionary, &result)
            guard readStatus == errSecSuccess,
                  let attributes = result as? [String: Any],
                  let accessGroup = attributes[kSecAttrAccessGroup as String] as? String else {
                throw MagicBackupKeychainError.unableToResolveAccessGroup
            }
            resolvedPrivateAccessGroup = accessGroup
            return accessGroup
        }
    }

    @objc
    private func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
              let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else {
            return
        }

        switch reason {
        case NSUbiquitousKeyValueStoreAccountChange,
             NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange:
            // Only the old Prime entry still uses KVS.
            if keys.contains(Self.v1PrimeKVSKey) {
                restoreV1PrimeDataFromKVS()
            }
        default:
            break
        }
    }
}

private enum MagicBackupSeedSource: String {
    case v1
    case v2
}

private struct MagicBackupPrivateSeedRecord: Codable, Equatable {
    let seed: String
    let backupEnabled: Bool
}

private enum MagicBackupKeychainError: LocalizedError {
    case invalidSeedEncoding
    case invalidPrivateRecord
    case keychain(OSStatus)
    case readbackFailed
    case unableToResolveAccessGroup

    var errorDescription: String? {
        switch self {
        case .invalidSeedEncoding:
            return "The stored seed is not valid UTF-8"
        case .invalidPrivateRecord:
            return "The private Magic Backup record is invalid"
        case let .keychain(status):
            return "Keychain operation failed with status \(status)"
        case .readbackFailed:
            return "Magic Backup seed readback failed"
        case .unableToResolveAccessGroup:
            return "Unable to resolve the signed Keychain access group"
        }
    }
}
