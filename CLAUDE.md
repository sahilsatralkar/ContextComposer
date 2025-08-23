# Context Composer - Project Instructions

## Project Overview
Context Composer is an iOS 26+ productivity app that uses Apple's Foundation Models framework for on-device AI text processing. It generates contextually appropriate response variations for different professional scenarios with complete privacy and no network dependency.

## Technical Stack & Requirements

### Core Technologies
- **Platform**: iOS 26+ only
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI with Liquid Glass design system
- **AI Framework**: Foundation Models (iOS 26)
- **Architecture**: MVVM pattern
- **Minimum Hardware**: iPhone 15 Pro, iPad M1+ (Apple Intelligence required)
- **Development**: Xcode 26 Beta 5+

### Required Frameworks
```swift
import SwiftUI
import FoundationModels  // Core AI framework - iOS 26 only
import Combine
import Foundation
import CoreData         // For local storage
```

### Key Framework Features to Use
- **@Generable protocol**: For structured output from Foundation Models
- **Streaming responses**: AsyncStream for real-time text generation
- **Stateful sessions**: ModelSession for context retention
- **On-device processing**: Zero network calls for AI operations

## Project Structure
Follow this exact MVVM structure:
```
ContextComposer/
├── Models/
│   ├── ResponseVariation.swift  (@Generable structs)
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

### 2. Foundation Models Integration Pattern
Always use this pattern for AI processing:
```swift
@MainActor
class FoundationModelService: ObservableObject {
    private let model = FoundationModel.shared
    private var session: ModelSession?
    
    func initializeSession() async throws {
        session = try await model.createSession(
            configuration: .init(
                maxTokens: 4096,
                temperature: 0.7,
                topP: 0.9
            )
        )
    }
    
    func generateVariations(input: String, context: CommunicationContext) async throws -> [ResponseVariation] {
        return try await model.generate(
            prompt: constructPrompt(input, context),
            schema: ResponseVariation.self,
            streaming: true,
            session: session
        )
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

### 4. UI/UX Guidelines
- **Design System**: Use iOS 26 Liquid Glass materials
- **Accessibility**: Full VoiceOver and Dynamic Type support
- **Dark Mode**: Complete light/dark mode support
- **Privacy Emphasis**: Prominent on-device processing indicators
- **Response Cards**: Swipeable cards with tone indicators and copy actions

## Testing Requirements

### Essential Test Cases
1. **Airplane Mode Demo**: App must work completely offline
2. **Structured Output**: Validate @Generable schema parsing
3. **Streaming**: Test AsyncStream UI updates
4. **Memory**: Monitor peak usage stays under 150MB
5. **Performance**: Verify generation times meet targets

### Test Commands
Run these commands before any commits:
```bash
# No specific test commands defined yet - check for:
# - xcodebuild test (if tests exist)
# - Swift Package Manager tests
# - Performance profiling with Instruments
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
- **Physical Device Testing**: Foundation Models unavailable in Simulator
- **Apple Intelligence**: Must be enabled in device settings
- **Weekend Project**: Target 8-12 hours total development time

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
- **Primary Doc**: Deep dive into Foundation Models - WWDC25
- **Code Tutorial**: Bring on-device AI to your app - WWDC25
- **Apple Intelligence**: https://www.apple.com/apple-intelligence/
- **iOS 26 Beta**: Requires developer account access