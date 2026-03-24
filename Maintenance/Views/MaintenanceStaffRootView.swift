import SwiftUI

/// Root view for the Maintenance Staff app.
/// Replace or embed this in your app entry point.
struct MaintenanceStaffRootView: View {
    @State private var selectedTab: StaffTab = .repair

    enum StaffTab: Int, CaseIterable {
        case repair, service, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RepairTaskListView()
                .tag(StaffTab.repair)
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver.fill")
                    Text("Repair")
                }

            ServiceTaskListView()
                .tag(StaffTab.service)
                .tabItem {
                    Image(systemName: "calendar.badge.checkmark")
                    Text("Service")
                }

            // Reuse existing profile tab
            NavigationStack {
                Text("Profile")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.appTextPrimary)
            }
            .tag(StaffTab.profile)
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Profile")
            }
        }
        .tint(.appOrange)
    }
}

#Preview {
    MaintenanceStaffRootView()
}
