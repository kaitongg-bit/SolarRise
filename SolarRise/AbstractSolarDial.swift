import SwiftUI

struct AbstractSolarDial: View {
    @Binding var betAmount: Int
    let maxBalance: Int
    
    // Read directly from AppStorage since we don't need to write to it here
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    
    @State private var rotation: Double = 0
    
    private let minBet = 10
    private var maxBet: Int {
        min(1000, maxBalance)
    }
    
    private var progress: Double {
        guard maxBet > minBet else { return 0 }
        return Double(betAmount - minBet) / Double(maxBet - minBet)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Outer subtle ring
                Circle()
                    .stroke(
                        Color.gray.opacity(0.1),
                        lineWidth: 1
                    )
                    .frame(width: size * 0.9, height: size * 0.9)
                
                // Progress path (very thin and elegant)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: size * 0.9, height: size * 0.9)
                    .rotationEffect(.degrees(-90))
                
                // Center "Sun" - Abstract Orb of Light
                ZStack {
                    // Soft aura
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "FFF9E3").opacity(0.8),
                                    Color(hex: "FFF9E3").opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size * 0.35
                            )
                        )
                        .scaleEffect(0.9 + (progress * 0.2))
                    
                    // Core orb
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white, Color(hex: "FFF9E3")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.4, height: size * 0.4)
                        .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 20)
                }
                
                // Minimalist handle
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.08), radius: 5, y: 2)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "FFD700").opacity(0.5), lineWidth: 1)
                    )
                    .offset(y: -(size * 0.9) / 2)
                    .rotationEffect(.degrees(progress * 360))
                    .gesture(
                        DragGesture(minimumDistance: 0)
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
                                
                                if clampedBet != betAmount {
                                    #if canImport(UIKit)
                                    if hapticsEnabled {
                                        let generator = UIImpactFeedbackGenerator(style: .soft)
                                        generator.impactOccurred()
                                    }
                                    #endif
                                    betAmount = clampedBet
                                }
                            }
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}


