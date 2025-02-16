import Foundation

class LLMService {
    static let shared = LLMService()
    private let apiKey = "a9F1LhUvHJN9Ff2jdv5AhYr2"
    private let secretKey = "pRGwmOKYLnsHHjvzNSEKNmPR3b1OAE4Z"
    private let baseURL = "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions"
    private var accessToken: String = ""
    private var tokenExpirationDate: Date?
    
    private init() {}
    
    private func getAccessToken() async throws -> String {
        if let expirationDate = tokenExpirationDate,
           expirationDate > Date(),
           !accessToken.isEmpty {
            return accessToken
        }
        
        let tokenURL = "https://aip.baidubce.com/oauth/2.0/token"
        var components = URLComponents(string: tokenURL)!
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),
            URLQueryItem(name: "client_id", value: apiKey),
            URLQueryItem(name: "client_secret", value: secretKey)
        ]
        
        let request = URLRequest(url: components.url!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        accessToken = response.access_token
        tokenExpirationDate = Date().addingTimeInterval(response.expires_in)
        return accessToken
    }
    
    private func makeRequest(prompt: String) async throws -> String {
        let token = try await getAccessToken()
        guard var components = URLComponents(string: baseURL) else {
            throw LLMError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "access_token", value: token)]
        
        guard let url = components.url else {
            throw LLMError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ChatRequest(messages: [
            Message(role: "user", content: prompt)
        ])
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        return response.result
    }
    
    func generateNames(surname: String) async throws -> [NameResponse] {
        let prompt = """
        请为姓氏'\(surname)'生成10个不同的富有诗意的名字，要求：
        1. 符合中国传统文化
        2. 寓意美好
        3. 字义优雅
        4. 每个名字都要独特，不要重复
        5. 使用如下格式返回（注意分号分隔）：
        名字：xxx；解释：xxx
        名字：xxx；解释：xxx
        ...（共10个）
        """
        
        let result = try await makeRequest(prompt: prompt)
        return try parseMultipleResponses(result)
    }
    
    private func parseMultipleResponses(_ response: String) throws -> [NameResponse] {
        let lines = response.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        return try lines.map { line in
            let components = line.components(separatedBy: "；")
            guard components.count >= 2,
                  let nameComponent = components.first,
                  let explanationComponent = components.last else {
                throw LLMError.invalidResponse
            }
            
            let name = nameComponent.components(separatedBy: "：").last ?? ""
            let explanation = explanationComponent.components(separatedBy: "：").last ?? ""
            
            return NameResponse(name: name, explanation: explanation)
        }
    }
    
    func generateZi(fullName: String) async throws -> ZiResponse {
        let prompt = "请为'\(fullName)'生成一个符合古人取字规则的字，要求：1. 符合传统取字规范 2. 与名字相关联 3. 意境优美。请按照以下格式返回：字：xxx；解释：xxx"
        let result = try await makeRequest(prompt: prompt)
        return try parseResponse(result, type: ZiResponse.self)
    }
    
    func generateHao(resume: String) async throws -> HaoResponse {
        let prompt = "基于以下简历内容，请生成一个富有文化内涵的号，要求：1. 反映个人特点 2. 符合传统文化 3. 意境优美。简历内容：\(resume)。请按照以下格式返回：号：xxx；解释：xxx"
        let result = try await makeRequest(prompt: prompt)
        return try parseResponse(result, type: HaoResponse.self)
    }
    
    private func parseResponse<T: Codable>(_ response: String, type: T.Type) throws -> T {
        let components = response.components(separatedBy: "；")
        guard components.count >= 2,
              let nameComponent = components.first,
              let explanationComponent = components.last else {
            throw LLMError.invalidResponse
        }
        
        let jsonString = """
        {
            "\(type == NameResponse.self ? "generated_name" : type == ZiResponse.self ? "generated_zi" : "generated_hao")": "\(nameComponent.components(separatedBy: "：").last ?? "")",
            "\(type == NameResponse.self ? "name_explanation" : type == ZiResponse.self ? "zi_explanation" : "hao_explanation")": "\(explanationComponent.components(separatedBy: "：").last ?? "")"
        }
        """
        
        return try JSONDecoder().decode(type, from: jsonString.data(using: .utf8)!)
    }
}

// 支持结构体
private struct ChatRequest: Codable {
    let messages: [Message]
    let temperature: Float
    let top_p: Float
    
    init(messages: [Message]) {
        self.messages = messages
        self.temperature = 0.7
        self.top_p = 0.8
    }
}

private struct Message: Codable {
    let role: String
    let content: String
}

private struct ChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let result: String
    let is_truncated: Bool
    let need_clear_history: Bool
    let usage: Usage
}

private struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

private struct TokenResponse: Codable {
    let access_token: String
    let expires_in: TimeInterval
}

enum LLMError: Error {
    case invalidURL
    case invalidResponse
}