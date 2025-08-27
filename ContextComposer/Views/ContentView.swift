//
//  ContentView.swift
//  ContextComposer
//
//  Created by Sahil Satralkar on 24/08/25.
//
//  Copyright 2025 Sahil Satralkar
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI


struct ContentView: View {
    @State private var aiService = AIService()
    @State private var inputText = ""
    @State private var selectedTone = ToneType.formal
    @FocusState private var isInputFocused: Bool
    
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
                        .focused($isInputFocused)
                    Text("\(inputText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Tone Selector
                Picker("Tone", selection: $selectedTone) {
                    ForEach(ToneType.allCases, id: \.self) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .pickerStyle(.menu)
                
                // Generate Button with Privacy Badge
                HStack {
                    Label("On-Device", systemImage: "lock.shield.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {
                        isInputFocused = false
                        Task {
                            let context = CommunicationContext(
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
                .scrollDismissesKeyboard(.interactively)
                
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
