import Foundation
import AppKit

/// 权限检测工具
struct PermissionChecker {
    
    /// 检查辅助功能权限
    static var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }
    
    /// 请求辅助功能权限（会弹出系统对话框）
    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    /// 打开系统偏好设置 - 辅助功能
    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    /// 打开系统偏好设置 - 完整磁盘访问
    static func openFullDiskAccessSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }
    
    /// 权限状态枚举
    enum PermissionStatus {
        case granted
        case denied
        case unknown
        
        var displayName: String {
            switch self {
            case .granted: return "已授权"
            case .denied: return "未授权"
            case .unknown: return "未知"
            }
        }
        
        var iconName: String {
            switch self {
            case .granted: return "checkmark.circle.fill"
            case .denied: return "xmark.circle.fill"
            case .unknown: return "questionmark.circle.fill"
            }
        }
        
        var color: String {
            switch self {
            case .granted: return "green"
            case .denied: return "red"
            case .unknown: return "yellow"
            }
        }
    }
    
    /// 获取辅助功能权限状态
    static var accessibilityStatus: PermissionStatus {
        isAccessibilityGranted ? .granted : .denied
    }
}
