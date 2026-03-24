import SwiftUI

/// Full maintenance dashboard — FMS_SS design, static data only.
struct MaintenanceDashboardView: View {

    @State private var viewModel = MaintenanceDashboardViewModel()
    @State private var selectedTab: DashTab = .tasks

    enum DashTab: Int, CaseIterable {
        case tasks, workOrders, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            tasksTab
                .tag(DashTab.tasks)
                .tabItem {
                    Image(systemName: "list.clipboard.fill")
                    Text("Tasks")
                }

            workOrdersTab
                .tag(DashTab.workOrders)
                .tabItem {
                    Image(systemName: "doc.plaintext.fill")
                    Text("Work Orders")
                }

            profileTab
                .tag(DashTab.profile)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
        }
        .tint(.appOrange)
    }

    // MARK: - Tasks Tab

    private var tasksTab: some View {
        NavigationStack {
            ZStack {
                Color.appSurface.ignoresSafeArea()
                Group {
                    if viewModel.filteredTasks.isEmpty {
                        emptyState
                    } else {
                        taskList
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    taskCountBadge
                }
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .navigationDestination(for: MMaintenanceTask.self) { task in
                MaintenanceTaskDetailView(task: task)
            }
        }
    }

    private var taskCountBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "number")
                .font(.caption2)
            Text("\(viewModel.filteredTasks.count)")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(.appOrange)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.appOrange.opacity(0.1), in: Capsule())
    }

    private var filterMenu: some View {
        let filterActive = viewModel.selectedFilter != .all || viewModel.selectedVehicleFilter != nil
        return Menu {
            Section("Status") {
                ForEach(MaintenanceDashboardViewModel.TaskFilter.allCases, id: \.self) { f in
                    Button {
                        viewModel.filterByStatus(f)
                    } label: {
                        Label(f.rawValue, systemImage: viewModel.selectedFilter == f ? "checkmark" : "")
                    }
                }
            }
            Section("Vehicle") {
                Button {
                    viewModel.filterByVehicle(nil)
                } label: {
                    Label("All Vehicles", systemImage: viewModel.selectedVehicleFilter == nil ? "checkmark" : "")
                }
                ForEach(viewModel.uniqueVehicleIds, id: \.self) { vId in
                    let v = StaticData.vehicles.first { $0.id == vId }
                    Button {
                        viewModel.filterByVehicle(vId)
                    } label: {
                        Label(v?.licensePlate ?? vId.uuidString.prefix(8).description,
                              systemImage: viewModel.selectedVehicleFilter == vId ? "checkmark" : "")
                    }
                }
            }
            if filterActive {
                Divider()
                Button(role: .destructive) {
                    viewModel.filterByStatus(.all)
                    viewModel.filterByVehicle(nil)
                } label: {
                    Label("Clear Filters", systemImage: "xmark.circle")
                }
            }
        } label: {
            Image(systemName: filterActive
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(filterActive ? .appOrange : .primary)
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredTasks) { task in
                    NavigationLink(value: task) {
                        taskCard(task)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func taskCard(_ task: MMaintenanceTask) -> some View {
        let vehicle = StaticData.vehicle(for: task)
        return VStack(alignment: .leading, spacing: 0) {
            // Top colored accent
            HStack(spacing: 0) {
                Rectangle()
                    .fill(task.priority.color)
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(task.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.appTextPrimary)
                                .lineLimit(1)
                            Text(vehicle?.name ?? "Unknown Vehicle")
                                .font(.caption)
                                .foregroundStyle(.appTextSecondary)
                        }
                        Spacer()
                        priorityBadge(task.priority)
                    }

                    HStack(spacing: 0) {
                        statusChip(task.status)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(task.dueDate.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.caption2)
                        }
                        .foregroundStyle(.appTextSecondary)
                        .padding(.trailing, 2)

                        Text("•")
                            .foregroundStyle(.appDivider)
                            .padding(.horizontal, 4)

                        Text(timeAgo(task.createdAt))
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
        }
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private func priorityBadge(_ p: MTaskPriority) -> some View {
        HStack(spacing: 4) {
            Image(systemName: p.icon)
                .font(.system(size: 9))
            Text(p.rawValue)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(p.color)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(p.bgColor)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(p.borderColor, lineWidth: 0.5))
    }

    private func statusChip(_ s: MTaskStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(s.color)
                .frame(width: 6, height: 6)
            Text(s.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(s.color)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(Color.appOrange.opacity(0.35))
            Text("No tasks match this filter")
                .font(.subheadline)
                .foregroundStyle(.appTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Work Orders Tab

    private var workOrdersTab: some View {
        NavigationStack {
            ZStack {
                Color.appSurface.ignoresSafeArea()
                if StaticData.workOrders.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 52, weight: .light))
                            .foregroundStyle(Color.appOrange.opacity(0.35))
                        Text("No work orders assigned")
                            .font(.subheadline).foregroundStyle(.appTextSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(StaticData.workOrders) { wo in
                                workOrderCard(wo)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
            .navigationTitle("Work Orders")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 4) {
                        Image(systemName: "number").font(.caption2)
                        Text("\(StaticData.workOrders.count)").font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.appOrange)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.appOrange.opacity(0.1), in: Capsule())
                }
            }
        }
    }

    private func workOrderCard(_ wo: MWorkOrder) -> some View {
        let task = StaticData.tasks.first { $0.id == wo.maintenanceTaskId }
        let vehicle = StaticData.vehicles.first { $0.id == wo.vehicleId }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(task?.title ?? "Work Order")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.appTextPrimary)
                        .lineLimit(1)
                    Text(vehicle.map { "\($0.name) • \($0.licensePlate)" } ?? "")
                        .font(.caption)
                        .foregroundStyle(.appTextSecondary)
                }
                Spacer()
                Text(wo.status.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(wo.status.color, in: Capsule())
            }

            if !wo.repairDescription.isEmpty {
                Text(wo.repairDescription)
                    .font(.caption)
                    .foregroundStyle(.appTextSecondary)
                    .lineLimit(2)
            }

            Text(timeAgo(wo.createdAt))
                .font(.caption2)
                .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
        }
        .padding(14)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    // MARK: - Profile Tab

    private var profileTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    profileStats
                    certificationCard
                    Spacer(minLength: 24)
                }
            }
            .background(Color.appSurface.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inline)
        }
    }

    private var profileHeader: some View {
        let user = StaticData.userProfile
        return ZStack {
            LinearGradient(
                colors: [Color.appOrange, Color.appDeepOrange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.white.opacity(0.15), .clear],
                center: .topLeading, startRadius: 20, endRadius: 280
            )
            VStack(spacing: 12) {
                let initials = String(user.name.prefix(2)).uppercased()
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    )
                Text(user.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                Text(user.email)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 30)
            .padding(.bottom, 24)
        }
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 0, bottomLeadingRadius: 28,
            bottomTrailingRadius: 28, topTrailingRadius: 0,
            style: .continuous
        ))
        .padding(.top, -8)
    }

    private var profileStats: some View {
        let total = StaticData.tasks.count
        let completed = StaticData.tasks.filter { $0.status == .completed }.count
        let inProgress = StaticData.tasks.filter { $0.status == .inProgress }.count
        return HStack(spacing: 0) {
            statCell(value: "\(completed)", label: "Completed", icon: "checkmark.circle.fill", color: .green)
            Divider().frame(height: 40)
            statCell(value: "\(inProgress)", label: "In Progress", icon: "wrench.fill", color: .purple)
            Divider().frame(height: 40)
            statCell(value: "\(total)", label: "Total Tasks", icon: "list.clipboard.fill", color: .appOrange)
        }
        .padding(.vertical, 16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.appTextPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var certificationCard: some View {
        let user = StaticData.userProfile
        return VStack(alignment: .leading, spacing: 12) {
            Text("CERTIFICATION")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)

            infoRow("Type", user.certificationType)
            infoRow("Expiry", user.certificationExpiry)
            infoRow("Experience", "\(user.yearsOfExperience) years")

            if !user.specializations.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Specializations")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.appTextSecondary)
                    FlexWrap(items: user.specializations)
                }
            }

            // Role badge
            HStack(spacing: 6) {
                Image(systemName: "wrench.fill").font(.caption2)
                Text(user.role).font(.caption)
            }
            .foregroundStyle(.appTextSecondary)
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(Color.appOrange.opacity(0.08), in: Capsule())

            // Approved badge
            HStack(spacing: 8) {
                Image(systemName: user.isApproved ? "checkmark.seal.fill" : "clock.fill")
                    .foregroundStyle(user.isApproved ? .green : .orange)
                Text(user.isApproved ? "Account Approved" : "Pending Approval")
                    .font(.subheadline)
                    .foregroundStyle(.appTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.appTextSecondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundStyle(.appTextPrimary)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600  { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}

// MARK: - Flex Wrap for chips

struct FlexWrap: View {
    let items: [String]
    var body: some View {
        var width: CGFloat = 0
        var rows: [[String]] = [[]]
        let chipWidth: CGFloat = 90
        for item in items {
            if width + chipWidth > 280 {
                rows.append([item])
                width = chipWidth
            } else {
                rows[rows.count - 1].append(item)
                width += chipWidth
            }
        }
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.appOrange)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.appOrange.opacity(0.1), in: Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    MaintenanceDashboardView()
}
