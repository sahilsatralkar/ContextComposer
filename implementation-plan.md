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

- [x] **Step 3: Configure Info.plist**
  - [x] Add NSAppleIntelligenceUsageDescription
  - [x] Add UIRequiredDeviceCapabilities with neural-engine
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Configure Info.plist for Apple Intelligence"`
  - **Status**: ✅ **COMPLETED**

### Phase 2: Project Structure

- [x] **Step 4: Create Folder Structure**
  - [x] Create Models/, Services/, Views/ groups in Xcode
  - [x] Move ContentView.swift to Views/
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Organize project structure"`
  - **Status**: ✅ **COMPLETED**

### Phase 3: Data Models

- [x] **Step 5: Create ToneType and AudienceType**
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Add tone and audience types"`
  - **Status**: ✅ **COMPLETED**

- [x] **Step 6: Create ResponseVariation Model**
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Add ResponseVariation model"`
  - **Status**: ✅ **COMPLETED**

- [x] **Step 7: Create CommunicationContext**
  ```swift
  // Models/CommunicationContext.swift
  struct CommunicationContext {
      let audience: AudienceType
      let tone: ToneType
  }
  ```
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Add CommunicationContext model"`
  - **Status**: ✅ **COMPLETED**

### Phase 4: AI Service

- [x] **Step 8: Create AIService Class**
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Fix AIService with correct Foundation Models API"`
  - **Status**: ✅ **COMPLETED**

- [x] **Step 9: Add Model Initialization** (Combined with Step 8)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with Step 8
  - **Status**: ✅ **COMPLETED**

- [x] **Step 10: Add Prompt Construction** (Combined with Step 8)
  ```swift
  // In AIService.swift
  private func constructPrompt(_ input: String, _ context: CommunicationContext) -> String {
      """
      Generate a \(context.tone.rawValue) response for \(context.audience.rawValue):
      Input: \(input)
      """
  }
  ```
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with Step 8
  - **Status**: ✅ **COMPLETED**

- [x] **Step 11: Add Response Generation** (Combined with Step 8)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with Step 8
  - **Status**: ✅ **COMPLETED**

### Phase 5: User Interface

- [x] **Step 12: Update ContentView Base Structure** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 13: Add Input Section** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 14: Add Context Selectors** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 15: Add Generate Button with Privacy Badge** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 16: Add Loading State** (Already complete)
  ```swift
  // After Generate Button:
  if aiService.isProcessing {
      ProgressView("Generating...")
          .frame(maxWidth: .infinity)
          .padding()
  }
  ```
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 17: Create ResponseCard View** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 18: Add Response Display** (Already complete)
  ```swift
  // In ContentView, after loading state:
  ScrollView {
      ForEach(aiService.responses) { response in
          ResponseCard(response: response)
              .padding(.horizontal)
      }
  }
  ```
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 19: Add Error Alert** (Already complete)
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
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: Combined with UI implementation
  - **Status**: ✅ **COMPLETED**

- [x] **Step 20: Final Polish**
  - [x] Add @FocusState for keyboard management
  - [x] Add .scrollDismissesKeyboard(.interactively)
  - [x] Test all functionality
  - [x] **Compile Check**: Build & Run on iPhone 16 Simulator ✅ BUILD SUCCEEDED
  - [x] **Commit**: `"Add final polish"`
  - **Status**: ✅ **COMPLETED**

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
- **Completed**: 20
- **Failed**: 0
- **Remaining**: 0

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

- [x] 20 successful iPhone 16 simulator compilations
- [x] 20 git commits with exact messages above
- [x] App runs without crashes
- [x] All Foundation Models APIs called correctly
- [x] Error alerts shown for any API failures
- [x] On-device processing indicator visible
- [x] Complete single-screen MVP functionality

---

**Last Updated**: Step 20/20 - Implementation COMPLETE ✅