import Foundation
import SwiftUI

/// 应用设置模型
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("hotkeyModifiers") var hotkeyModifiers: Int = 524288 // Option key
    @AppStorage("hotkeyKeyCode") var hotkeyKeyCode: Int = 49 // Space bar
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("showInDock") var showInDock: Bool = true
    @AppStorage("defaultAIService") var defaultAIService: String = AIService.chatgpt.rawValue
    @AppStorage("panelWidth") var panelWidth: Double = 800
    @AppStorage("panelHeight") var panelHeight: Double = 600
    @AppStorage("pageZoom") var pageZoom: Double = 1.0 // 网页缩放比例
    
    // 各模型的启用状态
    @AppStorage("enableChatGPT") var enableChatGPT: Bool = true
    @AppStorage("enableClaude") var enableClaude: Bool = true
    @AppStorage("enableGemini") var enableGemini: Bool = true
    @AppStorage("enableQianwen") var enableQianwen: Bool = true
    @AppStorage("enableGLM") var enableGLM: Bool = true
    @AppStorage("enableDeepseek") var enableDeepseek: Bool = true
    @AppStorage("enableDoubao") var enableDoubao: Bool = true
    
    var defaultService: AIService {
        get { AIService(rawValue: defaultAIService) ?? .chatgpt }
        set { defaultAIService = newValue.rawValue }
    }
    
    /// 获取已启用的 AI 服务列表
    var enabledServices: [AIService] {
        var services: [AIService] = []
        if enableChatGPT { services.append(.chatgpt) }
        if enableClaude { services.append(.claude) }
        if enableGemini { services.append(.gemini) }
        if enableQianwen { services.append(.qianwen) }
        if enableGLM { services.append(.glm) }
        if enableDeepseek { services.append(.deepseek) }
        if enableDoubao { services.append(.doubao) }
        return services
    }
    
    /// 检查某服务是否启用
    func isEnabled(_ service: AIService) -> Bool {
        switch service {
        case .chatgpt: return enableChatGPT
        case .claude: return enableClaude
        case .gemini: return enableGemini
        case .qianwen: return enableQianwen
        case .glm: return enableGLM
        case .deepseek: return enableDeepseek
        case .doubao: return enableDoubao
        }
    }
    
    /// 设置某服务的启用状态
    func setEnabled(_ service: AIService, enabled: Bool) {
        switch service {
        case .chatgpt: enableChatGPT = enabled
        case .claude: enableClaude = enabled
        case .gemini: enableGemini = enabled
        case .qianwen: enableQianwen = enabled
        case .glm: enableGLM = enabled
        case .deepseek: enableDeepseek = enabled
        case .doubao: enableDoubao = enabled
        }
        objectWillChange.send()
    }
    
    private init() {}
    
    func resetToDefaults() {
        hotkeyModifiers = 524288
        hotkeyKeyCode = 49
        launchAtLogin = false
        showInDock = true
        defaultAIService = AIService.chatgpt.rawValue
        panelWidth = 800
        panelHeight = 600
        pageZoom = 1.0
        enableChatGPT = true
        enableClaude = true
        enableGemini = true
        enableQianwen = true
        enableGLM = true
        enableDeepseek = true
        enableDoubao = true
    }
}

