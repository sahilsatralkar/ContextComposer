import Foundation
import FoundationModels

@Generable
struct ResponseVariation: Identifiable {
    let id = UUID()
    let tone: ToneType
    let responseText: String
    let formalityScore: Int
    let wordCount: Int
}