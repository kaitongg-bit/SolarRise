# SolarRise (MVP)

An offline-first, gamified habit-building app where users stake "Sun Drops" to wake up on time.

## Project Structure

- **App**: Entry point (`SolarRiseApp.swift`) setting up SwiftData.
- **Models**: SwiftData models (`DailyRecord`, `UserStats`).
- **Views**: SwiftUI views organized by feature (Home, Challenge, Result).
- **Services**: Business logic (`LightSensor`, `StoreManager`).
- **Intents**: App Intents for Shortcuts/Back Tap (`WakeUpIntent`).
- **Resources**: Localization files (`en.lproj`, `zh-Hans.lproj`).

## Usage Instructions

1. **Create Xcode Project**:
   - Open Xcode and create a new iOS App.
   - Drag the `SolarRise` folder into your project.
   - Remove the default `ContentView` and `App` files created by Xcode.
   - Ensure `SolarRiseApp.swift` is your main entry point.

2. **Configuration (Info.plist)**:
   Add the following privacy keys to your `Info.plist`:
   - `NSCameraUsageDescription`: "Used to detect ambient light level for the wake-up challenge. No photos are saved."
   - `NSUserTrackingUsageDescription`: (Optional, if tracking is used later).

3. **Capabilities**:
   - Enable **iCloud / SwiftData** (if syncing is desired later, currently local).
   - Enable **In-App Purchase** capability for StoreKit to work.
   - Enable **Background Modes** if needed for deeper timer integration (though Notifications handle most initiation).

4. **Localization**:
   - Ensure your Project Verification settings include "Chinese, Simplified" to pick up the `zh-Hans.lproj`.

## Key Features

- **Solar Dial**: A custom circular slider in `SolarDialView` to set bets.
- **Light Sensor**: Uses Camera sample buffers to detect brightness (Average Luminosity).
- **StoreKit 2**: Local handling of consumable "Sun Drop" purchases.
