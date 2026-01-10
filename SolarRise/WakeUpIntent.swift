import AppIntents
import Foundation

struct WakeUpIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Up Check-in"
    static var description = IntentDescription("Trigger this via Back Tap to finish your morning challenge.")
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        // Signal the app to open the Light Check Challenge
        NotificationCenter.default.post(name: NSNotification.Name("TriggerWakeUpChallenge"), object: nil)
        return .result()
    }
}
