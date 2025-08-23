import SwiftUI
import Observation
import FoundationModels

@Observable
@MainActor
final class AIService {
    var isProcessing = false
    var streamedText = ""
    var responses: [ResponseVariation] = []
    var errorMessage: String?
    
    private var model: SystemLanguageModel?
    private var session: LanguageModelSession?
    
    func initializeModel() async {
        // Initialize the system language model
        model = SystemLanguageModel.default
        
        // Check model availability
        switch model?.availability {
        case .available:
            // Create a session for interaction
            let instructions = Instructions("You are a helpful assistant that generates contextually appropriate responses for different audiences and tones.")
            session = LanguageModelSession(
                model: model!,
                tools: [],
                instructions: instructions
            )
        case .unavailable(let reason):
            errorMessage = "Model unavailable: \(reason)"
        case .none:
            errorMessage = "Failed to initialize model"
        }
    }
    
    private func constructPrompt(_ input: String, _ context: CommunicationContext) -> String {
        """
        Generate a \(context.tone.rawValue) response for \(context.audience.rawValue) audience.
        Original message: \(input)
        Requirements:
        - Match the tone: \(context.tone.rawValue)
        - Appropriate for: \(context.audience.rawValue)
        - Preserve key information
        - Professional and clear
        """
    }
    
    func generateResponse(input: String, context: CommunicationContext) async {
        isProcessing = true
        errorMessage = nil
        responses = []
        
        guard let session = session else {
            errorMessage = "Session not initialized"
            isProcessing = false
            return
        }
        
        do {
            let promptText = constructPrompt(input, context)
            
            // Generate text response using the session
            let response = try await session.respond(to: promptText)
            
            // Extract the text content from the response
            let responseText = response.content
            
            // Create ResponseVariation with the generated text
            let responseVariation = ResponseVariation(
                tone: context.tone,
                audience: context.audience,
                responseText: responseText,
                formalityScore: 7,
                wordCount: responseText.split(separator: " ").count
            )
            
            responses = [responseVariation]
        } catch {
            errorMessage = "Generation failed: \(error.localizedDescription)"
        }
        
        isProcessing = false
    }
}