import SwiftUI

struct ZiGeneratorView: View {
    @State private var surname = ""
    @State private var givenName = ""
    @State private var generatedZi = ""
    @State private var explanation = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("请输入姓氏", text: $surname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("请输入名字", text: $givenName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: generateZi) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "生成中..." : "生成字")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(surname.isEmpty || givenName.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(surname.isEmpty || givenName.isEmpty || isLoading)
                
                if !generatedZi.isEmpty {
                    ResultView(title: "生成的字", content: generatedZi, explanation: explanation)
                }
            }
            .padding()
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateZi() {
        isLoading = true
        Task {
            do {
                let fullName = surname + givenName
                let response = try await LLMService.shared.generateZi(fullName: fullName)
                DispatchQueue.main.async {
                    generatedZi = response.zi
                    explanation = response.explanation
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
}