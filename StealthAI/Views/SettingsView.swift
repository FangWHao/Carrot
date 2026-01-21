import SwiftUI

/// 设置视图
struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var accessibilityStatus = PermissionChecker.accessibilityStatus
    
    var body: some View {
        Form {
            // 快捷键设置
            Section("全局热键") {
                HStack {
                    Text("唤醒快捷键")
                    Spacer()
                    Text("⌥ Space")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.tertiary)
                        )
                }
                
                Text("按 Option + 空格键 可快速唤醒或隐藏浮动面板")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // AI 模型选择
            Section("启用的 AI 模型") {
                ForEach(AIService.allCases) { service in
                    Toggle(isOn: Binding(
                        get: { settings.isEnabled(service) },
                        set: { settings.setEnabled(service, enabled: $0) }
                    )) {
                        HStack(spacing: 10) {
                            Image(service.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            Text(service.displayName)
                        }
                    }
                }
            }
            
            // 数据管理
            Section("数据管理") {
                Button(action: {
                    for service in AIService.allCases {
                        AIWebViewManager.shared.reload(service: service)
                    }
                }) {
                    Label("刷新所有 AI 网页", systemImage: "arrow.clockwise")
                }
                
                Button(action: {
                    for service in AIService.allCases {
                        AIWebViewManager.shared.clearData(for: service)
                    }
                }) {
                    Label("清除所有登录数据", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // 浮动面板设置
            Section("浮动面板") {
                HStack {
                    Text("面板宽度")
                    Spacer()
                    Slider(value: $settings.panelWidth, in: 600...1200, step: 50)
                        .frame(width: 200)
                    Text("\(Int(settings.panelWidth))")
                        .foregroundColor(.secondary)
                        .frame(width: 50)
                }
                
                HStack {
                    Text("面板高度")
                    Spacer()
                    Slider(value: $settings.panelHeight, in: 400...900, step: 50)
                        .frame(width: 200)
                    Text("\(Int(settings.panelHeight))")
                        .foregroundColor(.secondary)
                        .frame(width: 50)
                }
                
                HStack {
                    Text("网页缩放")
                    Spacer()
                    Slider(value: $settings.pageZoom, in: 0.5...2.0, step: 0.1)
                        .frame(width: 200)
                        .onChange(of: settings.pageZoom) { newValue in
                            AIWebViewManager.shared.setZoom(newValue)
                        }
                    Text("\(Int(settings.pageZoom * 100))%")
                        .foregroundColor(.secondary)
                        .frame(width: 50)
                }
                
                Picker("默认 AI 服务", selection: $settings.defaultService) {
                    ForEach(settings.enabledServices) { service in
                        Text(service.displayName).tag(service)
                    }
                }
            }
            
            // 权限设置
            Section("系统权限") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("辅助功能")
                            .font(.body)
                        Text("用于监听全局快捷键")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if accessibilityStatus == .granted {
                        Label("已授权", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("前往授权") {
                            PermissionChecker.openAccessibilitySettings()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                if accessibilityStatus != .granted {
                    Text("💡 提示：授权后可能需要重新启动应用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 通用设置
            Section("通用") {
                Toggle("开机自启动", isOn: $settings.launchAtLogin)
                Toggle("在 Dock 中显示", isOn: $settings.showInDock)
            }
            
            // 重置
            Section {
                Button("恢复默认设置") {
                    settings.resetToDefaults()
                }
                .foregroundColor(.red)
            }
            
            // 关于
            Section {
                VStack(spacing: 12) {
                    // 图标
                    Image("CarrotIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 4)
                    
                    // 应用名和版本
                    Text("Carrot")
                        .font(.title2.bold())
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 开发者信息
                    HStack(spacing: 4) {
                        Text("Developed by")
                            .foregroundColor(.secondary)
                        Link("FangHao", destination: URL(string: "https://github.com/FangWHao")!)
                            .foregroundColor(.accentColor)
                    }
                    .font(.footnote)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 600)
        .navigationTitle("设置")
        .onAppear {
            accessibilityStatus = PermissionChecker.accessibilityStatus
        }
    }
}

#Preview {
    SettingsView()
}
