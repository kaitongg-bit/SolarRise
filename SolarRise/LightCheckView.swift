import SwiftUI

struct LightCheckView: View {
    @StateObject private var lightSensor = LightSensor()
    @State private var showQuiz = false
    @Binding var isPresented: Bool
    var onChallengeSuccess: () -> Void
    var onChallengeFailure: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Use light theme
            
            if !showQuiz {
                VStack(spacing: 40) {
                    Text("面向晨曦")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.top, 60)
                    
                    Text("请面向窗户或明亮光源以收集光能")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Visual Indicator
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 2)
                            .frame(width: 220, height: 220)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "FFD700").opacity(0.6), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 110
                                )
                            )
                            .frame(width: 220 * CGFloat(lightSensor.currentBrightness), height: 220 * CGFloat(lightSensor.currentBrightness))
                            .animation(.spring(), value: lightSensor.currentBrightness)
                        
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "FFD700"))
                    }
                    
                    Text("\(Int(lightSensor.currentBrightness * 100))%")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Button("取消 (放弃光点)") {
                        lightSensor.stop()
                        onChallengeFailure()
                        isPresented = false
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.red.opacity(0.6))
                    .padding(.bottom, 20)
                    
                    #if targetEnvironment(simulator)
                    Button("Debug: 跳过感应") {
                        showQuiz = true
                    }
                    .padding(.bottom, 40)
                    #endif
                }
            } else {
                MathQuizView(onQuizSuccess: {
                    lightSensor.stop()
                    onChallengeSuccess()
                    isPresented = false
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            }
        }
        .onChange(of: lightSensor.isBright) { oldValue, newValue in
            if newValue {
                withAnimation {
                    showQuiz = true
                }
            }
        }
    }
}
