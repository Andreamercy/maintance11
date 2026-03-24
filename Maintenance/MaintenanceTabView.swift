import SwiftUI

/// Root tab bar — FMS_SS design with orange accent.
struct MaintenanceTabView: View {

    init() {
        MaintenanceTheme.configureTabBar()
    }

    var body: some View {
        TabView {
            Tab("Tasks", systemImage: "wrench.and.screwdriver.fill") {
                MaintenanceDashboardView()
            }
            Tab("Schedule", systemImage: "calendar") {
                schedulePlaceholder
            }
            Tab("Inventory", systemImage: "shippingbox.fill") {
                inventoryPlaceholder
            }
            Tab("Profile", systemImage: "person.fill") {
                profilePlaceholder
            }
        }
        .tint(.appOrange)
    }

    // MARK: - Placeholder Tabs

    private var schedulePlaceholder: some View {
        placeholderView(icon: "calendar.badge.clock", title: "Schedule", color: .appAmber)
    }

    private var inventoryPlaceholder: some View {
        placeholderView(icon: "shippingbox.fill", title: "Parts Inventory", color: .appOrange)
    }

    private var profilePlaceholder: some View {
        placeholderView(icon: "person.fill", title: "Profile", color: .appDeepOrange)
    }

    private func placeholderView(icon: String, title: String, color: Color) -> some View {
        ZStack {
            Color.appSurface.ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(color.opacity(0.4))
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.appTextSecondary)
                Text("Coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.appTextSecondary.opacity(0.6))
            }
        }
    }
}

#Preview {
    MaintenanceTabView()
}
