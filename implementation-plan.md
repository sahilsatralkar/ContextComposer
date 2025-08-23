# Context Composer MVP Implementation Plan

## Prerequisites
- Xcode 26 Beta 5+
- iPhone 16 Simulator with iOS 26.0
- Git repository initialized

## Build & Test Protocol
After EVERY step:
1. Build: `⌘+B`
2. Run on iPhone 16 Simulator: `⌘+R`
3. Verify no compilation errors
4. If successful: `git add -A && git commit -m "message"`
5. If failed: Fix before proceeding

## Implementation Progress

### Phase 1: Project Configuration

- [x] **Step 1: Set iOS 26.0 Deployment Target**
  - [x] Open project settings
  - [x] Set iOS Deployment Target to 26.0 (already set)
  - [x] Set destination to iPhone 16 simulator
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Already configured, no commit needed
  - **Status**: ✅ **COMPLETED**

- [x] **Step 2: Add Foundation Models Framework**
  - [x] Add FoundationModels to Frameworks, Libraries (not needed - available in iOS 26 SDK)
  - [x] Import FoundationModels in ContextComposerApp.swift
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Add Foundation Models framework"`
  - **Status**: ✅ **COMPLETED**

- [ ] **Step 3: Configure Info.plist**
  - [ ] Add NSAppleIntelligenceUsageDescription
  - [ ] Add UIRequiredDeviceCapabilities with neural-engine
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Configure Info.plist for Apple Intelligence"`
  - **Status**: ❌ Not Started

### Phase 2: Project Structure

- [ ] **Step 4: Create Folder Structure**
  - [ ] Create Models/, Services/, Views/ groups in Xcode
  - [ ] Move ContentView.swift to Views/
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Organize project structure"`
  - **Status**: ❌ Not Started

### Phase 3: Data Models

- [ ] **Step 5: Create ToneType and AudienceType**
  ```swift
  // Models/ResponseTypes.swift
  import Foundation
  import FoundationModels

  @Generable
  enum ToneType: String, CaseIterable {
      case formal, casual, empathetic, direct, diplomatic
  }

  @Generable
  enum AudienceType: String, CaseIterable {
      case executive, peer, client, team, public
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add tone and audience types"`
  - **Status**: ❌ Not Started

- [ ] **Step 6: Create ResponseVariation Model**
  ```swift
  // Models/ResponseVariation.swift
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
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add ResponseVariation model"`
  - **Status**: ❌ Not Started

- [ ] **Step 7: Create CommunicationContext**
  ```swift
  // Models/CommunicationContext.swift
  struct CommunicationContext {
      let audience: AudienceType
      let tone: ToneType
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add CommunicationContext model"`
  - **Status**: ❌ Not Started

### Phase 4: AI Service

- [ ] **Step 8: Create AIService Class**
  ```swift
  // Services/AIService.swift
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
      
      private var model: FoundationModel?
      private var session: ModelSession?
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Create AIService with @Observable"`
  - **Status**: ❌ Not Started

- [ ] **Step 9: Add Model Initialization**
  ```swift
  // In AIService.swift
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
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add model initialization"`
  - **Status**: ❌ Not Started

- [ ] **Step 10: Add Prompt Construction**
  ```swift
  // In AIService.swift
  private func constructPrompt(_ input: String, _ context: CommunicationContext) -> String {
      """
      Generate a \(context.tone.rawValue) response for \(context.audience.rawValue):
      Input: \(input)
      """
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add prompt construction"`
  - **Status**: ❌ Not Started

- [ ] **Step 11: Add Response Generation**
  ```swift
  // In AIService.swift
  func generateResponse(input: String, context: CommunicationContext) async {
      isProcessing = true
      errorMessage = nil
      
      guard let model = model else {
          errorMessage = "Model not initialized"
          isProcessing = false
          return
      }
      
      do {
          let response = try await model.generate(
              prompt: constructPrompt(input, context),
              guidedBy: ResponseVariation.self,
              session: session
          )
          responses = [response]
      } catch {
          errorMessage = "Generation failed: \(error.localizedDescription)"
      }
      
      isProcessing = false
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add response generation"`
  - **Status**: ❌ Not Started

### Phase 5: User Interface

- [ ] **Step 12: Update ContentView Base Structure**
  ```swift
  // Views/ContentView.swift
  import SwiftUI

  struct ContentView: View {
      @State private var aiService = AIService()
      @State private var inputText = ""
      @State private var selectedTone = ToneType.formal
      @State private var selectedAudience = AudienceType.peer
      
      var body: some View {
          NavigationStack {
              VStack {
                  Text("Context Composer")
              }
              .navigationTitle("Context Composer")
          }
          .task {
              await aiService.initializeModel()
          }
      }
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Update ContentView structure"`
  - **Status**: ❌ Not Started

- [ ] **Step 13: Add Input Section**
  ```swift
  // In ContentView body, replace VStack content:
  VStack(spacing: 20) {
      // Input Section
      VStack(alignment: .leading, spacing: 8) {
          Text("Your Message")
              .font(.headline)
          TextEditor(text: $inputText)
              .frame(minHeight: 100)
              .overlay(RoundedRectangle(cornerRadius: 8)
                  .stroke(Color.gray.opacity(0.3)))
          Text("\(inputText.count) characters")
              .font(.caption)
              .foregroundColor(.secondary)
      }
      Spacer()
  }
  .padding()
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add input text section"`
  - **Status**: ❌ Not Started

