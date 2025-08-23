# Apple Foundation Models Framework API Reference

A comprehensive guide to Apple's Foundation Models framework for AI tool integration.

## Framework Overview

**Foundation Models** is Apple's on-device large language model framework that powers Apple Intelligence. It provides access to text generation, structured output, and tool calling capabilities.

**Platform Availability:**
- iOS 26.0+ (Beta)
- iPadOS 26.0+ (Beta)
- Mac Catalyst 26.0+ (Beta)
- macOS 26.0+ (Beta)
- visionOS 26.0+ (Beta)

**Requirements:**
- Device must support Apple Intelligence
- Apple Intelligence must be enabled in Settings
- Beta software (subject to change)

## Core Classes and Structures

### SystemLanguageModel

The main entry point for accessing Apple's on-device language model.

```swift
final class SystemLanguageModel
```

**Key Properties:**
- `static let default: SystemLanguageModel` - Base version of the model
- `var isAvailable: Bool` - Convenience check for model readiness
- `var availability: SystemLanguageModel.Availability` - Detailed availability status
- `var supportedLanguages: Set<Locale.Language>` - Supported languages

**Initialization:**
```swift
// Default model
let model = SystemLanguageModel.default

// With specific use case
convenience init(useCase: SystemLanguageModel.UseCase, guardrails: SystemLanguageModel.Guardrails)

// With custom adapter
convenience init(adapter: SystemLanguageModel.Adapter, guardrails: SystemLanguageModel.Guardrails)
```

**Methods:**
- `func supportsLocale(Locale) -> Bool` - Check locale support

**Nested Types:**
- `UseCase` - Represents use cases for prompting
- `Availability` - Availability status enumeration
- `Guardrails` - Content safety guardrails
- `Adapter` - Custom model specialization

### SystemLanguageModel.UseCase

Defines specific use cases for the language model.

```swift
struct UseCase
```

**Static Properties:**
- `static let general: SystemLanguageModel.UseCase` - General purpose prompting
- `static let contentTagging: SystemLanguageModel.UseCase` - Content categorization and tagging

### SystemLanguageModel.Availability

Enumeration representing model availability status.

**Cases:**
- `.available` - Model is ready for use
- `.unavailable(.deviceNotEligible)` - Device doesn't support Apple Intelligence
- `.unavailable(.appleIntelligenceNotEnabled)` - Apple Intelligence is disabled
- `.unavailable(.modelNotReady)` - Model is downloading or not ready
- `.unavailable(let other)` - Unknown unavailability reason

## Session Management

### LanguageModelSession

Main class for interacting with the language model, maintaining conversation state.

```swift
final class LanguageModelSession
```

**Initialization:**
```swift
// With instructions
convenience init(model: SystemLanguageModel, tools: [any Tool], instructions: Instructions)

// From existing transcript
convenience init(model: SystemLanguageModel, tools: [any Tool], transcript: Transcript)
```

**Key Properties:**
- `var isResponding: Bool` - Indicates if response is being generated
- `var transcript: Transcript` - Full conversation history

**Response Generation:**
```swift
// Basic response
func respond(to: String, options: GenerationOptions) async throws -> LanguageModelSession.Response

// With custom prompt builder
func respond(options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response

// Structured generation
func respond<Content: Generable>(generating: Content.Type, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.Response<Content>

// Schema-based generation
func respond(schema: GenerationSchema, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) async throws -> LanguageModelSession.ResponseContent
```

**Streaming Responses:**
```swift
// Stream basic response
func streamResponse(to: String, options: GenerationOptions) -> sending LanguageModelSession.ResponseStream

// Stream structured response
func streamResponse<Content: Generable>(generating: Content.Type, includeSchemaInPrompt: Bool, options: GenerationOptions, prompt: () throws -> Prompt) rethrows -> sending LanguageModelSession.ResponseStream<Content>
```

**Utility Methods:**
- `func prewarm(promptPrefix: Prompt?)` - Preload model resources
- `func logFeedbackAttachment(sentiment: LanguageModelFeedback.Sentiment?, issues: [LanguageModelFeedback.Issue], desiredOutput: Transcript.Entry?) -> Data`

