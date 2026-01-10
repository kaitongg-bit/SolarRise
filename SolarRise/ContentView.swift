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
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "sun.max.fill" : "sun.max")
                    Text("晨曦")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "timer.circle.fill" : "timer")
                    Text("历程")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "leaf.fill" : "leaf")
                    Text("宁静")
                }
                .tag(2)
        }
        .tint(Color(hex: "FFA500"))
        .preferredColorScheme(.light)
    }
}

struct HistoryView: View {
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "sun.haze")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.3))
                Text("记录每一次与太阳的约定")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.3))
                Text("寻找内心的宁静时刻")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.gray)
            }
        }
    }
}
