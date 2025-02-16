import Foundation

struct ZiResponse: Codable {
    let zi: String
    let explanation: String
    
    enum CodingKeys: String, CodingKey {
        case zi = "generated_zi"
        case explanation = "zi_explanation"
    }
}