**Nested Types:**
- `Response` - Response container structure
- `ResponseStream` - Async sequence for streaming responses
- `GenerationError` - Error enumeration for generation failures
- `ToolCallError` - Tool-specific error structure

## Prompting System

### Instructions

Defines model behavior and role for a session.

```swift
struct Instructions
```

**Initialization:**
```swift
init(_ content: String)
```

**Usage Example:**
```swift
let instructions = """
You are a motivational workout coach that provides quotes to inspire 
and motivate athletes.
"""
let session = LanguageModelSession(instructions: instructions)
```

**Related Types:**
- `InstructionsBuilder` - Dynamic instruction building
- `InstructionsRepresentable` - Protocol for instruction types

### Prompt

Represents user input to the model.

```swift
struct Prompt
```

**Initialization:**
```swift
init(_ content: String)
```

**Usage with Builder:**
```swift
let prompt = Prompt {
    "Generate a motivational quote"
    if includeContext {
        "for my next workout."
    }
}
```

**Related Types:**
- `PromptBuilder` - Dynamic prompt construction
- `PromptRepresentable` - Protocol for prompt types

### Transcript

Documents complete conversation history.

```swift
struct Transcript
```

**Initialization:**
```swift
init(entries: some Sequence<Transcript.Entry>)
```

**Nested Types:**
- `Entry` - Individual conversation entry
- `Segment` - Content segment types
- `Instructions` - Instruction entries
- `Prompt` - User prompt entries
- `Response` - Model response entries
- `ResponseFormat` - Response format specifications
- `StructuredSegment` - Structured content segments
- `TextSegment` - Text content segments
- `ToolCall` - Tool invocation records
- `ToolCalls` - Tool call collections
- `ToolDefinition` - Tool definitions
- `ToolOutput` - Tool execution results

### GenerationOptions

Controls response generation behavior.

```swift
struct GenerationOptions
```

## Guided Generation

### Generable Protocol

Enables structured data generation from the model.

```swift
protocol Generable : ConvertibleFromGeneratedContent, ConvertibleToGeneratedContent
```

**Required Properties:**
- `static var generationSchema: GenerationSchema` - Type schema definition

**Key Features:**
- Use `@Generable` macro to conform types
- Use `@Guide` macro for property descriptions
- Strong type guarantees for generated content

**Usage Example:**
```swift
@Generable
struct ContactInfo {
    @Guide(description: "Person's first name")
    let firstName: String
    
    @Guide(description: "Person's last name") 
    let lastName: String
    
    @Guide(description: "Valid email address")
    let email: String
}

let response = try await session.respond(generating: ContactInfo.self, to: "Generate contact info for John Smith")
```

**Associated Types:**
- `PartiallyGenerated` - Partially generated content representation
- `GenerationID` - Unique identifier for generation
- `GenerationSchema` - Schema definition structure
- `DynamicGenerationSchema` - Runtime schema construction
- `GenerationGuide` - Value generation guides

**Macros:**
- `@Generable(description: String?)` - Makes type generable
- `@Guide(description: String)` - Provides property guidance
- `@Guide(description: String, _: GenerationGuide)` - Advanced property guidance

## Tool Calling

### Tool Protocol

Enables model to call custom functions for specialized tasks.

```swift
protocol Tool<Arguments, Output> : Sendable
```

**Required Properties:**
- `var name: String` - Unique tool identifier
- `var description: String` - Natural language description
- `var parameters: GenerationSchema` - Parameter schema
- `var includesSchemaInInstructions: Bool` - Schema injection flag (default implementation provided)

**Required Associated Types:**
- `Arguments: ConvertibleFromGeneratedContent` - Tool input type
- `Output: PromptRepresentable` - Tool output type

**Required Methods:**
- `func call(arguments: Arguments) async throws -> Output` - Tool execution

