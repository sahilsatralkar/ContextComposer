import Foundation
import FoundationModels

@Generable
enum ToneType: String, CaseIterable {
    case formal, casual, empathetic, direct, diplomatic
}

@Generable
enum AudienceType: String, CaseIterable {
    case executive, peer, client, team, `public`
}