import SwiftUI

/// Root tab bar for the FMS Maintenance Staff App.
/// Tabs: Repair · Service · Profile
struct MaintenanceTabView: View {

    init() {
        MaintenanceTheme.configureTabBar()
    }

    var body: some View {
        TabView {
            Tab("Repair", systemImage: "wrench.and.screwdriver.fill") {
                RepairTaskListView()
            }
            Tab("Service", systemImage: "calendar.badge.checkmark") {
                ServiceTaskListView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                profileTab
            }
        }
        .tint(.appOrange)
    }

    // MARK: - Profile Tab
    private var profileTab: some View {
        NavigationStack {
            ZStack {
                Color.appSurface.ignoresSafeArea()
                VStack(spacing: 16) {
                    profileHeader
                    profileStats
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inline)
        }
    }

    private var profileHeader: some View {
        let user = StaticData.userProfile
        return ZStack {
            LinearGradient(
                colors: [Color.appOrange, Color.appDeepOrange],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 12) {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(user.name.prefix(2)).uppercased())
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    )
                Text(user.name)
                    .font(.title3.weight(.bold)).foregroundStyle(.white)
                Text(user.email)
                    .font(.caption).foregroundStyle(.white.opacity(0.8))
                Text(user.role)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 14).padding(.vertical, 5)
                    .background(.white.opacity(0.15), in: Capsule())
            }
            .padding(.top, 30).padding(.bottom, 28)
        }
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 0, bottomLeadingRadius: 28,
            bottomTrailingRadius: 28, topTrailingRadius: 0,
            style: .continuous
        ))
        .padding(.top, -8)
    }

    private var profileStats: some View {
        let total     = StaticData.tasks.count
        let completed = StaticData.tasks.filter { $0.status == .completed }.count
        let inProg    = StaticData.tasks.filter { $0.status == .inProgress }.count
        return HStack(spacing: 0) {
            statCell(value: "\(completed)", label: "Completed",  icon: "checkmark.circle.fill", color: .green)
            Divider().frame(height: 40)
            statCell(value: "\(inProg)",    label: "In Progress", icon: "wrench.fill",          color: .purple)
            Divider().frame(height: 40)
            statCell(value: "\(total)",     label: "Total Tasks", icon: "list.clipboard.fill",  color: .appOrange)
        }
        .padding(.vertical, 16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(color)
            Text(value).font(.title3.weight(.bold)).foregroundStyle(.appTextPrimary)
            Text(label).font(.system(size: 10)).foregroundStyle(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MaintenanceTabView()
}
