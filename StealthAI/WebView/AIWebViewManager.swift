import Foundation
import WebKit

/// 多 WebView 管理器（单例）
class AIWebViewManager: ObservableObject {
    static let shared = AIWebViewManager()
    
    private var webViews: [AIService: WKWebView] = [:]
    private let configuration: WKWebViewConfiguration
    
    private init() {
        self.configuration = WebViewConfiguration.createConfiguration()
        
        // 预创建所有 AI 服务的 WebView
        for service in AIService.allCases {
            createWebView(for: service)
        }
    }
    
    /// 获取指定服务的 WebView
    func getWebView(for service: AIService) -> WKWebView {
        if let webView = webViews[service] {
            return webView
        }
        return createWebView(for: service)
    }
    
    /// 创建 WebView
    @discardableResult
    private func createWebView(for service: AIService) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // 设置 User-Agent
        webView.customUserAgent = WebViewConfiguration.safariUserAgent
        
        // 允许后退前进
        webView.allowsBackForwardNavigationGestures = true
        
        // 应用缩放设置
        webView.pageZoom = AppSettings.shared.pageZoom
        
        // 加载 URL
        let request = URLRequest(url: service.url)
        webView.load(request)
        
        webViews[service] = webView
        return webView
    }
    
    /// 刷新指定服务的页面
    func reload(service: AIService) {
        webViews[service]?.reload()
    }
    
    /// 刷新所有页面
    func reloadAll() {
        for (_, webView) in webViews {
            webView.reload()
        }
    }
    
    /// 清除指定服务的数据
    func clearData(for service: AIService) {
        let dataStore = configuration.websiteDataStore
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            let serviceRecords = records.filter { record in
                record.displayName.contains(service.url.host ?? "")
            }
            dataStore.removeData(ofTypes: dataTypes, for: serviceRecords) {
                // 数据清除完成，重新加载
                self.webViews[service]?.reload()
            }
        }
    }
    
    /// 注入文件到 WebView
    func injectFile(_ fileURL: URL, to service: AIService) {
        guard let webView = webViews[service] else { return }
        
        // 获取对应服务的文件注入脚本
        let script = FileInjector.getInjectionScript(for: service, fileURL: fileURL)
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("文件注入失败: \(error.localizedDescription)")
            } else {
                print("文件注入成功: \(fileURL.lastPathComponent)")
            }
        }
    }
    
    /// 执行 JavaScript
    func evaluateJavaScript(_ script: String, for service: AIService, completion: ((Any?, Error?) -> Void)? = nil) {
        webViews[service]?.evaluateJavaScript(script, completionHandler: completion)
    }
    
    /// 设置所有 WebView 的缩放比例
    func setZoom(_ zoom: Double) {
        for (_, webView) in webViews {
            webView.pageZoom = zoom
        }
    }
    
    /// 应用当前缩放设置到指定 WebView
    func applyCurrentZoom(to webView: WKWebView) {
        webView.pageZoom = AppSettings.shared.pageZoom
    }
}
