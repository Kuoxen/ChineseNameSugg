import Foundation

struct NameResponse: Codable, Identifiable {
    let id = UUID()
    let name: String
    let explanation: String
}