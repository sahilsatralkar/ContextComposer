# Context Composer - iOS 26 App Design Document

## Project Overview

**App Name:** Context Composer  
**Platform:** iOS 26+  
**Target Devices:** iPhone 15 Pro and later (Apple Intelligence required)  
**Development Framework:** SwiftUI + Foundation Models Framework  
**Estimated Development Time:** 8-12 hours (weekend project)  
**Purpose:** Demonstrate iOS 26's Foundation Models framework capabilities for on-device AI text processing

## Core Technologies & Documentation

### Foundation Models Framework
- **Primary Documentation:** [Deep dive into Foundation Models - WWDC25](https://developer.apple.com/videos/play/wwdc2025/301/)
- **Code-along Tutorial:** [Bring on-device AI to your app - WWDC25](https://developer.apple.com/videos/play/wwdc2025/259/)
- **Framework Overview:** [ML & AI Frameworks on Apple Platforms](https://developer.apple.com/videos/play/wwdc2025/360/)
- **Technical Paper:** [Apple's On-Device Foundation Language Models](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates)

### Supporting Frameworks
- **SpeechAnalyzer API:** [Advanced speech-to-text - WWDC25](https://developer.apple.com/videos/play/wwdc2025/277/)
- **iOS 26 Features Guide:** [What's new in iOS](https://developer.apple.com/wwdc25/guides/ios/)
- **Apple Intelligence Overview:** [Apple Intelligence Documentation](https://www.apple.com/apple-intelligence/)

## Technical Requirements

### Hardware Requirements
- iPhone 15 Pro, iPhone 15 Pro Max, or iPhone 16 series
- iPadOS 26 on M1 iPad or later
- macOS 15 on Apple Silicon Mac (for development)

### Software Requirements
- Xcode 26 Beta 5 or later
- iOS 26 Beta 7 (23A5326a) or later
- Swift 6.0

### Framework Dependencies
```swift
import SwiftUI
import FoundationModels  // Core AI framework
import Combine
import Foundation
```

## App Architecture

### MVVM Structure
```
ContextComposer/
├── Models/
│   ├── ResponseVariation.swift
│   ├── CommunicationContext.swift
│   └── ToneAnalysis.swift
├── ViewModels/
│   ├── ComposerViewModel.swift
│   └── ResponseGeneratorService.swift
├── Views/
│   ├── ContentView.swift
│   ├── InputSection.swift
│   ├── ResponseCard.swift
│   └── ContextSelector.swift
├── Services/
│   ├── FoundationModelService.swift
│   └── StreamingHandler.swift
└── Resources/
    └── Info.plist
```

## Core Features Implementation

### 1. Foundation Models Integration

```swift
// FoundationModelService.swift
import FoundationModels

@MainActor
class FoundationModelService: ObservableObject {
    private let model = FoundationModel.shared
    private var session: ModelSession?
    
    // Initialize stateful session for context retention
    func initializeSession() async throws {
        session = try await model.createSession(
            configuration: .init(
                maxTokens: 4096,
                temperature: 0.7,
                topP: 0.9
            )
        )
    }
    
    // Generate responses using guided generation with @Generable
    func generateVariations(
        input: String,
        context: CommunicationContext
    ) async throws -> [ResponseVariation] {
        let prompt = constructPrompt(input, context)
        
        return try await model.generate(
            prompt: prompt,
            schema: ResponseVariation.self,
            streaming: true,
            session: session
        )
    }
}
```

### 2. Data Models with @Generable

```swift
// ResponseVariation.swift
import FoundationModels

@Generable
struct ResponseVariation: Identifiable {
    let id = UUID()
    let tone: ToneType
    let audience: AudienceType
    let formalityScore: Int // 1-10
    let responseText: String
    let keyPointsPreserved: [String]
    let wordCount: Int
    let estimatedReadingTime: Int // seconds
}

@Generable
enum ToneType: String, CaseIterable {
    case formal = "Formal"
    case casual = "Casual"
    case empathetic = "Empathetic"
    case direct = "Direct"
    case diplomatic = "Diplomatic"
}

@Generable
enum AudienceType: String, CaseIterable {
    case executive = "Executive"
    case peer = "Peer"
    case client = "Client"
    case team = "Team"
    case public = "Public"
}
```

### 3. Streaming Response Handler

```swift
// StreamingHandler.swift
import FoundationModels
import Combine

class StreamingHandler: ObservableObject {
    @Published var streamedText: String = ""
    @Published var isStreaming: Bool = false
    
    func handleStream(_ stream: AsyncStream<String>) async {
        await MainActor.run {
            self.isStreaming = true
            self.streamedText = ""
        }
        
        for await chunk in stream {
            await MainActor.run {
                self.streamedText += chunk
            }
        }
        
        await MainActor.run {
            self.isStreaming = false
        }
    }
}
```

## User Interface Specifications

### Main Screen Layout

```swift
// ContentView.swift
struct ContentView: View {
    @StateObject private var viewModel = ComposerViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Input Section
                    InputSection(text: $viewModel.inputText)
                        .frame(minHeight: 150)
                    
                    // Context Selector
                    ContextSelector(
                        selectedAudience: $viewModel.selectedAudience,
                        selectedTone: $viewModel.selectedTone
                    )
                    
                    // Generate Button with Privacy Indicator
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Process On-Device")
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(action: viewModel.generateResponses) {
                            Label("Generate", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isProcessing)
                    }
                    .padding(.horizontal)
                    
                    // Response Cards
                    if viewModel.isProcessing {
                        StreamingView(handler: viewModel.streamingHandler)
                    } else {
                        ResponseCardsSection(responses: viewModel.responses)
                    }
                }
                .padding()
            }
            .navigationTitle("Context Composer")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear All", action: viewModel.clearAll)
                        Button("Export Responses", action: viewModel.exportResponses)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}
```

### Response Card Component

```swift
// ResponseCard.swift
struct ResponseCard: View {
    let response: ResponseVariation
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label(response.tone.rawValue, systemImage: toneIcon)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(toneColor.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Text("\(response.wordCount) words")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Response Text
            Text(response.responseText)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            // Key Points
            if !response.keyPointsPreserved.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Points Preserved:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(response.keyPointsPreserved, id: \.self) { point in
                        Label(point, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 8)
            }
            
            // Actions
            HStack {
                Button(action: copyToClipboard) {
                    Label(isCopied ? "Copied!" : "Copy", 
                          systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Button(action: refineResponse) {
                    Label("Refine", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                FormalityIndicator(score: response.formalityScore)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

## Prompting Strategy for Foundation Models

### Prompt Construction Template

```swift
func constructPrompt(_ input: String, _ context: CommunicationContext) -> String {
    """
    Task: Generate a professional response variation for the following message.
    
    Original Message:
    \(input)
    
    Target Audience: \(context.audience.rawValue)
    Desired Tone: \(context.tone.rawValue)
    
    Requirements:
    1. Preserve all key information from the original message
    2. Adjust formality level appropriately for the audience
    3. Maintain professional clarity
    4. Keep response concise but complete
    5. Return structured data matching the ResponseVariation schema
    
    Generate a response that would be appropriate for \(context.audience.rawValue) 
    communication with a \(context.tone.rawValue) tone.
    """
}
```

## Privacy & Performance Features

### On-Device Processing Indicator

```swift
struct PrivacyIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.shield.fill")
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), 
                          value: isAnimating)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("100% On-Device")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("No data leaves your iPhone")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .onAppear { isAnimating = true }
    }
}
```

### Airplane Mode Demo Function

```swift
func demonstrateOfflineCapability() {
    // Check network status
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    monitor.start(queue: queue)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied {
            // Show alert suggesting airplane mode
            showAirplaneModePrompt()
        } else {
            // Highlight that processing continues without network
            highlightOfflineProcessing()
        }
    }
}
```

## Testing Guidelines

### Unit Tests

```swift
// ResponseGeneratorTests.swift
import XCTest
@testable import ContextComposer

class ResponseGeneratorTests: XCTestCase {
    func testPromptConstruction() async throws {
        let service = FoundationModelService()
        let context = CommunicationContext(
            audience: .executive,
            tone: .formal
        )
        
        let prompt = service.constructPrompt("Test input", context)
        XCTAssertTrue(prompt.contains("executive"))
        XCTAssertTrue(prompt.contains("formal"))
    }
    
    func testResponseGeneration() async throws {
        let service = FoundationModelService()
        await service.initializeSession()
        
        let responses = try await service.generateVariations(
            input: "I need to reschedule our meeting",
            context: .init(audience: .client, tone: .diplomatic)
        )
        
        XCTAssertFalse(responses.isEmpty)
        XCTAssertEqual(responses.first?.audience, .client)
    }
}
```

### Demo Scenarios

1. **Executive Summary Generation**
   - Input: Long technical explanation
   - Context: Executive audience, Direct tone
   - Expected: Concise, high-level summary

2. **Client Apology**
   - Input: Service disruption notification
   - Context: Client audience, Empathetic tone
   - Expected: Professional, understanding response

3. **Team Motivation**
   - Input: Project deadline extension request
   - Context: Team audience, Casual tone
   - Expected: Supportive, collaborative message

## Performance Optimization

### Memory Management
- Model loads on-demand, not at app launch
- Session cleanup in `onDisappear`
- Responses limited to 5 variations to prevent memory issues

### Battery Optimization
- Use low-power mode detection
- Reduce generation temperature for faster processing
- Implement response caching for identical inputs

## Deployment Checklist

- [ ] Test on physical iPhone 15 Pro or later
- [ ] Verify Foundation Models framework availability
- [ ] Add privacy usage descriptions to Info.plist
- [ ] Enable Apple Intelligence capability in Xcode
- [ ] Test with airplane mode enabled
- [ ] Verify streaming UI updates smoothly
- [ ] Test session state persistence
- [ ] Validate structured output parsing
- [ ] Test with various text lengths (10-1000 words)
- [ ] Verify memory usage stays under 200MB

## Known Limitations

1. **Context Window**: 4,096 tokens maximum
2. **Device Support**: Limited to Apple Intelligence-enabled devices
3. **Language Support**: Currently 9 languages (expanding to 17)
4. **Model Size**: ~3B parameters (optimized for specific tasks)
5. **No Chat History**: Model optimized for single-turn tasks

## Future Enhancements

1. **Integration with SpeechAnalyzer**: Voice input for messages
2. **Visual Intelligence**: Screenshot analysis for context
3. **App Intents**: Shortcuts for quick response generation
4. **Widget Support**: Quick access from home screen
5. **Share Extension**: Generate responses from any app

## Resources & References

- [Apple Developer Forums - Foundation Models](https://developer.apple.com/forums/)
- [iOS 26 Beta Release Notes](https://developer.apple.com/news/releases/?id=08182025a)
- [WWDC 2025 Sessions](https://developer.apple.com/wwdc25/)
- [Apple Machine Learning Research](https://machinelearning.apple.com/)
- [Private Cloud Compute Documentation](https://security.apple.com/blog/private-cloud-compute/)

## Support & Feedback

For implementation questions, refer to:
- Apple Developer Documentation: https://developer.apple.com
- Anthropic Claude Code Documentation: https://docs.anthropic.com/en/docs/claude-code
- iOS 26 Support: https://support.anthropic.com

---

*Document Version: 1.0*  
*Last Updated: August 23, 2025*  
*Target iOS Version: 26.0 (23A5326a)*