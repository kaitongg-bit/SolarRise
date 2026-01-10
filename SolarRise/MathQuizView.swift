import SwiftUI

struct MathQuizView: View {
    var onQuizSuccess: () -> Void
    
    @State private var num1 = Int.random(in: 10...30)
    @State private var num2 = Int.random(in: 10...30)
    @State private var answer = ""
    @State private var isError = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("清醒自检")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Text("\(num1) + \(num2) =")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                TextField("?", text: $answer)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .frame(width: 80)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                    .multilineTextAlignment(.center)
            }
            
            if isError {
                Text("再试一次，你是清醒的吗？")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
            
            Button(action: checkAnswer) {
                Text("提交")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(20)
            }
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.05), radius: 20)
        .onAppear {
            isFocused = true
        }
    }
    
    private func checkAnswer() {
        if Int(answer) == (num1 + num2) {
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
            onQuizSuccess()
        } else {
            #if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
            isError = true
            answer = ""
            num1 = Int.random(in: 10...30)
            num2 = Int.random(in: 10...30)
        }
    }
}
