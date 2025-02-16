import SwiftUI
import UniformTypeIdentifiers

struct HaoGeneratorView: View {
    @State private var isFilePickerPresented = false
    @State private var selectedFileURL: URL?
    @State private var generatedHao = ""
    @State private var explanation = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var resumeContent = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: { isFilePickerPresented = true }) {
                    HStack {
                        Image(systemName: "doc")
                        Text(selectedFileURL?.lastPathComponent ?? "选择简历文件")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                if !resumeContent.isEmpty {
                    Text("已读取简历内容")
                        .foregroundColor(.green)
                }
                
                Button(action: generateHao) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isLoading ? "生成中..." : "生成号")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(resumeContent.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(resumeContent.isEmpty || isLoading)
                
                if !generatedHao.isEmpty {
                    ResultView(title: "生成的号", content: generatedHao, explanation: explanation)
                }
            }
            .padding()
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.pdf, .plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                // 确保文件可访问
                guard url.startAccessingSecurityScopedResource() else {
                    errorMessage = "无法访问选中的文件"
                    showError = true
                    return
                }
                
                do {
                    resumeContent = try DocumentParser.extractText(from: url)
                    selectedFileURL = url
                } catch {
                    errorMessage = "文件读取失败：\(error.localizedDescription)"
                    showError = true
                }
                
                url.stopAccessingSecurityScopedResource()
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func generateHao() {
        guard !resumeContent.isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                let response = try await LLMService.shared.generateHao(resume: resumeContent)
                DispatchQueue.main.async {
                    generatedHao = response.hao
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
