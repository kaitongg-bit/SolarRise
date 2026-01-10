import Foundation
import SwiftUI

/// Centralized Localization Keys to avoid hardcoded strings.
/// Usage: Text(LocalizationKeys.Home.betTitle)
struct LocalizationKeys {
    struct Home {
        static let betTitle = String(localized: "home_bet_title", defaultValue: "Commitment")
        static let targetTime = String(localized: "home_target_time", defaultValue: "Wake Up Time")
        static let startButton = String(localized: "home_start_button", defaultValue: "Plant the Sun")
    }
    
    struct Result {
        static let successTitle = String(localized: "result_success_title", defaultValue: "Sunrise Achieved")
        static let failedTitle = String(localized: "result_failed_title", defaultValue: "Sunset")
        static let redemptionTitle = String(localized: "result_redemption_title", defaultValue: "The sun is setting. Reignite it?")
        static let redeemButton = String(localized: "result_redeem_button", defaultValue: "Reignite Sun (-500)")
    }
    
    struct Common {
        static let sunDrops = String(localized: "common_sundrops", defaultValue: "Sun Drops")
    }
}
