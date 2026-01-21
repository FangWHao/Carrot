import Foundation

/// 文件注入器 - JavaScript 注入实现文件上传
struct FileInjector {
    
    /// 获取针对特定 AI 服务的文件注入脚本
    static func getInjectionScript(for service: AIService, fileURL: URL) -> String {
        let fileName = fileURL.lastPathComponent
        let filePath = fileURL.path
        
        switch service {
        case .chatgpt:
            return chatGPTScript(fileName: fileName, filePath: filePath)
        case .claude:
            return claudeScript(fileName: fileName, filePath: filePath)
        case .gemini:
            return geminiScript(fileName: fileName, filePath: filePath)
        case .qianwen, .glm, .deepseek, .doubao:
            return genericChineseAIScript(fileName: fileName, filePath: filePath)
        }
    }
    
    // MARK: - ChatGPT 注入脚本
    
    private static func chatGPTScript(fileName: String, filePath: String) -> String {
        """
        (function() {
            // 查找文件上传按钮
            const uploadButton = document.querySelector('button[aria-label*="附加"]') ||
                                 document.querySelector('button[aria-label*="Attach"]') ||
                                 document.querySelector('[data-testid="upload-button"]');
            
            if (uploadButton) {
                // 触发点击事件
                uploadButton.click();
                
                // 提示用户文件路径
                console.log('请手动选择文件: \(filePath)');
                
                // 尝试查找隐藏的 input
                setTimeout(() => {
                    const fileInput = document.querySelector('input[type="file"]');
                    if (fileInput) {
                        console.log('找到文件输入框');
                    }
                }, 500);
            } else {
                console.log('未找到上传按钮');
            }
            
            return '文件上传触发: \(fileName)';
        })();
        """
    }
    
    // MARK: - Claude 注入脚本
    
    private static func claudeScript(fileName: String, filePath: String) -> String {
        """
        (function() {
            // Claude 的上传按钮
            const uploadButton = document.querySelector('button[aria-label*="附件"]') ||
                                 document.querySelector('button[aria-label*="attachment"]') ||
                                 document.querySelector('[data-testid="attachment-button"]');
            
            if (uploadButton) {
                uploadButton.click();
                console.log('请手动选择文件: \(filePath)');
            } else {
                // 尝试直接查找 input
                const fileInput = document.querySelector('input[type="file"]');
                if (fileInput) {
                    fileInput.click();
                    console.log('请手动选择文件: \(filePath)');
                } else {
                    console.log('未找到上传按钮');
                }
            }
            
            return '文件上传触发: \(fileName)';
        })();
        """
    }
    
    // MARK: - Gemini 注入脚本
    
    private static func geminiScript(fileName: String, filePath: String) -> String {
        """
        (function() {
            // Gemini 的上传按钮（可能需要更新选择器）
            const uploadButton = document.querySelector('button[aria-label*="上传"]') ||
                                 document.querySelector('button[aria-label*="Upload"]') ||
                                 document.querySelector('[data-tooltip*="上传"]');
            
            if (uploadButton) {
                uploadButton.click();
                console.log('请手动选择文件: \(filePath)');
            } else {
                // 尝试查找加号或更多选项按钮
                const moreButton = document.querySelector('button[aria-label*="更多"]') ||
                                   document.querySelector('button[aria-label*="More"]');
                if (moreButton) {
                    moreButton.click();
                    console.log('请从菜单中选择上传选项');
                } else {
                    console.log('未找到上传按钮');
                }
            }
            
            return '文件上传触发: \(fileName)';
        })();
        """
    }
    
    // MARK: - 国产 AI 通用注入脚本
    
    private static func genericChineseAIScript(fileName: String, filePath: String) -> String {
        """
        (function() {
            // 通用查找上传按钮的选择器
            const uploadButton = document.querySelector('button[aria-label*="上传"]') ||
                                 document.querySelector('button[aria-label*="附件"]') ||
                                 document.querySelector('button[aria-label*="文件"]') ||
                                 document.querySelector('[data-testid*="upload"]') ||
                                 document.querySelector('[data-testid*="file"]') ||
                                 document.querySelector('input[type="file"]');
            
            if (uploadButton) {
                if (uploadButton.tagName === 'INPUT') {
                    uploadButton.click();
                } else {
                    uploadButton.click();
                }
                console.log('请手动选择文件: \(filePath)');
            } else {
                // 尝试查找任何可能的上传入口
                const possibleButtons = document.querySelectorAll('button');
                for (const btn of possibleButtons) {
                    if (btn.textContent.includes('上传') || btn.textContent.includes('文件')) {
                        btn.click();
                        console.log('请手动选择文件: \(filePath)');
                        break;
                    }
                }
            }
            
            return '文件上传触发: \(fileName)';
        })();
        """
    }
    
    // MARK: - 通用文件读取（Base64）
    
    /// 将文件转换为 Base64（用于高级注入场景）
    static func fileToBase64(_ url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return data.base64EncodedString()
    }
    
    /// 获取文件 MIME 类型
    static func getMimeType(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": return "application/pdf"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "txt": return "text/plain"
        case "md": return "text/markdown"
        case "json": return "application/json"
        case "csv": return "text/csv"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default: return "application/octet-stream"
        }
    }
}
