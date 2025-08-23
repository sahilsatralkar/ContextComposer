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