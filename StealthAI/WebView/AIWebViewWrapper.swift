import SwiftUI
import WebKit

/// WKWebView 的 SwiftUI 封装
struct AIWebViewWrapper: NSViewRepresentable {
    let service: AIService
    
    func makeNSView(context: Context) -> WKWebView {
        // 获取或创建该服务的 WebView
        return AIWebViewManager.shared.getWebView(for: service)
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // 如果当前页面不是目标 URL，则加载
        if nsView.url == nil {
            let request = URLRequest(url: service.url)
            nsView.load(request)
        }
    }
}

// MARK: - WebView 配置工厂

struct WebViewConfiguration {
    
    /// 创建标准配置（伪装为 Safari）
    static func createConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        // 使用默认数据存储以持久化 Cookie
        configuration.websiteDataStore = .default()
        
        // 媒体配置（macOS 特有）
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // 用户内容控制器
        let userContentController = WKUserContentController()
        
        // 注入自定义脚本以隐藏某些检测
        let script = WKUserScript(
            source: antiDetectionScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(script)
        
        configuration.userContentController = userContentController
        
        // 偏好设置
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        return configuration
    }
    
    /// Safari User-Agent
    static var safariUserAgent: String {
        // 获取系统版本
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion)_\(osVersion.minorVersion)"
        
        return """
        Mozilla/5.0 (Macintosh; Intel Mac OS X \(osVersionString)) \
        AppleWebKit/605.1.15 (KHTML, like Gecko) \
        Version/17.2 Safari/605.1.15
        """
    }
    
    /// 反检测脚本
    private static var antiDetectionScript: String {
        """
        (function() {
            // 隐藏 webdriver 属性
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });
            
            // 模拟正常的 chrome 对象（某些网站检测）
            window.chrome = {
                runtime: {}
            };
            
            // 隐藏自动化属性
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3]
            });
        })();
        """
    }
}
