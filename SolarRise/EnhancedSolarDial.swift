import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Enhanced Solar Dial with glowing sun in center
struct EnhancedSolarDial: View {
    @Binding var betAmount: Int
    let maxBalance: Int
    
    @State private var sunPulse: Bool = false
    @State private var rotationAngle: Double = 0
    
    private let minBet = 10
    private var maxBet: Int {
        min(1000, maxBalance)
    }
    
    private var progress: Double {
        guard maxBet > minBet else { return 0 }
        return Double(betAmount - minBet) / Double(maxBet - minBet)
    }
    
    private var sunSize: CGFloat {
        80 + (progress * 40) // 80 to 120
    }
    
    private var sunGlow: CGFloat {
        20 + (progress * 40) // 20 to 60
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.9
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Outer ring - track
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.2),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                
                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                .yellow,
                                .orange,
                                Color(red: 1.0, green: 0.6, blue: 0.0),
                                .yellow
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .orange.opacity(0.6), radius: 10)
                
                // Tick marks around the circle
                ForEach(0..<12) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 12)
                        .offset(y: -size / 2 + 6)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                
                // Central Sun
                ZStack {
                    // Glow layers
                    ForEach(0..<3) { layer in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.yellow.opacity(0.3 - Double(layer) * 0.1),
                                        Color.orange.opacity(0.2 - Double(layer) * 0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: sunSize / 2 + CGFloat(layer * 20)
                                )
                            )
                            .frame(width: sunSize + CGFloat(layer * 40), height: sunSize + CGFloat(layer * 40))
                            .blur(radius: 10)
                    }
                    
                    // Main sun body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    .white,
                                    .yellow,
                                    .orange
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: sunSize / 2
                            )
                        )
                        .frame(width: sunSize, height: sunSize)
                        .shadow(color: .yellow.opacity(0.8), radius: sunGlow)
                    
                    // Sun rays
                    ForEach(0..<8) { i in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange.opacity(0.5), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 30 + progress * 20, height: 4)
                            .offset(x: sunSize / 2 + 10)
                            .rotationEffect(.degrees(Double(i) * 45 + rotationAngle))
                    }
                }
                .scaleEffect(sunPulse ? 1.05 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        sunPulse = true
                    }
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
                
                // Draggable handle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .overlay(
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                    )
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(progress * 360))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                let vector = CGVector(
                                    dx: value.location.x - center.x,
                                    dy: value.location.y - center.y
                                )
                                var angle = atan2(vector.dy, vector.dx) + .pi / 2
                                if angle < 0 { angle += 2 * .pi }
                                
                                let newProgress = angle / (2 * .pi)
                                let newBet = minBet + Int(newProgress * Double(maxBet - minBet))
                                let clampedBet = min(max(newBet, minBet), maxBet)
                                
                                // Haptic feedback every 100 points
                                #if canImport(UIKit)
                                if abs(clampedBet - betAmount) >= 100 {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                                #endif
                                
                                betAmount = clampedBet
                            }
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
