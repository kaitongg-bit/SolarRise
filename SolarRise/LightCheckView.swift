import SwiftUI

struct LightCheckView: View {
    @StateObject private var lightSensor = LightSensor()
    @Binding var isPresented: Bool
    var onChallengeSuccess: () -> Void
    var onChallengeFailure: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Text("Face the Light")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                // Visual Indicator of Light
                Circle()
                    .fill(Color.yellow.opacity(Double(lightSensor.currentBrightness)))
                    .frame(width: 200, height: 200)
                    .shadow(color: .orange, radius: CGFloat(lightSensor.currentBrightness * 50))
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
                
                Text("Brightness: \(Int(lightSensor.currentBrightness * 100))%")
                    .foregroundStyle(.gray)
                    .padding()
                
                Spacer()
                
                Button("Cancel (Give Up)") {
                    lightSensor.stop()
                    onChallengeFailure()
                    isPresented = false
                }
                .foregroundStyle(.red)
                .padding(.bottom, 10)
                
                #if targetEnvironment(simulator)
                Button("Debug: Sim Success") {
                    lightSensor.stop()
                    onChallengeSuccess()
                    isPresented = false
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(10)
                .foregroundStyle(.yellow)
                .padding(.bottom, 20)
                #else
                // Secret tap area for testing on physical devices too if needed
                Color.clear
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture(count: 3) {
                        lightSensor.stop()
                        onChallengeSuccess()
                        isPresented = false
                    }
                #endif
            }
        }
        .onChange(of: lightSensor.isBright) { oldValue, newValue in
            if newValue {
                // Challenge Succeeded
                lightSensor.stop()
                onChallengeSuccess()
                isPresented = false
            }
        }
    }
}
