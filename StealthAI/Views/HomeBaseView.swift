import SwiftUI

/// 主窗口视图 - Home Base
struct HomeBaseView: View {
    @State private var selection: SidebarItem? = .settings
    @ObservedObject private var settings = AppSettings.shared
    
    var body: some View {
        NavigationSplitView {
            // 侧边栏
            sidebar
        } detail: {
            // 详情视图
            detailView
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(VisualEffectBackground())
    }
    
    // MARK: - 侧边栏项枚举
    
    enum SidebarItem: Hashable {
        case aiService(AIService)
        case settings
    }
    
    // MARK: - 侧边栏
    
    private var sidebar: some View {
        List(selection: $selection) {
            Section("AI 账户") {
                ForEach(settings.enabledServices) { service in
                    HStack(spacing: 8) {
                        Image(service.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        Text(service.displayName)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .tag(SidebarItem.aiService(service))
                }
            }
            
            Section("系统") {
                Label("设置", systemImage: "gearshape")
                    .tag(SidebarItem.settings)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 140, idealWidth: 180, maxWidth: 250)
    }
    
    // MARK: - 详情视图
    
    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .aiService(let service):
            AccountLoginView(service: service)
                .id(service.id)  // 强制 SwiftUI 在切换时重建视图
        case .settings, .none:
            SettingsView()
        }
    }
}

// MARK: - 毛玻璃背景

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .sidebar
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

#Preview {
    HomeBaseView()
}
