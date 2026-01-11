import AppIntents
import SwiftUI

struct WakeUpIntent: AppIntent {
    static var title: LocalizedStringResource = "立即唤醒 (Wake Up Now)"
    static var description = IntentDescription("快速进入光线检测模式 (Quickly enter light detection mode)")

    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        // When the intent runs and opens the app, we post a notification
        // The HomeView will listent to this notification found in 'onReceive'
        print("📲 WakeUpIntent performed! Posting TriggerWakeUp notification...")
        NotificationCenter.default.post(name: NSNotification.Name("TriggerWakeUp"), object: nil)
        return .result()
    }
}
