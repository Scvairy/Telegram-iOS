import Foundation
import SwiftSignalKit
import TelegramCore

public struct SGStatus: Equatable, Codable {
    public var status: Int64

    // Local features are included in the personal fork, independently of the
    // server-reported purchase status, which remains unchanged in storage.
    public var hasProFeatures: Bool {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let isPersonalFork = bundleId == "me.scvairy.Timgram" || bundleId.hasPrefix("me.scvairy.Timgram.")
        return isPersonalFork || self.status > 1
    }
    
    public static var `default`: SGStatus {
        return SGStatus(status: 1)
    }
    
    public init(status: Int64) {
        self.status = status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        self.status = try container.decodeIfPresent(Int64.self, forKey: "status") ?? 1
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(self.status, forKey: "status")
    }
}

public func updateSGStatusInteractively(accountManager: AccountManager<TelegramAccountManagerTypes>, _ f: @escaping (SGStatus) -> SGStatus) -> Signal<Void, NoError> {
    return accountManager.transaction { transaction -> Void in
        transaction.updateSharedData(ApplicationSpecificSharedDataKeys.sgStatus, { entry in
            let currentSettings: SGStatus
            if let entry = entry?.get(SGStatus.self) {
                currentSettings = entry
            } else {
                currentSettings = SGStatus.default
            }
            return SharedPreferencesEntry(f(currentSettings))
        })
    }
}
