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
    @AppStorage("startTime") private var startTime: Double = Date().timeIntervalSince1970
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
    
    private var motivationalMessage: String {
        if betAmount >= 500 {
            return "豪掷千金买晨曦，你是懂自律的！"
        } else if betAmount >= 200 {
            return "这个注码，明早的阳光一定很贵。"
        } else if betAmount >= 100 {
            return "细水长流，明早也要准时相约哦。"
        } else {
            return "种下一颗种子，期待明早的惊喜。"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                    // MARK: - Top Anchor (Stats)
                    // Pushed down by safe area + slight offset to clear Island
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(currentUser.streakDays)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.orange.opacity(0.1)))
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(Color(hex: "FFD700"))
                            Text("\(currentUser.currentBalance)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color(hex: "FFD700").opacity(0.1)))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, geometry.safeAreaInsets.top > 20 ? geometry.safeAreaInsets.top + 10 : 60)
                    
                    if !isChallengeActive {
                        // MARK: - Flexible Center Content
                        // This VStack takes up all remaining space between Header and Footer
                        Spacer()
                        
                        VStack(spacing: 0) {
                            // 1. Motivation & Time Picker Group
                            VStack(spacing: 20) {
                                Text(motivationalMessage)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.orange.opacity(0.9))
                                    .padding(.horizontal, 40)
                                    .multilineTextAlignment(.center)
                                    .frame(height: 50)
                                    .animation(.spring(), value: betAmount)
                                
                                VStack(spacing: 0) {
                                    Text("设定晨曦之时")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.4))
                                        .tracking(2)
                                        .padding(.bottom, 10)
                                    
                                    DatePicker("", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.wheel)
                                        .labelsHidden()
                                        .frame(height: 100)
                                        .clipped()
                                }
                            }
                            
                            // Dynamic Spacer based on screen height to separate Picker and Dial
                            Spacer().frame(height: geometry.size.height * 0.05)
                            
                            // 2. Solar Dial Group
                            VStack(spacing: 16) {
                                AbstractSolarDial(betAmount: $betAmount, maxBalance: currentUser.currentBalance)
                                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6) // Responsive size
                                    .frame(maxWidth: 240, maxHeight: 240) // But capped maximum
                                
                                VStack(spacing: 4) {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(betAmount)")
                                            .font(.system(size: 36, weight: .light, design: .rounded))
                                            .contentTransition(.numericText())
                                        Text("光点")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("承诺挑战")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.gray.opacity(0.3))
                                        .tracking(1)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        // MARK: - Bottom Anchor (Action Button)
                        Button(action: commitToWakeUp) {
                            Text("种下太阳")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 180)
                                .padding(.vertical, 14)
                                .background(
                                    ZStack {
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    }
                                )
                                .shadow(color: Color(hex: "FFA500").opacity(0.3), radius: 15, y: 10)
                        }
                        // Dynamic bottom padding: Safe Area + TabBar height estimate
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 100)
                        
                    } else {
                        // MARK: - Walking/Waiting State Center
                        Spacer()
                        
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
                            
                            VStack(spacing: 24) {
                                Button(action: { showingChallenge = true }) {
                                    Text("立即唤醒 (调试)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.orange.opacity(0.6))
                                }
                                
                                Button(action: {
                                    handleRegret()
                                }) {
                                    VStack(spacing: 4) {
                                        Text("反悔退出")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        let now = Date().timeIntervalSince1970
                                        let timeSinceStart = now - startTime
                                        let timeRemaining = targetTime - now
                                        
                                        if timeSinceStart < 300 {
                                            Text("5分钟内误操作免费取消")
                                                .font(.system(size: 11))
                                        } else if timeRemaining > 21600 {
                                            Text("入睡前反悔不计违约")
                                                .font(.system(size: 11))
                                        } else if timeRemaining < 3600 {
                                            Text("临阵脱逃扣除 80% 押注")
                                                .font(.system(size: 11))
                                        } else {
                                            Text("深夜反悔扣除 20% 押注")
                                                .font(.system(size: 11))
                                        }
                                    }
                                    .foregroundColor(.red.opacity(0.7))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Capsule().stroke(Color.red.opacity(0.2), lineWidth: 1))
                                }
                            }
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 80)
                        }
                        
                        Spacer()
                    }
                }
                .ignoresSafeArea(.all, edges: .all) // Crucial: We manage safe area manually
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RedeemStreak"))) { notification in
            if let amount = notification.object as? Int {
                let costGap = Int(Double(amount) * 0.5) // We only deduct the extra 0.5x here
                if currentUser.currentBalance >= costGap {
                    currentUser.currentBalance -= costGap
                    
                    // Update the last failed record to redeemed
                    let descriptor = FetchDescriptor<DailyRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
                    if let records = try? modelContext.fetch(descriptor), let lastFailed = records.first(where: { $0.status == .failed }) {
                        lastFailed.status = .redeemed
                    }
                    
                    currentUser.streakDays += 1
                    
                    #if canImport(UIKit)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    #endif
                }
            }
        }
    }
    
    private func handleRegret() {
        let now = Date().timeIntervalSince1970
        let timeSinceStart = now - startTime
        let timeRemaining = targetTime - now
        
        var refundRate: Double = 1.0 // Default: Full refund
        
        // 1. Grace Period: If cancelled within 5 mins of setting, it's free/misclick
        if timeSinceStart < 300 {
            refundRate = 1.0
        }
        // 2. Far away: If it's still more than 6 hours before target time, it's free
        else if timeRemaining > 21600 {
            refundRate = 1.0
        }
        // 3. Night Regret: 1-6 hours remaining, 20% penalty
        else if timeRemaining > 3600 {
            refundRate = 0.8
        }
        // 4. Morning Panic: < 1 hour remaining, 80% penalty
        else {
            refundRate = 0.2
        }
        
        // Process refund
        let refundAmount = Int(Double(lockedBet) * refundRate)
        let penaltyAmount = lockedBet - refundAmount
        
        currentUser.currentBalance += refundAmount
        
        // Only record in history if there was a real penalty
        if penaltyAmount > 0 {
            modelContext.insert(DailyRecord(date: Date(), betAmount: penaltyAmount, status: .failed))
        }
        
        isChallengeActive = false
        lockedBet = 0
        
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(refundRate == 1.0 ? .success : .warning)
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
            startTime = Date().timeIntervalSince1970
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
