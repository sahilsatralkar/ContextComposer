import SwiftUI
import Observation
import FoundationModels
#if targetEnvironment(simulator)
import UIKit
#endif

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
        case .unavailable:
            errorMessage = getErrorMessage(for: model!.availability)
        case .none:
            errorMessage = "Failed to initialize Foundation Models. Please ensure Apple Intelligence is enabled in Settings."
        }
    }
    
    private func getErrorMessage(for availability: SystemLanguageModel.Availability) -> String {
        #if targetEnvironment(simulator)
        return "Foundation Models API is not available on the Simulator. Please test on a physical device with Apple Intelligence enabled."
        #else
        // The availability enum provides information about why the model is unavailable
        return "Foundation Models unavailable. Please ensure Apple Intelligence is enabled in Settings > Apple Intelligence & Siri and that your device supports it (iPhone 15 Pro or later)."
        #endif
    }
    
    private func constructPrompt(_ input: String, _ context: CommunicationContext) -> String {
        """
        Generate a \(context.tone.rawValue) response.
        Original message: \(input)
        Requirements:
        - Match the tone: \(context.tone.rawValue)
        - Preserve key information
        - Professional and clear
        """
    }
    
    func generateResponse(input: String, context: CommunicationContext) async {
        isProcessing = true
        errorMessage = nil
        responses = []
        
        guard let session = session else {
            #if targetEnvironment(simulator)
            errorMessage = "Foundation Models API is not available on the Simulator. Please test on a physical device with Apple Intelligence enabled."
            #else
            errorMessage = "Session not initialized. Please ensure Apple Intelligence is enabled in Settings."
            #endif
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
                responseText: responseText,
                formalityScore: 7,
                wordCount: responseText.split(separator: " ").count
            )
            
            responses = [responseVariation]
        } catch {
            #if targetEnvironment(simulator)
            errorMessage = "Foundation Models API is not available on the Simulator. Please test on a physical device with Apple Intelligence enabled."
            #else
            // Check if it's a specific generation error
            if let generationError = error as? LanguageModelSession.GenerationError {
                switch generationError {
                case .exceededContextWindowSize:
                    errorMessage = "Input text is too long. Please shorten your message and try again."
                default:
                    errorMessage = "Failed to generate response: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "Failed to generate response. Please try again."
            }
            #endif
        }
        
        isProcessing = false
    }
}