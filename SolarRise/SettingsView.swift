import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var storeManager = StoreManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var userStats: [UserStats]
    
    var currentUser: UserStats {
        userStats.first ?? UserStats()
    }
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("设置与宁静")
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
                                Button(action: {
                                    // Could show IAP here
                                }) {
                                    Text("充值")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Capsule().stroke(Color.orange, lineWidth: 1))
                                }
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
                                            try? await storeManager.purchase(product)
                                        }
                                    }
                                }
                                
                                // Mock products if storeManager is empty (for simulator/testing)
                                if storeManager.products.isEmpty {
                                    MockProductRow(name: "100 光点", price: "¥1.00", icon: "sun.min")
                                    MockProductRow(name: "500 光点", price: "¥3.00", icon: "sun.max")
                                    MockProductRow(name: "1000 光点", price: "¥6.00", icon: "sun.max.fill")
                                }
                            }
                            .background(Color.gray.opacity(0.1))
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
                                SettingRow(icon: "globe", title: "语言", detail: "简体中文")
                                SettingRow(icon: "bell.badge", title: "提醒", detail: "已开启")
                                SettingRow(icon: "hand.tap", title: "触感反馈", detail: "中等")
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                            .clipped()
                        }
                        
                        // About
                        VStack(spacing: 16) {
                            Text("SolarRise v1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            HStack(spacing: 20) {
                                Text("隐私政策").font(.system(size: 12))
                                Text("服务协议").font(.system(size: 12))
                            }
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
            }
            .padding()
            .background(Color.white)
        }
    }
}

struct MockProductRow: View {
    let name: String
    let price: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "FFD700"))
            Text(name)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Spacer()
            Text(price)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color.white)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let detail: String
    
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
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        .background(Color.white)
    }
}
