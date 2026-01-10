import Foundation
import SwiftData

@Model
final class UserStats {
    var currentBalance: Int
    var streakDays: Int
    var lastCheckInDate: Date?
    
    init(currentBalance: Int = 1000, streakDays: Int = 0, lastCheckInDate: Date? = nil) {
        self.currentBalance = currentBalance
        self.streakDays = streakDays
        self.lastCheckInDate = lastCheckInDate
    }
}
