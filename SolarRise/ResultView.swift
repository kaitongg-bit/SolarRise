import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ResultView: View {
    let success: Bool
    let amount: Int
    var onDismiss: () -> Void
    
    @State private var sunOffset: CGFloat = 400
    @State private var skyColors: [Color] = [.black, .black, .black]
    @State private var glowOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var raysRotation: Double = 0
    @State private var particlesAppear = false
    @State private var hapticPhase = 0
    
    var body: some View {
        ZStack {
            // Animated Sky Background
            LinearGradient(
                colors: skyColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if success {
                // Stars fading out
                StarsLayer()
                    .opacity(1.0 - min(1.0, (400 - sunOffset) / CGFloat(400)))
                
                // The Rising Sun
                ZStack {
                    // Outer glow
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.yellow.opacity(0.3 - Double(i) * 0.05),
                                        Color.orange.opacity(0.2 - Double(i) * 0.03),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100 + CGFloat(i * 30)
                                )
                            )
                            .frame(width: 200 + CGFloat(i * 60), height: 200 + CGFloat(i * 60))
                            .blur(radius: 20)
                    }
                    
                    // Sun rays
                    ForEach(0..<12) { i in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.white, .yellow, .orange.opacity(0.3), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 80, height: 6)
                            .offset(x: 75)
                            .rotationEffect(.degrees(Double(i) * 30 + raysRotation))
                    }
                    
                    // Main sun
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white,
                                    .yellow,
                                    .orange,
                                    Color(red: 1.0, green: 0.5, blue: 0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: .yellow, radius: 40)
                        .shadow(color: .orange, radius: 60)
                }
                .offset(y: sunOffset)
                
                // Light particles
                if particlesAppear {
                    ForEach(0..<30, id: \.self) { i in
                        LightParticle(index: i)
                    }
                }
            } else {
                // Fading sun for failure
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.gray, .black.opacity(0.8)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 150, height: 150)
                        .opacity(0.5)
                }
            }
            
            // Content overlay
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    // Result Icon
                    Image(systemName: success ? "sunrise.fill" : "sunset.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: success ? [.yellow, .orange] : [.gray, .black],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .opacity(textOpacity)
                    
                    // Title
                    Text(success ? "日出东方" : "日落西山")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: success ? [.white, .yellow] : [.gray, .white.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(textOpacity)
                    
                    // Amount
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 24))
                        Text(success ? "+\(amount)" : "-\(amount)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(success ? .yellow : .red)
                    .opacity(textOpacity)
                    
                    if success {
                        Text("挑战成功！连胜持续中")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .opacity(textOpacity)
                    } else {
                        VStack(spacing: 16) {
                            Text("挑战失败，连胜中断")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .opacity(textOpacity)
                            
                            // Redemption button (if within grace period)
                            Button(action: {
                                onDismiss()
                                // Post a notification to handle logic
                                // The user already lost 'amount', so the penalty to reach 1.5x is 0.5x more
                                NotificationCenter.default.post(name: NSNotification.Name("RedeemStreak"), object: amount)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "flame.fill")
                                    Text("重燃太阳 (加付 \(Int(Double(amount) * 0.5)) 光点)")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "FF4500"), Color(hex: "FF0000")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .red.opacity(0.3), radius: 10, y: 5)
                                )
                            }
                            .opacity(textOpacity)
                        }
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 20)
                )
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    onDismiss()
                }) {
                    Text("继续")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            if success {
                performSuccessAnimation()
            } else {
                performFailureAnimation()
            }
        }
    }
    
    private func performSuccessAnimation() {
        // Animate sky colors from night to day
        withAnimation(.easeInOut(duration: 2.5)) {
            skyColors = [
                Color(red: 0.4, green: 0.6, blue: 1.0),  // Light blue
                Color(red: 1.0, green: 0.7, blue: 0.4),  // Orange
                Color(red: 1.0, green: 0.9, blue: 0.6)   // Light yellow
            ]
        }
        
        // Sun rises
        withAnimation(.spring(response: 2.5, dampingFraction: 0.7)) {
            sunOffset = -100
        }
        
        // Rotate rays
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            raysRotation = 360
        }
        
        // Text appears
        withAnimation(.easeIn(duration: 0.8).delay(1.5)) {
            textOpacity = 1.0
        }
        
        // Particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                particlesAppear = true
            }
        }
        
        // Progressive haptics
        #if canImport(UIKit)
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                let generator = UIImpactFeedbackGenerator(style: i < 3 ? .light : .medium)
                generator.impactOccurred()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        #endif
    }
    
    private func performFailureAnimation() {
        withAnimation(.easeIn(duration: 1.5)) {
            skyColors = [.black, Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.1)]
            textOpacity = 1.0
        }
        
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}

// MARK: - Supporting Views
struct StarsLayer: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<60, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.6)
                        )
                        .opacity(Double.random(in: 0.3...0.9))
                }
            }
        }
    }
}

struct LightParticle: View {
    let index: Int
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: CGFloat.random(in: 4...10))
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                .offset(offset)
                .opacity(opacity)
                .onAppear {
                    let angle = Double(index) * 12.0
                    let distance = CGFloat.random(in: 150...300)
                    
                    withAnimation(.easeOut(duration: Double.random(in: 1.5...2.5))) {
                        offset = CGSize(
                            width: cos(angle * .pi / 180) * distance,
                            height: sin(angle * .pi / 180) * distance
                        )
                        opacity = 0
                    }
                }
        }
    }
}
