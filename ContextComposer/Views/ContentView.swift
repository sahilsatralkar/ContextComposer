//
//  ContentView.swift
//  ContextComposer
//
//  Created by Sahil Satralkar on 24/08/25.
//

import SwiftUI


struct ContentView: View {
    @State private var aiService = AIService()
    @State private var inputText = ""
    @State private var selectedTone = ToneType.formal
    @State private var selectedAudience = AudienceType.peer
    
    var body: some View {
        NavigationStack {
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
                
                // Context Selectors
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
                
                // Generate Button with Privacy Badge
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
                
                // Loading State
                if aiService.isProcessing {
                    ProgressView("Generating...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                // Response Display
                ScrollView {
                    ForEach(aiService.responses) { response in
                        ResponseCard(response: response)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Context Composer")
        }
        .task {
            await aiService.initializeModel()
        }
        .alert("Error", isPresented: .constant(aiService.errorMessage != nil)) {
            Button("OK") {
                aiService.errorMessage = nil
            }
        } message: {
            if let error = aiService.errorMessage {
                Text(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
