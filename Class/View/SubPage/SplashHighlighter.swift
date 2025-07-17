//
//  SplashHighlighter.swift
//  Chat302AI
//
//  Created by Adswave on 2025/7/4.
//

import SwiftUI
import MarkdownUI
import Splash

struct TextOutputFormat: OutputFormat {
    private let theme: Splash.Theme

    init(theme: Splash.Theme) {
        self.theme = theme
    }

    func makeBuilder() -> Builder {
        Builder(theme: self.theme)
    }
}

extension TextOutputFormat {
    struct Builder: OutputBuilder {
        private let theme: Splash.Theme
        private var accumulatedText: [Text]

        fileprivate init(theme: Splash.Theme) {
            self.theme = theme
            self.accumulatedText = []
        }

        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = self.theme.tokenColors[type] ?? self.theme.plainTextColor
            self.accumulatedText.append(Text(token).foregroundColor(.init(uiColor: color)))
        }

        mutating func addPlainText(_ text: String) {
            self.accumulatedText.append(
                Text(text).foregroundColor(.init(uiColor: self.theme.plainTextColor))
            )
        }

        mutating func addWhitespace(_ whitespace: String) {
            self.accumulatedText.append(Text(whitespace))
        }

        func build() -> Text {
            self.accumulatedText.reduce(Text(""), +)
        }
    }
}

struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter {
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

    init(theme: Splash.Theme) {
        self.syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text {
        guard language != nil else {
            return Text(content)
        }
        return self.syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
    static func splash(theme: Splash.Theme) -> Self {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
}


extension Splash.Theme {
    /// 获取适合当前颜色方案的主题
    /// - Parameters:
    ///   - colorScheme: 当前颜色方案
    ///   - fontSize: 字体大小
    /// - Returns: 配置好的主题
    static func adaptiveTheme(for colorScheme: ColorScheme, fontSize: CGFloat = 16) -> Splash.Theme {
        switch colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: fontSize))
        default:
            return customLightTheme(fontSize: fontSize)
        }
    }
    
    /// 自定义浅色主题
    /// - Parameter fontSize: 字体大小
    /// - Returns: 配置好的主题
    private static func customLightTheme(fontSize: CGFloat) -> Splash.Theme {
        Splash.Theme(
            font: .init(size: fontSize),
            plainTextColor: UIColor(
                red: 0.1,
                green: 1,
                blue: 0.1,
                alpha: 1
            ),
            tokenColors: [
                .keyword: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                .string: UIColor(red: 1, green: 0, blue: 0, alpha: 1),
                .type: UIColor(red: 0, green: 1, blue: 0, alpha: 1),
                .call: UIColor(red: 1, green: 0, blue: 1, alpha: 1),
                .number: UIColor(red: 1, green: 0, blue: 0.6, alpha: 1),
                .comment: UIColor(red: 0, green: 1, blue: 1, alpha: 1),
                .property: UIColor(red: 0.6, green: 0.8, blue: 0, alpha: 1),
                .dotAccess: UIColor(red: 1, green: 0, blue: 0.6, alpha: 1),
                .preprocessing: UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1)
            ],
            backgroundColor: UIColor(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0.75
            )
        )
    }
}
