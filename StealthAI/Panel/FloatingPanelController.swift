import AppKit
import SwiftUI

/// 浮动面板控制器
class FloatingPanelController {
    private var panel: FloatingPanel?
    private var isVisible = false
    private let settings = AppSettings.shared
    
    init() {
        setupPanel()
    }
    
    private func setupPanel() {
        let width = settings.panelWidth
        let height = settings.panelHeight
        
        // 居中位置
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - width / 2
        let y = screenFrame.midY - height / 2 + 100 // 稍微偏上一点
        
        let contentRect = NSRect(x: x, y: y, width: width, height: height)
        panel = FloatingPanel(contentRect: contentRect)
        
        // 设置 SwiftUI 内容
        let contentView = FloatingContentView()
        let hostingView = NSHostingView(rootView: contentView)
        
        // 添加毛玻璃背景
        let visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 16
        visualEffectView.layer?.masksToBounds = true
        
        // 添加微妙边框
        visualEffectView.layer?.borderWidth = 0.5
        visualEffectView.layer?.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        
        hostingView.frame = visualEffectView.bounds
        hostingView.autoresizingMask = [.width, .height]
        visualEffectView.addSubview(hostingView)
        
        panel?.contentView = visualEffectView
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    func show() {
        guard let panel = panel else { return }
        
        // 更新尺寸
        let width = settings.panelWidth
        let height = settings.panelHeight
        
        // 重新居中（以防屏幕变化）
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - width / 2
            let y = screenFrame.midY - height / 2 + 100
            panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
        }
        
        // 显示动画
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
        
        isVisible = true
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hide() {
        guard let panel = panel else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
        
        isVisible = false
    }
    
    func updateSize(width: Double, height: Double) {
        guard let panel = panel else { return }
        var frame = panel.frame
        let centerX = frame.midX
        let centerY = frame.midY
        frame.size = NSSize(width: width, height: height)
        frame.origin.x = centerX - width / 2
        frame.origin.y = centerY - height / 2
        panel.setFrame(frame, display: true, animate: true)
    }
}

