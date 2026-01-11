import SwiftUI

struct SplashScreenView: View {
    var onDismiss: () -> Void
    
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background: Warm Morning Gradient
            LinearGradient(
                colors: [
                    Color(hex: "FFF9E3"), // Light cream
                    Color(hex: "FFFFFF")  // White
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 1. Logo / Icon Animation
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFD700").opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "FFD700")) // Golden
                        .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // 2. Title & Subtitle
                VStack(spacing: 16) {
                    Text(LocalizedStringKey("起了么"))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text("SolarRise")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(.gray.opacity(0.5))
                        .tracking(2)
                }
                .opacity(textOpacity)
                
                // 3. Warm Concept Intro (High EQ)
                VStack(spacing: 24) {
                    Text(LocalizedStringKey("让光点代替意志力\n陪你对抗清晨的引力"))
                        .font(.system(size: 18, weight: .light))
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text(LocalizedStringKey("基于行为心理学「损失厌恶」原理\n将自我承诺具象化\n愿每一个清晨，都始于一份庄重的契约"))
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 40)
                }
                .opacity(textOpacity)
                .padding(.top, 20)
                
                Spacer()
                
                // 4. Action Button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                        textOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onDismiss()
                    }
                }) {
                    Text(LocalizedStringKey("开启今日"))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [Color.orange, Color(hex: "FFD700")], startPoint: .leading, endPoint: .trailing))
                                .shadow(color: .orange.opacity(0.3), radius: 10, y: 5)
                        )
                }
                .opacity(textOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Animate In
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                opacity = 1.0
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView(onDismiss: {})
}
