import SwiftUI
import SwiftData
import UserNotifications

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        // Set TabBar appearance for a clean light look
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
   @State private var selection = 0
    
    // Splash Screen Logic
    @State private var showSplash = false
    @AppStorage("lastSplashDate") private var lastSplashDate: String = ""
    @AppStorage("showDailySplash") private var showDailySplash = true
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Image(systemName: "sun.max.fill")
                        Text("晨曦")
                    }
                    .tag(0)
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("历程")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("设置")
                    }
                    .tag(2)
            }
            .accentColor(.orange)
            
            // Splash Screen Overlay
            if showSplash {
                SplashScreenView {
                    withAnimation {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            checkAndShowSplash()
            requestNotificationPermission()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ReplaySplash"))) { _ in
            withAnimation {
                showSplash = true
            }
        }
    }
    
    private func checkAndShowSplash() {
        // Respect user setting
        guard showDailySplash else { return }
        
        let today = Date().formatted(date: .numeric, time: .omitted)
        
        // Debug: Uncomment next line to force show splash every time
        // lastSplashDate = "" 
        
        if lastSplashDate != today {
            showSplash = true
            lastSplashDate = today
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
}
