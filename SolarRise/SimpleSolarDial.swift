import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SimpleSolarDial: View {
    @Binding var betAmount: Int
    let maxBalance: Int
    
    @State private var rotation: Double = 0
    
    private let minBet = 10
    private var maxBet: Int {
        min(1000, maxBalance)
    }
    
    private var progress: Double {
        guard maxBet > minBet else { return 0 }
        return Double(betAmount - minBet) / Double(maxBet - minBet)
    }
    
    private var sunScale: Double {
        0.8 + (progress * 0.4) // 0.8 to 1.2
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: size * 0.85, height: size * 0.85)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [.yellow, .orange, .yellow],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: size * 0.85, height: size * 0.85)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .orange.opacity(0.5), radius: 10)
                
                // Central Sun
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.yellow.opacity(0.4),
                                    Color.orange.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    
                    // Sun body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white, .yellow, .orange],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .yellow.opacity(0.8), radius: 20)
                    
                    // Sun rays
                    ForEach(0..<8) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange.opacity(0.6), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 35, height: 6)
                            .offset(x: 50)
                            .rotationEffect(.degrees(Double(i) * 45 + rotation))
                    }
                }
                .scaleEffect(sunScale)
                .onAppear {
                    withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
                
                // Draggable handle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white, .yellow.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: .white.opacity(0.4), radius: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                    )
                    .offset(y: -(size * 0.85) / 2)
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
