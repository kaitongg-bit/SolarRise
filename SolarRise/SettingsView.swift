import SwiftUI
import StoreKit
import SwiftData

struct SettingsView: View {
    @StateObject private var storeManager = StoreManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var userStats: [UserStats]
    
    var currentUser: UserStats {
        userStats.first ?? UserStats()
    }
    
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("设置")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("调整你的晨曦之旅")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("我的资产")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack {
                                Label {
                                    Text("\(currentUser.currentBalance)")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                } icon: {
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(Color(hex: "FFD700"))
                                }
                                Spacer()
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(.white))
                        }
                        
                        // IAP Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("获取更多光点")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 1) {
                                ForEach(storeManager.products) { product in
                                    IAPRow(product: product) {
                                        Task {
                                            do {
                                                if let transaction = try await storeManager.purchase(product) {
                                                    // Purchase successful, add coins
                                                    let amount = coinAmount(for: product.id)
                                                    addCoins(amount)
                                                }
                                            } catch {
                                                print("Purchase failed: \(error)")
                                            }
                                        }
                                    }
                                }
                                
                                // Mock products for Simulator (only show if no real products loaded)
                                if storeManager.products.isEmpty {
                                    MockProductRow(name: "100 光点 (测试)", price: "免费", icon: "sun.min") {
                                        addCoins(100)
                                    }
                                    MockProductRow(name: "500 光点 (测试)", price: "免费", icon: "sun.max") {
                                        addCoins(500)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .clipped()
                        }
                        
                            // App Settings
                        VStack(alignment: .leading, spacing: 12) {
                            Text("偏好设置")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 1) {
                                SettingRow(icon: "globe", title: "语言", detail: "跟随系统")
                                ToggleSettingRow(icon: "bell.badge", title: "每日提醒", isOn: $notificationsEnabled)
                                ToggleSettingRow(icon: "hand.tap", title: "触感反馈", isOn: $hapticsEnabled)
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .clipped()
                        }
                        
                        // About
                        VStack(spacing: 16) {
                            Text("SolarRise v1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            HStack(spacing: 20) {
                                Link("隐私政策", destination: URL(string: "https://www.apple.com")!)
                                Link("服务协议", destination: URL(string: "https://www.apple.com")!)
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.orange.opacity(0.8))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            Task {
                await storeManager.requestProducts()
            }
        }
    }
    
    private func addCoins(_ amount: Int) {
        currentUser.currentBalance += amount
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
    
    private func coinAmount(for productID: String) -> Int {
        if productID.contains("100") { return 100 }
        if productID.contains("500") { return 500 }
        if productID.contains("1200") { return 1200 }
        return 0
    }
}

struct IAPRow: View {
    let product: Product
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(Color(hex: "FFD700"))
                Text(product.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Spacer()
                Text(product.displayPrice)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange.opacity(0.1)))
            }
            .padding()
            .background(Color.white)
        }
        .buttonStyle(.plain)
        Divider().padding(.leading, 50)
    }
}

struct MockProductRow: View {
    let name: String
    let price: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "FFD700"))
                    .frame(width: 24)
                Text(name)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Spacer()
                Text(price)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.green) // Green for free/mock
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.green.opacity(0.1)))
            }
            .padding()
            .background(Color.white)
        }
        .buttonStyle(.plain)
        Divider().padding(.leading, 50)
    }
}

struct SettingRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Spacer()
            Text(detail)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        Divider().padding(.leading, 50)
    }
}

struct ToggleSettingRow: View {
    let icon: String
    let title: LocalizedStringKey
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.white)
        Divider().padding(.leading, 50)
    }
}
