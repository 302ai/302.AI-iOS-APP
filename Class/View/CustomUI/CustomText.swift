//
//  CustomText.swift
//  Chat302AI
//
//  Created by Adswave on 2025/6/30.
//

import SwiftUI
 
extension Font.Weight: @retroactive RawRepresentable, Codable {
    public init?(rawValue: Double) {
        switch rawValue {
        case -0.8: self = .ultraLight
        case -0.6: self = .thin
        case -0.4: self = .light
        case 0.0: self = .regular
        case 0.23: self = .medium
        case 0.3: self = .semibold
        case 0.4: self = .bold
        case 0.56: self = .heavy
        case 0.62: self = .black
        default: return nil
        }
    }
    
    public var rawValue: Double {
        switch self {
        case .ultraLight: return -0.8
        case .thin: return -0.6
        case .light: return -0.4
        case .regular: return 0.0
        case .medium: return 0.23
        case .semibold: return 0.3
        case .bold: return 0.4
        case .heavy: return 0.56
        case .black: return 0.62
        default: return 0.0
        }
    }
}

extension Font.Design: @retroactive RawRepresentable, Codable {
    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .default
        case 1: self = .serif
        case 2: self = .rounded
        case 3: self = .monospaced
        default: return nil
        }
    }
    
    public var rawValue: Int {
        switch self {
        case .default: return 0
        case .serif: return 1
        case .rounded: return 2
        case .monospaced: return 3
        @unknown default: return 0
        }
    }
}



// 1. 创建字体管理器
class FontSettings: ObservableObject {
       
    static let kFontSettingsSetFontSize = "FontSettings_SetFontSize"
    
    private enum Keys {
            static let fontSize = "fontSize"
            static let fontWeight = "fontWeight"
            static let fontDesign = "fontDesign"
        }
        
        @Published var fontSize: CGFloat {
            didSet {
                UserDefaults.standard.set(fontSize, forKey: Keys.fontSize)
                UserDefaults.standard.synchronize()
                NotificationCenter.default.post(name: Notification.Name(FontSettings.kFontSettingsSetFontSize), object: nil)
            }
        }
        
        @Published var fontWeight: Font.Weight {
            didSet {
                // 将 Font.Weight 转换为 rawValue 存储
                UserDefaults.standard.set(fontWeight.rawValue, forKey: Keys.fontWeight)
                UserDefaults.standard.synchronize()
            }
        }
        
        @Published var fontDesign: Font.Design {
            didSet {
                // 将 Font.Design 转换为 rawValue 存储
                UserDefaults.standard.set(fontDesign.rawValue, forKey: Keys.fontDesign)
                UserDefaults.standard.synchronize()
            }
        }
        
        init() {
            // 从 UserDefaults 加载保存的值或使用默认值
            self.fontSize = UserDefaults.standard.object(forKey: Keys.fontSize) as? CGFloat ?? 16
            let fontWeightRawValue = UserDefaults.standard.double(forKey: Keys.fontWeight)
            self.fontWeight = Font.Weight(rawValue: fontWeightRawValue) ?? .regular
            let fontDesignRawValue = UserDefaults.standard.integer(forKey: Keys.fontDesign)
            self.fontDesign = Font.Design(rawValue: fontDesignRawValue) ?? .default
        }
}



struct CustomText: View {
    private var content: Text  // 统一用Text类型存储
    @EnvironmentObject var fontSettings: FontSettings
    @Environment(\.openURL) private var openURL  // 添加环境变量用于打开URL
    
    // 控制是否启用链接点击功能
    private var enableLinkTap: Bool
    
    // MARK: - 全部初始化方法
    
    /// 1. 直接传入AttributedString
    init(_ attributedString: AttributedString, enableLinkTap: Bool = true) {
        self.content = Text(attributedString)
        self.enableLinkTap = enableLinkTap
    }
    
    /// 2. 普通字符串（自动检测URL）
    init(_ string: String, enableLinkTap: Bool = true) {
        if let attributedString = Self.createAttributedString(from: string) {
            self.content = Text(attributedString)
        } else {
            self.content = Text(string)
        }
        self.enableLinkTap = enableLinkTap
    }
    
    /// 3. 非本地化字符串（verbatim）
    init(verbatim string: String, enableLinkTap: Bool = true) {
        self.content = Text(verbatim: string)
        self.enableLinkTap = enableLinkTap
    }
    
    /// 4. 本地化字符串
    init(_ key: LocalizedStringKey, enableLinkTap: Bool = true) {
        self.content = Text(key)
        self.enableLinkTap = enableLinkTap
    }
    
    /// 5. 直接传入Text（最高级灵活性）
    init(text: Text, enableLinkTap: Bool = true) {
        self.content = text
        self.enableLinkTap = enableLinkTap
    }
    
    // MARK: - 视图主体
    var body: some View {
        if enableLinkTap {
            content
                .font(.system(
                    size: (fontSettings.fontSize + 1),
                    weight: fontSettings.fontWeight,
                    design: fontSettings.fontDesign
                ))
                .environment(\.openURL, OpenURLAction { url in
                    // 这里可以添加自定义处理逻辑
                    // 例如检查特定域名或记录点击事件等
                    openURL(url)  // 最终调用系统打开URL
                    return .handled
                })
        } else {
            content
                .font(.system(
                    size: (fontSettings.fontSize + 1),
                    weight: fontSettings.fontWeight,
                    design: fontSettings.fontDesign
                ))
        }
    }
    
    // MARK: - URL检测私有方法
    private static func createAttributedString(from string: String) -> AttributedString? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        
        let matches = detector.matches(in: string, range: NSRange(location: 0, length: string.utf16.count))
        guard !matches.isEmpty else { return nil }
        
        var attributedString = AttributedString(string)
        
        for match in matches {
            guard let range = Range(match.range, in: attributedString),
                  let url = match.url else { continue }
            
            attributedString[range].link = url
            attributedString[range].foregroundColor = .blue
            attributedString[range].underlineStyle = .single
        }
        
        return attributedString
    }
}
  
