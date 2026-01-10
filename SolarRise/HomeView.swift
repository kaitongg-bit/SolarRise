import SwiftUI
import SwiftData
import UserNotifications

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userStats: [UserStats]
    
    @StateObject private var storeManager = StoreManager()
    
    @State private var betAmount: Int = 100
    @State private var wakeUpTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingChallenge = false
    @State private var showingResult = false
    @State private var lastResultSuccess = false
    @State private var lastResultAmount = 0
    
    @AppStorage("isChallengeActive") private var isChallengeActive = false
    @AppStorage("targetTime") private var targetTime: Double = Date().timeIntervalSince1970
    @AppStorage("lockedBet") private var lockedBet: Int = 0
    
    var currentUser: UserStats {
        if let first = userStats.first {
            return first
        } else {
            let new = UserStats()
            modelContext.insert(new)
            return new
        }
    }
    
    var body: some View {
        ZStack {
            // Elegant Light Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: "FFFFFF"),
                    Color(hex: "FFF9E3").opacity(0.5),
                    Color(hex: "F8F9FA")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Stats (Minimalist)
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(currentUser.streakDays)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.orange.opacity(0.1)))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("\(currentUser.currentBalance)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color(hex: "FFD700").opacity(0.1)))
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                if !isChallengeActive {
                    VStack(spacing: 40) {
                        // Title & Time Picker
                        VStack(spacing: 16) {
                            Text("设定晨曦之时")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray.opacity(0.8))
                                .tracking(2)
                            
                            DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(height: 120)
                                .clipped()
                        }
                        
                        // Abstract Dial Section
                        VStack(spacing: 24) {
                            AbstractSolarDial(betAmount: $betAmount, maxBalance: currentUser.currentBalance)
                                .frame(width: 260, height: 260)
                            
                            VStack(spacing: 8) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(betAmount)")
                                        .font(.system(size: 40, weight: .light, design: .rounded))
                                    Text("光点")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Text("承诺挑战")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .tracking(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Start Button (Pure & Simple)
                        Button(action: commitToWakeUp) {
                            Text("种下太阳")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(30)
                                .shadow(color: Color(hex: "FFA500").opacity(0.3), radius: 15, y: 10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    }
                } else {
                    // Waiting State (Minimalist)
                    VStack(spacing: 40) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.05), lineWidth: 1)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "FFF9E3").opacity(0.3), .clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 250, height: 250)
                            
                            Text(Date(timeIntervalSince1970: targetTime).formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 48, weight: .ultraLight, design: .rounded))
                        }
                        
                        Text("静候晨光")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray.opacity(0.5))
                            .tracking(4)
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Button(action: { showingChallenge = true }) {
                                Text("立即唤醒 (调试)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                            
                            Button(action: { isChallengeActive = false }) {
                                Text("取消挑战")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        #if os(iOS)
        .fullScreenCover(isPresented: $showingChallenge) {
            LightCheckView(
                isPresented: $showingChallenge,
                onChallengeSuccess: handleSuccess,
                onChallengeFailure: handleFailure
            )
        }
        .fullScreenCover(isPresented: $showingResult) {
            ResultView(
                success: lastResultSuccess,
                amount: lastResultAmount,
                onDismiss: { showingResult = false }
            )
        }
        #endif
    }
    
    private func commitToWakeUp() {
        guard currentUser.currentBalance >= betAmount else { return }
        
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        currentUser.currentBalance -= betAmount
        lockedBet = betAmount
        
        // Calculate target time: specified hour/minute for tomorrow
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeUpTime)
        
        components.day! += 1
        components.hour = wakeComponents.hour
        components.minute = wakeComponents.minute
        
        if let target = calendar.date(from: components) {
            targetTime = target.timeIntervalSince1970
            isChallengeActive = true
        }
    }
    
    private func handleSuccess() {
        let reward = Int(Double(lockedBet) * 0.05)
        currentUser.currentBalance += (lockedBet + reward)
        currentUser.streakDays += 1
        modelContext.insert(DailyRecord(date: Date(), betAmount: lockedBet, status: .success))
        lastResultSuccess = true
        lastResultAmount = reward
        showingResult = true
        isChallengeActive = false
    }
    
    private func handleFailure() {
        currentUser.streakDays = 0
        modelContext.insert(DailyRecord(date: Date(), betAmount: lockedBet, status: .failed))
        lastResultSuccess = false
        lastResultAmount = lockedBet
        showingResult = true
        isChallengeActive = false
    }
}
