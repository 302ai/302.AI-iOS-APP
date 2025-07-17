import SwiftUI
//import iosmath

struct MathTextView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
//            ForEach(parseContent(content), id: \.self) { component in
//                if component.isLatex {
//                    MathFormulaView(formula: component.text)
//                        .frame(minHeight: component.text.contains("\\frac") ? 50 : 30)
//                        .padding(.vertical, 5)
//                } else {
//                    Text(component.text)
//                        .font(.body)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//            }
        }
    }
    
//    private func parseContent(_ text: String) -> [TextComponent] {
//        let pattern = "\\\\\\[.*?\\\\\\]|\\\\\\(.*?\\\\\\)"
//        guard let regex = try? NSRegularExpression(pattern: pattern) else {
//            return [TextComponent(text: text, isLatex: false)]
//        }
//        
//        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
//        var components: [TextComponent] = []
//        var lastIndex = text.startIndex
//        
//        for match in matches {
//            let range = match.range
//            if let swiftRange = Range(range, in: text) {
//                // Add preceding non-LaTeX text
//                let precedingText = String(text[lastIndex..<swiftRange.lowerBound])
//                if !precedingText.isEmpty {
//                    components.append(TextComponent(text: precedingText, isLatex: false))
//                }
//                
//                // Add LaTeX text (remove the \[ \] or \( \) markers)
//                let latexStart = text.index(swiftRange.lowerBound, offsetBy: 2)
//                let latexEnd = text.index(swiftRange.upperBound, offsetBy: -2)
//                let latexText = String(text[latexStart..<latexEnd])
//                components.append(TextComponent(text: latexText, isLatex: true))
//                
//                lastIndex = swiftRange.upperBound
//            }
//        }
//        
//        // Add remaining non-LaTeX text
//        let remainingText = String(text[lastIndex...])
//        if !remainingText.isEmpty {
//            components.append(TextComponent(text: remainingText, isLatex: false))
//        }
//        
//        return components
//    }
//}
//
//struct TextComponent: Hashable {
//    let text: String
//    let isLatex: Bool
//}
//
//struct MathFormulaView: UIViewRepresentable {
//    let formula: String
//    
//    func makeUIView(context: Context) -> MTMathUILabel {
//        let label = MTMathUILabel()
//        label.latex = formula
//        label.textAlignment = .left
//        label.fontSize = 16
//        label.contentInsets = .zero
//        return label
//    }
//    
//    func updateUIView(_ uiView: MTMathUILabel, context: Context) {
//        uiView.latex = formula
//    }
}
