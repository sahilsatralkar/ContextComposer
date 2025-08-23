import Foundation
import FoundationModels

@Generable
struct ResponseVariation: Identifiable {
    let id = UUID()
    let tone: ToneType
    let audience: AudienceType
    let responseText: String
    let formalityScore: Int
    let wordCount: Int
}