import SwiftUI

struct RepairTaskDetailView: View {
    @State private var viewModel: RepairDetailViewModel
    var onUpdate: (RepairTask) -> Void
    @Environment(\.dismiss) private var dismiss

    init(task: RepairTask, onUpdate: @escaping (RepairTask) -> Void) {
        _viewModel = State(initialValue: RepairDetailViewModel(task: task))
        self.onUpdate = onUpdate
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                taskHeaderCard
                vehicleCard
                statusBanner
                inventoryCard
                historyCard
                actionButtons
            }
            .padding(.bottom, 32)
        }
        .background(Color.appSurface.ignoresSafeArea())
        .navigationTitle("Repair Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showPartsRequestSheet) {
            PartsRequestSheet(task: viewModel.task) { parts in
                viewModel.submitPartsRequest(parts)
                onUpdate(viewModel.task)
            }
        }
        .sheet(isPresented: $viewModel.showEstimatedTimeSheet) {
            estimatedTimeSheet
        }
        .onChange(of: viewModel.task) { _, newTask in
            onUpdate(newTask)
        }
    }

    // MARK: - Task Header
    private var taskHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.task.title)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.appTextPrimary)
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill").font(.caption2)
                        Text(viewModel.task.assignedBy)
                            .font(.caption)
                    }
                    .foregroundStyle(.appTextSecondary)
                }
                Spacer()
                priorityBadge(viewModel.task.priority)
            }

            Text(viewModel.task.description)
                .font(.subheadline)
                .foregroundStyle(.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Label(viewModel.task.dueDate.formatted(.dateTime.month(.abbreviated).day().hour().minute()), systemImage: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(.appTextSecondary)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    // MARK: - Vehicle Card
    private var vehicleCard: some View {
        let v = RepairStaticData.vehicle(for: viewModel.task.vehicleId)
        return VStack(alignment: .leading, spacing: 10) {
            Label("VEHICLE", systemImage: "car.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)

            if let v = v {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appOrange.opacity(0.12))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "car.fill")
                                .font(.title2)
                                .foregroundStyle(.appOrange)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(v.name).font(.subheadline.weight(.semibold)).foregroundStyle(.appTextPrimary)
                        Text("\(v.model) • \(v.licensePlate)").font(.caption).foregroundStyle(.appTextSecondary)
                        Text("VIN: \(v.vin)").font(.system(size: 10, design: .monospaced)).foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
                        Text("Odometer: \(Int(v.odometer)) km").font(.caption2).foregroundStyle(.appTextSecondary)
                    }
                    Spacer()
                }

                // Previous History Placeholder
                VStack(alignment: .leading, spacing: 4) {
                    Text("Previous Repairs").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                    HStack(spacing: 8) {
                        ForEach(["Brake Check", "Oil Change", "Tyre Rot."], id: \.self) { item in
                            Text(item)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.appOrange)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color.appOrange.opacity(0.1), in: Capsule())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Status Banner
    @ViewBuilder
    private var statusBanner: some View {
        let status = viewModel.task.status
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: status.icon)
                    .font(.title3)
                    .foregroundStyle(status.color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(status.rawValue).font(.subheadline.weight(.semibold)).foregroundStyle(status.color)
                    if status == .underMaintenance {
                        Text(viewModel.dueCountdown)
                            .font(.caption)
                            .foregroundStyle(.appTextSecondary)
                    } else if status == .partsReady {
                        Text("All parts available — you can start work now")
                            .font(.caption)
                            .foregroundStyle(.appTextSecondary)
                    } else if status == .repairDone, let done = viewModel.task.completedAt {
                        Text("Completed " + done.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                            .font(.caption).foregroundStyle(.appTextSecondary)
                    }
                }
                Spacer()
            }
        }
        .padding(14)
        .background(status.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(status.color.opacity(0.25), lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Inventory Card
    private var inventoryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("INVENTORY REQUIREMENTS", systemImage: "shippingbox.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.appTextSecondary)
                    .kerning(1)
                Spacer()
                let allAvail = viewModel.task.inventoryRequirements.allSatisfy { $0.isAvailable }
                if allAvail {
                    Label("All Available", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                } else {
                    let missing = viewModel.task.inventoryRequirements.filter { !$0.isAvailable }.count
                    Label("\(missing) missing", systemImage: "xmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            }

            if viewModel.task.inventoryRequirements.isEmpty {
                Text("No inventory requirements listed")
                    .font(.caption).foregroundStyle(.appTextSecondary)
            } else {
                ForEach(viewModel.task.inventoryRequirements) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(item.isAvailable ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(item.name).font(.subheadline).foregroundStyle(.appTextPrimary)
                        Spacer()
                        Text("x\(item.quantity)").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                        Text(item.partNumber)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
                    }
                }
            }

            // Parts request status
            if let req = viewModel.task.partsRequest {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Parts Request").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                        Text("\(req.items.count) item(s) • " + req.status.rawValue)
                            .font(.caption).foregroundStyle(.appTextPrimary)
                    }
                    Spacer()
                    Text(req.status.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(req.status == .fulfilled ? Color.green : Color.orange, in: Capsule())
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - History
    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("HISTORY", systemImage: "clock.arrow.circlepath")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)

            ForEach(viewModel.task.history.reversed()) { entry in
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(entry.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: entry.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(entry.color)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title).font(.subheadline.weight(.medium)).foregroundStyle(.appTextPrimary)
                        Text(entry.detail).font(.caption).foregroundStyle(.appTextSecondary)
                        Text(entry.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                            .font(.system(size: 10)).foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        let status = viewModel.task.status
        VStack(spacing: 10) {
            // Request parts button — only if assigned and no request yet
            if status == .assigned && viewModel.task.partsRequest == nil {
                Button {
                    viewModel.showPartsRequestSheet = true
                } label: {
                    Label("Request Parts from Inventory", systemImage: "shippingbox.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appOrange, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
            }

            // Start work — only if parts ready
            if status == .partsReady {
                Button {
                    viewModel.showEstimatedTimeSheet = true
                } label: {
                    Label("Start Work", systemImage: "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.purple, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
            }

            // Mark done — only if under maintenance
            if status == .underMaintenance {
                Button {
                    viewModel.markRepairDone()
                } label: {
                    HStack {
                        if viewModel.isCompleting { ProgressView().tint(.white) }
                        Label("Mark Repair Done", systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isCompleting)
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Estimated Time Sheet
    private var estimatedTimeSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "timer")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(.appOrange)

                Text("Estimated Time to Complete")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.appTextPrimary)

                Text("Set how long you expect this repair to take.")
                    .font(.subheadline)
                    .foregroundStyle(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                HStack(spacing: 0) {
                    Picker("Hours", selection: $viewModel.estimatedHours) {
                        ForEach(0..<24, id: \.self) { h in
                            Text("\(h) hr").tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("Minutes", selection: $viewModel.estimatedMinutes) {
                        ForEach([0, 15, 30, 45], id: \.self) { m in
                            Text("\(m) min").tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .tint(.appOrange)
                .frame(height: 150)

                Button {
                    viewModel.startWork()
                } label: {
                    HStack {
                        if viewModel.isStarting { ProgressView().tint(.white) }
                        Label("Start Now", systemImage: "play.fill")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isStarting)
                .padding(.horizontal, 24)

                Spacer()
            }
            .background(Color.appSurface.ignoresSafeArea())
            .navigationTitle("Set ETA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showEstimatedTimeSheet = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func priorityBadge(_ p: MTaskPriority) -> some View {
        HStack(spacing: 4) {
            Image(systemName: p.icon).font(.system(size: 10))
            Text(p.rawValue).font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(p.color)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(p.bgColor)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(p.borderColor, lineWidth: 0.5))
    }
}
