import SwiftUI

/// Task detail view — FMS_SS design, static data only.
struct MaintenanceTaskDetailView: View {

    @State var viewModel: MaintenanceTaskDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(task: MMaintenanceTask) {
        _viewModel = State(initialValue: MaintenanceTaskDetailViewModel(task: task))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                taskHeader
                vehicleCard
                statusTimeline
                Divider().padding(.horizontal, 16)
                actionSection
                if viewModel.workOrder != nil {
                    workOrderForm
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.appSurface.ignoresSafeArea())
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Task Header

    private var taskHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(viewModel.task.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.appTextPrimary)
                Spacer()
                priorityBadge(viewModel.task.priority)
            }
            Text(viewModel.task.taskDescription)
                .font(.subheadline)
                .foregroundStyle(.appTextSecondary)
            HStack(spacing: 14) {
                Label(viewModel.task.taskType.rawValue, systemImage: "tag.fill")
                Label(viewModel.task.dueDate.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar")
            }
            .font(.caption)
            .foregroundStyle(.appTextSecondary)
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
        .padding(.top, 16)
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

    // MARK: - Vehicle Card

    private var vehicleCard: some View {
        let vehicle = StaticData.vehicle(for: viewModel.task)
        return VStack(alignment: .leading, spacing: 10) {
            Text("VEHICLE")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundStyle(.appOrange)
                    .frame(width: 44, height: 44)
                    .background(Color.appOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(vehicle?.name ?? "Unknown").font(.subheadline.weight(.medium))
                        .foregroundStyle(.appTextPrimary)
                    Text("\(vehicle?.licensePlate ?? "") • \(vehicle?.model ?? "")")
                        .font(.caption).foregroundStyle(.appTextSecondary)
                    Text("VIN: \(vehicle?.vin ?? "N/A")")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.68))
                    Text("Odometer: \(vehicle?.odometer ?? 0, specifier: "%.0f") km")
                        .font(.caption2).foregroundStyle(.appTextSecondary)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Status Timeline

    private var statusTimeline: some View {
        let steps: [(String, MTaskStatus)] = [
            ("Pending", .pending), ("Assigned", .assigned),
            ("In Progress", .inProgress), ("Completed", .completed)
        ]
        let currentIndex = steps.firstIndex(where: { $0.1 == viewModel.task.status }) ?? 0

        return VStack(alignment: .leading, spacing: 0) {
            Text("STATUS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)
                .padding(.bottom, 12)

            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    VStack(spacing: 5) {
                        Circle()
                            .fill(idx <= currentIndex ? Color.appOrange : Color(.systemGray4))
                            .frame(width: 12, height: 12)
                        Text(step.0)
                            .font(.system(size: 9, weight: idx <= currentIndex ? .bold : .regular))
                            .foregroundStyle(idx <= currentIndex ? .appTextPrimary : .appTextSecondary)
                    }
                    if idx < steps.count - 1 {
                        Rectangle()
                            .fill(idx < currentIndex ? Color.appOrange : Color(.systemGray4))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionSection: some View {
        if viewModel.task.status == .assigned && viewModel.workOrder == nil {
            Button {
                viewModel.startWork()
            } label: {
                HStack {
                    if viewModel.isStartingWork { ProgressView().tint(.white) }
                    Text("Start Work")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appOrange, in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(viewModel.isStartingWork)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Work Order Form

    private var workOrderForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WORK ORDER")
                .font(.caption.weight(.bold))
                .foregroundStyle(.appTextSecondary)
                .kerning(1)

            VStack(alignment: .leading, spacing: 6) {
                Text("Repair Description").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                TextEditor(text: $viewModel.repairDescription)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appDivider, lineWidth: 1))
            }

            DatePicker("Est. Completion", selection: $viewModel.estimatedCompletion,
                       displayedComponents: [.date, .hourAndMinute])
                .font(.subheadline)
                .tint(.appOrange)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Parts Used").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                    Spacer()
                    Button { viewModel.addPartRow() } label: {
                        Image(systemName: "plus.circle.fill").foregroundStyle(.appOrange)
                    }
                }
                ForEach($viewModel.partsUsed) { $part in
                    HStack(spacing: 8) {
                        TextField("Part", text: $part.name).textFieldStyle(.roundedBorder).font(.caption)
                        TextField("#", text: $part.partNumber).textFieldStyle(.roundedBorder).font(.caption).frame(width: 60)
                        Stepper("Qty: \(part.quantity)", value: $part.quantity, in: 1...100).font(.caption2)
                        TextField("Cost", value: $part.unitCost, format: .number)
                            .textFieldStyle(.roundedBorder).font(.caption).frame(width: 60)
                    }
                }
                Text("Parts Total: ₹\(viewModel.computedPartsCost, specifier: "%.2f")")
                    .font(.caption.weight(.bold)).foregroundStyle(.appOrange)
            }

            HStack {
                Text("Labour Cost").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                Spacer()
                TextField("₹", value: $viewModel.labourCost, format: .number)
                    .textFieldStyle(.roundedBorder).frame(width: 100)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Technician Notes").font(.caption.weight(.medium)).foregroundStyle(.appTextSecondary)
                TextEditor(text: $viewModel.technicianNotes)
                    .frame(minHeight: 60)
                    .padding(8)
                    .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appDivider, lineWidth: 1))
            }

            if viewModel.task.status == .inProgress || viewModel.workOrder != nil {
                Button {
                    let done = viewModel.markComplete()
                    if done { dismiss() }
                } label: {
                    HStack {
                        if viewModel.isCompleting { ProgressView().tint(.white) }
                        Text("Mark Complete").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(viewModel.isCompleting)
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }
}
