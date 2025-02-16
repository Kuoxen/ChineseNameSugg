import SwiftUI

struct NameGeneratorView: View {
    @State private var surname = ""
    @State private var generatedNames: [NameResponse] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("请输入姓氏", text: $surname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: generateName) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "生成中..." : "生成名字")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(surname.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(surname.isEmpty || isLoading)
                
                if !generatedNames.isEmpty {
                    Text("为您生成的\(generatedNames.count)个名字建议")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(generatedNames) { response in
                        ResultView(
                            title: "名字方案",
                            content: "\(surname)\(response.name)",
                            explanation: response.explanation
                        )
                        .padding(.vertical, 5)
                    }
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
    
    private func generateName() {
        isLoading = true
        generatedNames.removeAll()
        
        Task {
            do {
                let responses = try await LLMService.shared.generateNames(surname: surname)
                DispatchQueue.main.async {
                    generatedNames = responses
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