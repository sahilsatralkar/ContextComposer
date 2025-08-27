//
//  ResponseCard.swift
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