import AppKit

/// 自定义浮动面板 - Spotlight 风格
class FloatingPanel: NSPanel {
    
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )
        
        configure()
    }
    
    private func configure() {
        // 浮动层级 - 使用 statusBar 级别确保在全屏应用上方
        level = .statusBar
        
        // 集合行为：关键修复 - 不使用 transient，避免全屏下滑动到桌面
        // stationary: 窗口不会触发空间切换
        // canJoinAllSpaces: 在所有桌面空间可见
        // fullScreenAuxiliary: 可以在全屏应用上显示
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        
        // 透明背景，允许自定义视觉效果
        isOpaque = false
        backgroundColor = .clear
        
        // 移动性
        isMovableByWindowBackground = true
        
        // 圆角
        if let contentView = contentView {
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 16
            contentView.layer?.masksToBounds = true
        }
        
        // 阴影
        hasShadow = true
        
        // 标题栏隐藏
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        // 动画
        animationBehavior = .utilityWindow
    }
    
    // 允许成为 key window 以接收键盘事件
    override var canBecomeKey: Bool { true }
    
    // 不允许成为 main window
    override var canBecomeMain: Bool { false }
    
    // ESC 键关闭面板
    override func cancelOperation(_ sender: Any?) {
        orderOut(nil)
    }
    
    // 不再自动关闭 - 只通过快捷键或 ESC 关闭
    // 这样用户可以从 Finder 拖放文件到面板
}
