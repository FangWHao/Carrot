import SwiftUI

/// 浮动面板内容视图
struct FloatingContentView: View {
    @StateObject private var webViewManager = AIWebViewManager.shared
    @ObservedObject private var settings = AppSettings.shared
    @State private var selectedService: AIService = AppSettings.shared.defaultService
    @State private var isDropTargeted = false
    
    var body: some View {
        VStack(spacing: 0) {
            // AI 服务选择器
            aiServicePicker
            
            // 分隔线
            Divider()
                .opacity(0.5)
            
            // WebView 容器，带拖放支持
            webViewContainer
        }
        .background(.clear)
        .onAppear {
            // 确保选中的服务是已启用的
            if !settings.isEnabled(selectedService), let first = settings.enabledServices.first {
                selectedService = first
            }
        }
    }
    
    // MARK: - AI 服务选择器
    
    private var aiServicePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(settings.enabledServices) { service in
                    serviceButton(for: service)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
    
    private func serviceButton(for service: AIService) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedService = service
            }
        }) {
            HStack(spacing: 6) {
                Image(service.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                Text(service.displayName)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedService == service
                          ? Color.accentColor.opacity(0.2)
                          : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedService == service
                            ? Color.accentColor.opacity(0.5)
                            : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(selectedService == service ? .accentColor : .secondary)
    }
    
    // MARK: - WebView 容器
    
    private var webViewContainer: some View {
        ZStack {
            // 只显示已启用的 WebView
            ForEach(settings.enabledServices) { service in
                AIWebViewWrapper(service: service)
                    .opacity(selectedService == service ? 1 : 0)
            }
            
            // 拖放覆盖层
            if isDropTargeted {
                dropOverlay
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleFileDrop(providers)
        }
    }
    
    private var dropOverlay: some View {
        ZStack {
            Color.accentColor.opacity(0.1)
            
            VStack(spacing: 12) {
                Image(systemName: "arrow.down.doc.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("拖放文件到此处上传")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }
    
    // MARK: - 文件拖放处理
    
    private func handleFileDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                    guard error == nil,
                          let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        // 将文件传递给当前 WebView 进行注入
                        webViewManager.injectFile(url, to: selectedService)
                    }
                }
                return true
            }
        }
        return false
    }
}

#Preview {
    FloatingContentView()
        .frame(width: 800, height: 600)
        .background(.ultraThinMaterial)
}