**Usage Example:**
```swift
struct FindContacts: Tool {
    let name = "findContacts"
    let description = "Find a specific number of contacts"
    
    @Generable
    struct Arguments {
        @Guide(description: "The number of contacts to get", .range(1...10))
        let count: Int
    }
    
    func call(arguments: Arguments) async throws -> [String] {
        var contacts: [CNContact] = []
        // Fetch contacts using arguments.count
        let formattedContacts = contacts.map { "\($0.givenName) \($0.familyName)" }
        return formattedContacts
    }
}
```

## Content Conversion Protocols

### ConvertibleFromGeneratedContent

Types that can be initialized from model-generated content.

```swift
protocol ConvertibleFromGeneratedContent
```

### ConvertibleToGeneratedContent  

Types that can be converted to model-understandable content.

```swift
protocol ConvertibleToGeneratedContent
```

### PromptRepresentable

Types that can be represented as prompts.

```swift
protocol PromptRepresentable
```

## Generated Content Types

### GeneratedContent

Represents structured content generated by the model.

```swift
struct GeneratedContent
```

**Conforms to:** `Generable`

## Error Handling

### LanguageModelSession.GenerationError

Errors that occur during response generation.

**Common Cases:**
- `.exceededContextWindowSize(_:)` - Context window overflow

### LanguageModelSession.ToolCallError

Errors specific to tool execution.

```swift
struct ToolCallError
```

## Feedback and Logging

### LanguageModelFeedback

Structure for providing feedback to Apple about model performance.

```swift
struct LanguageModelFeedback
```

**Nested Types:**
- `Sentiment` - Feedback sentiment enumeration
- `Issue` - Issue type enumeration

## Adapters and Customization

### SystemLanguageModel.Adapter

Enables custom model specialization through trained adapters.

```swift
struct Adapter
```

**Entitlement Required:**
- `com.apple.developer.foundation-model-adapter` - Boolean value for adapter support

### SystemLanguageModel.Guardrails

Content safety and filtering mechanisms.

```swift
struct Guardrails
```

## Builder Types

### InstructionsBuilder

Dynamic instruction construction.

```swift
struct InstructionsBuilder
```

### PromptBuilder

Dynamic prompt construction.

```swift
struct PromptBuilder
```

## Best Practices

1. **Model Availability**: Always check `SystemLanguageModel.availability` before use
2. **Instructions**: Provide clear, specific instructions to guide model behavior
3. **Tool Design**: Make tools focused and well-documented with clear descriptions
4. **Error Handling**: Handle `GenerationError.exceededContextWindowSize` appropriately
5. **Content Safety**: Use guardrails and validate user inputs
6. **Performance**: Use `prewarm()` for better response times
7. **Localization**: Check `supportedLanguages` and use `supportsLocale()` for internationalization

## Code Examples

### Basic Usage
```swift
// Check availability
let model = SystemLanguageModel.default
guard model.isAvailable else { return }

// Create session
let session = LanguageModelSession(
    model: model,
    tools: [],
    instructions: "You are a helpful assistant."
)

// Generate response
let response = try await session.respond(to: "Hello, world!")
print(response.content)
```

### Structured Generation
```swift
@Generable
struct Recipe {
    @Guide(description: "Recipe name")
    let name: String
    
    @Guide(description: "List of ingredients")
    let ingredients: [String]
    
    @Guide(description: "Cooking instructions")
    let instructions: String
}

let response = try await session.respond(
    generating: Recipe.self,
    to: "Create a recipe for chocolate chip cookies"
)
```

### Tool Integration
```swift
let weatherTool = WeatherTool()
let session = LanguageModelSession(
    model: model,
    tools: [weatherTool],
    instructions: "You can check weather using the weather tool."
)

let response = try await session.respond(to: "What's the weather like in San Francisco?")
```

## Notes

- This is **Beta software** - APIs may change before final release
- Requires Apple Intelligence-compatible devices
- Model responses are generated on-device for privacy
- All operations are asynchronous and may throw errors
- Framework designed with Sendable conformance for concurrent usage