- [ ] **Step 14: Add Context Selectors**
  ```swift
  // After Input Section in VStack:
  HStack(spacing: 16) {
      Picker("Tone", selection: $selectedTone) {
          ForEach(ToneType.allCases, id: \.self) { tone in
              Text(tone.rawValue).tag(tone)
          }
      }
      .pickerStyle(.menu)
      
      Picker("Audience", selection: $selectedAudience) {
          ForEach(AudienceType.allCases, id: \.self) { audience in
              Text(audience.rawValue).tag(audience)
          }
      }
      .pickerStyle(.menu)
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add tone and audience pickers"`
  - **Status**: ❌ Not Started

- [ ] **Step 15: Add Generate Button with Privacy Badge**
  ```swift
  // After Context Selectors:
  HStack {
      Label("On-Device", systemImage: "lock.shield.fill")
          .font(.caption)
          .foregroundColor(.green)
      
      Spacer()
      
      Button(action: {
          Task {
              let context = CommunicationContext(
                  audience: selectedAudience,
                  tone: selectedTone
              )
              await aiService.generateResponse(
                  input: inputText,
                  context: context
              )
          }
      }) {
          Label("Generate", systemImage: "wand.and.stars")
      }
      .buttonStyle(.borderedProminent)
      .disabled(inputText.isEmpty || aiService.isProcessing)
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add generate button with privacy badge"`
  - **Status**: ❌ Not Started

- [ ] **Step 16: Add Loading State**
  ```swift
  // After Generate Button:
  if aiService.isProcessing {
      ProgressView("Generating...")
          .frame(maxWidth: .infinity)
          .padding()
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add loading state"`
  - **Status**: ❌ Not Started

- [ ] **Step 17: Create ResponseCard View**
  ```swift
  // Views/ResponseCard.swift
  import SwiftUI

  struct ResponseCard: View {
      let response: ResponseVariation
      @State private var isCopied = false
      
      var body: some View {
          VStack(alignment: .leading, spacing: 12) {
              HStack {
                  Label(response.tone.rawValue, systemImage: "text.bubble")
                      .font(.caption)
                      .padding(4)
                      .background(Color.blue.opacity(0.1))
                      .cornerRadius(6)
                  
                  Spacer()
                  
                  Text("\(response.wordCount) words")
                      .font(.caption2)
                      .foregroundColor(.secondary)
              }
              
              Text(response.responseText)
                  .font(.body)
              
              Button(action: {
                  UIPasteboard.general.string = response.responseText
                  isCopied = true
                  Task {
                      try? await Task.sleep(for: .seconds(2))
                      isCopied = false
                  }
              }) {
                  Label(isCopied ? "Copied!" : "Copy",
                        systemImage: isCopied ? "checkmark" : "doc.on.doc")
                      .font(.caption)
              }
              .buttonStyle(.bordered)
          }
          .padding()
          .background(Color(.systemBackground))
          .cornerRadius(12)
          .shadow(radius: 1)
      }
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add ResponseCard view"`
  - **Status**: ❌ Not Started

- [ ] **Step 18: Add Response Display**
  ```swift
  // In ContentView, after loading state:
  ScrollView {
      ForEach(aiService.responses) { response in
          ResponseCard(response: response)
              .padding(.horizontal)
      }
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add response display"`
  - **Status**: ❌ Not Started

- [ ] **Step 19: Add Error Alert**
  ```swift
  // Add to NavigationStack modifiers:
  .alert("Error", isPresented: .constant(aiService.errorMessage != nil)) {
      Button("OK") {
          aiService.errorMessage = nil
      }
  } message: {
      if let error = aiService.errorMessage {
          Text(error)
      }
  }
  ```
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add error handling"`
  - **Status**: ❌ Not Started

- [ ] **Step 20: Final Polish**
  - [ ] Add @FocusState for keyboard management
  - [ ] Add .scrollDismissesKeyboard(.interactively)
  - [ ] Test all functionality
  - [ ] **Compile Check**: Build & Run on iPhone 16 Simulator
  - [ ] **Commit**: `"Add final polish"`
  - **Status**: ❌ Not Started

## Verification Protocol

### After Each Step:
1. **Build**: `⌘+B` - Must succeed
2. **Run**: `⌘+R` - Select iPhone 16 Simulator
3. **Check**: No red errors in Xcode
4. **Test**: App launches without crash
5. **Commit**: Only if all above pass

### If Compilation Fails:
- STOP immediately
- Fix the error
- Do not proceed until green build
- Then commit with fix message

## Progress Summary

- **Total Steps**: 20
- **Completed**: 0
- **Failed**: 0
- **Remaining**: 20

## Git Commits Expected

1. Set iOS 26.0 deployment target
2. Add Foundation Models framework
3. Configure Info.plist for Apple Intelligence
4. Organize project structure
5. Add tone and audience types
6. Add ResponseVariation model
7. Add CommunicationContext model
8. Create AIService with @Observable
9. Add model initialization
10. Add prompt construction
11. Add response generation
12. Update ContentView structure
13. Add input text section
14. Add tone and audience pickers
15. Add generate button with privacy badge
16. Add loading state
17. Add ResponseCard view
18. Add response display
19. Add error handling
20. Add final polish

## Success Criteria

- [ ] 20 successful iPhone 16 simulator compilations
- [ ] 20 git commits with exact messages above
- [ ] App runs without crashes
- [ ] All Foundation Models APIs called correctly
- [ ] Error alerts shown for any API failures
- [ ] On-device processing indicator visible
- [ ] Complete single-screen MVP functionality

---

**Last Updated**: Step 0/20 - Ready to begin implementation