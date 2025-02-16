import Foundation
import PDFKit
import UIKit

class DocumentParser {
    static func extractText(from url: URL) throws -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return try extractFromPDF(url: url)
        case "txt":
            return try String(contentsOf: url, encoding: .utf8)
        case "doc", "docx":
            // TODO: 实现Word文档解析
            return ""
        default:
            throw ParseError.unsupportedFormat
        }
    }
    
    private static func extractFromPDF(url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw ParseError.invalidPDF
        }
        
        var text = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i) {
                text += page.string ?? ""
            }
        }
        return text
    }
    
    enum ParseError: Error {
        case unsupportedFormat
        case invalidPDF
    }
}