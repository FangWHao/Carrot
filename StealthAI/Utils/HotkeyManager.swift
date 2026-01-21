import Foundation
import Carbon

/// 全局热键管理器
class HotkeyManager {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let callback: () -> Void
    private let settings = AppSettings.shared
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    deinit {
        stopListening()
    }
    
    /// 开始监听全局热键
    func startListening() {
        // 检查辅助功能权限
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !trusted {
            print("需要辅助功能权限才能使用全局热键")
            return
        }
        
        // 创建事件回调
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        // 使用 block-based 方式创建 tap
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("无法创建事件 tap")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("全局热键监听已启动")
        }
    }
    
    /// 停止监听
    func stopListening() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
        
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            runLoopSource = nil
        }
    }
    
    /// 处理键盘事件
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // 检查是否匹配热键（默认 Option + Space）
        let expectedKeyCode = Int64(settings.hotkeyKeyCode)
        let expectedModifiers = CGEventFlags(rawValue: UInt64(settings.hotkeyModifiers))
        
        // Option 键检查
        let isOptionPressed = flags.contains(.maskAlternate)
        let isOnlyOption = !flags.contains(.maskCommand) && !flags.contains(.maskControl) && !flags.contains(.maskShift)
        
        if keyCode == expectedKeyCode && isOptionPressed && isOnlyOption {
            // 在主线程执行回调
            DispatchQueue.main.async { [weak self] in
                self?.callback()
            }
            // 消费事件，不传递
            return nil
        }
        
        return Unmanaged.passUnretained(event)
    }
}
