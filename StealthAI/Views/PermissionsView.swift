import SwiftUI

/// 权限引导视图
struct PermissionsView: View {
    @State private var accessibilityStatus = PermissionChecker.accessibilityStatus
    @State private var isRefreshing = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 标题
            VStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("系统权限")
                    .font(.title.bold())
                
                Text("应用需要以下权限才能正常工作")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // 权限列表
            VStack(spacing: 16) {
                PermissionRow(
                    title: "辅助功能",
                    description: "用于监听全局快捷键",
                    status: accessibilityStatus,
                    action: {
                        PermissionChecker.requestAccessibilityPermission()
                        // 延迟检查状态
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            refreshStatus()
                        }
                    },
                    openSettings: PermissionChecker.openAccessibilitySettings
                )
            }
            .padding(.horizontal, 40)
            
            // 提示
            if accessibilityStatus != .granted {
                Text("💡 提示：授权后可能需要重新启动应用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 刷新按钮
            Button(action: {
                refreshStatus()
            }) {
                HStack {
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Label("刷新状态", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRefreshing)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            refreshStatus()
        }
    }
    
    private func refreshStatus() {
        isRefreshing = true
        // 延迟一点确保系统返回最新状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            accessibilityStatus = PermissionChecker.accessibilityStatus
            isRefreshing = false
        }
    }
}

// MARK: - 权限行

struct PermissionRow: View {
    let title: String
    let description: String
    let status: PermissionChecker.PermissionStatus
    let action: () -> Void
    let openSettings: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 状态图标
            Image(systemName: status.iconName)
                .font(.title2)
                .foregroundColor(statusColor)
            
            // 文本
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 操作按钮
            if status != .granted {
                Button("授权") {
                    action()
                }
                .buttonStyle(.borderedProminent)
                
                Button("打开设置") {
                    openSettings()
                }
                .buttonStyle(.bordered)
            } else {
                Text("已授权")
                    .foregroundColor(.green)
                    .font(.callout.bold())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .granted: return .green
        case .denied: return .red
        case .unknown: return .yellow
        }
    }
}

#Preview {
    PermissionsView()
}
