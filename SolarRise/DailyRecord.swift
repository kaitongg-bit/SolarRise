import Foundation
import SwiftData

enum ChallengeStatus: String, Codable {
    case pending
    case success
    case failed
    case redeemed
}

@Model
final class DailyRecord {
    var date: Date
    var betAmount: Int
    var status: ChallengeStatus
    
    init(date: Date, betAmount: Int, status: ChallengeStatus = .pending) {
        self.date = date
        self.betAmount = betAmount
        self.status = status
    }
}
