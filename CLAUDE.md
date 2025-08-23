# Context Composer - Project Instructions

## Project Overview
Context Composer is an iOS 26+ productivity app that uses Apple's Foundation Models framework for on-device AI text processing. It generates contextually appropriate response variations for different professional scenarios with complete privacy and no network dependency.

## Technical Stack & Requirements

### Core Technologies
- **Platform**: iOS 26+ only
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI with Liquid Glass design system
- **AI Framework**: Foundation Models (iOS 26)
- **Architecture**: @Observable pattern with Swift 6 concurrency
- **Minimum Hardware**: iPhone 15 Pro, iPad M1+ (Apple Intelligence required)
- **Development**: Xcode 26 Beta 5+

### Required Frameworks
```swift
import SwiftUI
import FoundationModels  // Core AI framework - iOS 26 only
import Observation       // For @Observable macro
import Foundation
```

### Key Framework Features to Use
- **@Generable protocol**: For structured output from Foundation Models
- **Streaming responses**: AsyncStream for real-time text generation
- **Stateful sessions**: ModelSession for context retention
- **On-device processing**: Zero network calls for AI operations

## Project Structure
Follow this simplified single-screen structure:
```
ContextComposer/
├── Models/
│   ├── ResponseVariation.swift  (@Generable structs)
│   ├── ResponseTypes.swift      (ToneType, AudienceType)
│   └── CommunicationContext.swift
├── Services/
│   └── AIService.swift          (@Observable service)
├── Views/
│   ├── ContentView.swift        (Single main screen)
│   └── ResponseCard.swift
└── Resources/
```

## Critical Implementation Requirements

### 1. Data Models Must Use @Generable
All AI-generated data structures MUST use the @Generable protocol:
```swift
@Generable
struct ResponseVariation {
    let id: UUID
    let tone: ToneType
    let audience: AudienceType
    let responseText: String
    let formalityScore: Int
    let keyPointsPreserved: [String]
}

@Generable
enum ToneType: String, CaseIterable {
    case formal, casual, empathetic, direct, diplomatic
}
```

### 2. @Observable Service Pattern
Always use this pattern for AI processing:
```swift
@Observable
@MainActor
final class AIService {
    var isProcessing = false
    var responses: [ResponseVariation] = []
    var errorMessage: String?
    
    private var model: FoundationModel?
    private var session: ModelSession?
    
    func initializeModel() async {
        do {
            let config = FoundationModel.Configuration(
                maxTokens: 2048,
                temperature: 0.7,
                topP: 0.9,
                stream: true
            )
            model = try await FoundationModel.load(
                configuration: config,
                hardwareAcceleration: .neural
            )
            session = try await model?.createSession()
        } catch {
            errorMessage = "Failed to initialize: \(error.localizedDescription)"
        }
    }
    
    func generateResponse(input: String, context: CommunicationContext) async {
        // Direct API calls with error handling via alerts
    }
}
```

### 3. Privacy & Performance Requirements
- **100% On-Device**: Never make network calls for AI processing
- **Privacy Indicators**: Always show "🔒 100% On-Device" UI elements
- **Streaming UI**: Implement progressive response display with AsyncStream
- **Memory Management**: Model loads on-demand, cleanup in onDisappear
- **Performance Targets**: 
  - Generation start: < 200ms
  - Full response: < 3s
  - Memory usage: < 150MB

### 4. Single-Screen MVP Guidelines
- **Single Screen**: All functionality on ContentView (no navigation)
- **Direct API Usage**: No mocks - show error alerts if APIs fail
- **iPhone 16 Simulator**: Mandatory compilation check after each step
- **Git Commits**: Required after each successful compilation
- **Privacy Emphasis**: Prominent on-device processing indicators
- **Simple UI**: Input → Generate → Display → Copy workflow

## Testing Requirements

### Essential Test Cases
1. **Airplane Mode Demo**: App must work completely offline
2. **Structured Output**: Validate @Generable schema parsing
3. **Streaming**: Test AsyncStream UI updates
4. **Memory**: Monitor peak usage stays under 150MB
5. **Performance**: Verify generation times meet targets

### Compilation Protocol
Required after every step:
```bash
# 1. Build project: ⌘+B
# 2. Run on iPhone 16 Simulator: ⌘+R
# 3. Verify no compilation errors
# 4. Git commit if successful: git add -A && git commit -m "step message"
```

## Development Phases

### Phase 1: MVP (Current)
- Basic UI with SwiftUI
- Foundation Models integration
- Single response generation
- Copy/share functionality

### Phase 2: Enhanced Features
- Streaming response display
- Multiple tone variations
- Response history with CoreData
- Basic preferences

## Important Constraints & Limitations

### Technical Limitations
- **Context Window**: 4,096 tokens maximum
- **Device Support**: Only Apple Intelligence-enabled devices
- **Model Size**: ~3B parameters optimized for text tasks
- **Languages**: Currently 9 languages supported
- **No Chat History**: Optimized for single-turn tasks

### Development Constraints
- **iOS 26 Beta Required**: Cannot build on older Xcode versions
- **iPhone 16 Simulator**: Use for compilation checks (APIs may show errors)
- **Apple Intelligence**: Must be enabled in device settings for real testing
- **Step-by-Step**: Follow implementation-plan.md exactly - 20 steps total

## Code Style Requirements
- **No Comments**: Do not add code comments unless explicitly requested
- **Follow Existing Patterns**: Mimic established SwiftUI and iOS patterns
- **Security First**: Never log or expose user input text
- **Privacy By Design**: All processing must remain on-device

## Deployment Checklist
- [ ] Test on physical iPhone 15 Pro or later
- [ ] Verify Foundation Models framework availability
- [ ] Test with airplane mode enabled
- [ ] Validate memory usage under 150MB
- [ ] Test streaming UI responsiveness
- [ ] Verify structured output parsing works

## Resources
- **Foundation Models API**: https://developer.apple.com/documentation/FoundationModels
- **Implementation Plan**: implementation-plan.md (20 steps with tracking)
- **Apple Intelligence**: https://www.apple.com/apple-intelligence/
- **iOS 26 Beta**: Requires developer account access
- Build with Xcode version 26.0 beta 6 17A5305f. Its available in Downloads folder. Always run on iOS 26.0 simulator for iPhone 16.
- Refer @FoundationModel.md for Apple Foundation Models API reference documentation.