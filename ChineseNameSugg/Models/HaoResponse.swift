import Foundation

struct HaoResponse: Codable {
    let hao: String
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case hao = "generated_hao"
        case explanation = "hao_explanation"
    }
}