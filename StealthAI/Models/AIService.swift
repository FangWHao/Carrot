import Foundation

/// AI 服务枚举
enum AIService: String, CaseIterable, Identifiable, Codable {
    case chatgpt = "ChatGPT"
    case claude = "Claude"
    case gemini = "Gemini"
    case qianwen = "通义千问"
    case glm = "智谱GLM"
    case deepseek = "DeepSeek"
    case doubao = "豆包"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    /// 自定义图片名（Assets 中的 imageset 名）
    var imageName: String {
        switch self {
        case .chatgpt: return "chatgpt"
        case .claude: return "claude"
        case .gemini: return "gemini"
        case .qianwen: return "qianwen"
        case .glm: return "glm"
        case .deepseek: return "deepseek"
        case .doubao: return "doubao"
        }
    }
    
    /// 系统图标名（fallback）
    var iconName: String {
        switch self {
        case .chatgpt: return "sparkles"
        case .claude: return "brain"
        case .gemini: return "wand.and.stars"
        case .qianwen: return "cloud"
        case .glm: return "cpu"
        case .deepseek: return "magnifyingglass"
        case .doubao: return "leaf"
        }
    }
    
    var url: URL {
        switch self {
        case .chatgpt: return URL(string: "https://chat.openai.com")!
        case .claude: return URL(string: "https://claude.ai")!
        case .gemini: return URL(string: "https://gemini.google.com")!
        case .qianwen: return URL(string: "https://tongyi.aliyun.com/qianwen")!
        case .glm: return URL(string: "https://chatglm.cn")!
        case .deepseek: return URL(string: "https://chat.deepseek.com")!
        case .doubao: return URL(string: "https://www.doubao.com/chat")!
        }
    }
    
    var accentColor: String {
        switch self {
        case .chatgpt: return "#10A37F"
        case .claude: return "#D4A27F"
        case .gemini: return "#4285F4"
        case .qianwen: return "#FF6A00"
        case .glm: return "#5B6EF8"
        case .deepseek: return "#4A90D9"
        case .doubao: return "#00D4AA"
        }
    }
}

