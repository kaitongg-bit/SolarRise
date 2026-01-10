import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


// Improved Dial with proper math
struct SolarDialInteractive: View {
    @Binding var betAmount: Int
    let maxBet: Int = 1000
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            
            ZStack {
                // Background Track
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3), .orange.opacity(0.3), .blue.opacity(0.3)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                
                // Progress Arc (Bet Amount)
                Circle()
                    .trim(from: 0.0, to: CGFloat(betAmount) / CGFloat(maxBet))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.orange, .yellow]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: betAmount)
                
                // Handler
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 4)
                    .offset(y: -size / 2)
                    .rotationEffect(Angle.degrees(Double(betAmount) / Double(maxBet) * 360))
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                                let angle = atan2(vector.dy, vector.dx) + .pi / 2
                                let fixedAngle = angle < 0 ? angle + 2 * .pi : angle
                                
                                let progress = fixedAngle / (2 * .pi)
                                let newBet = Int(progress * Double(maxBet))
                                
                                // Haptic Feedback
                                if abs(newBet - betAmount) > 50 {
                                    #if canImport(UIKit)
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    #endif
                                }
                                
                                self.betAmount = min(max(newBet, 0), maxBet)
                            }
                    )
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
