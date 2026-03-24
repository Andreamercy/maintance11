import SwiftUI

struct ServiceTaskDetailView: View {
    @State var task: ServiceTask
    var onUpdate: (ServiceTask) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showAddPart = false
    @State private var newPartName = ""
    @State private var newPartFromCatalog = true
    @State private var isCompleting = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                serviceHeaderCard
                vehicleCard
                requiredPartsCard
                checklistCard
                actionButton
            }
            .padding(.bottom, 32)
        }
        .background(Color.appSurface.ignoresSafeArea())
        .navigationTitle("Service Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddPart) {
            addPartSheet
        }
        .onChange(of: task) { _, newTask in onUpdate(newTask) }
    }

    // MARK: - Header
    private var serviceHeaderCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 19, weight: .bold)).foregroundStyle(.appTextPrimary)
                    Text(task.serviceType.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.appOrange)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.appOrange.opacity(0.1), in: Capsule())
                }
                Spacer()
                Text(task.status.rawValue)
                    .font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(task.status.color, in: Capsule())
            }

            Text(task.description)
                .font(.subheadline).foregroundStyle(.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                if let last = task.lastServiceDate {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Last Service").font(.system(size: 10)).foregroundStyle(.appTextSecondary)
                        Text(last.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(.caption.weight(.medium)).foregroundStyle(.appTextPrimary)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scheduled").font(.system(size: 10)).foregroundStyle(.appTextSecondary)
                    Text(task.scheduledDate.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(.caption.weight(.medium)).foregroundStyle(.appTextPrimary)
                }
                if let next = task.nextServiceDate {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Service").font(.system(size: 10)).foregroundStyle(.appTextSecondary)
                        Text(next.formatted(.dateTime.month(.abbreviated).day().year()))
                            .font(.caption.weight(.medium)).foregroundStyle(.appTextPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16).padding(.top, 16)
    }

    // MARK: - Vehicle
    private var vehicleCard: some View {
        let v = RepairStaticData.vehicle(for: task.vehicleId)
        return VStack(alignment: .leading, spacing: 10) {
            Label("VEHICLE", systemImage: "car.fill")
                .font(.caption.weight(.bold)).foregroundStyle(.appTextSecondary).kerning(1)
            if let v = v {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appOrange.opacity(0.12))
                        .frame(width: 48, height: 48)
                        .overlay(Image(systemName: "car.fill").font(.title2).foregroundStyle(.appOrange))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(v.name).font(.subheadline.weight(.semibold)).foregroundStyle(.appTextPrimary)
                        Text("\(v.model) • \(v.licensePlate)").font(.caption).foregroundStyle(.appTextSecondary)
                        Text("Odometer: \(Int(v.odometer)) km").font(.caption2).foregroundStyle(.appTextSecondary)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Required Parts
    private var requiredPartsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("REQUIRED PARTS", systemImage: "shippingbox.fill")
                    .font(.caption.weight(.bold)).foregroundStyle(.appTextSecondary).kerning(1)
                Spacer()
                Button {
                    showAddPart = true
                } label: {
                    Label("Add Part", systemImage: "plus.circle.fill")
                        .font(.caption.weight(.medium)).foregroundStyle(.appOrange)
                }
            }

            ForEach(task.requiredParts) { item in
                HStack(spacing: 10) {
                    Circle()
                        .fill(item.isAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(item.name).font(.subheadline).foregroundStyle(.appTextPrimary)
                    Spacer()
                    Text("x\(item.quantity)").font(.caption).foregroundStyle(.appTextSecondary)
                    Text(item.isAvailable ? "✓" : "Missing")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(item.isAvailable ? .green : .red)
                }
                Divider()
            }

            let available = task.requiredParts.filter { $0.isAvailable }.count
            let total = task.requiredParts.count
            HStack {
                Text("\(available) of \(total) parts available")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(available == total ? .green : .orange)
                Spacer()
            }
        }
        .padding(16)
        .background(Color.appCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - Checklist
    private var checklistCard: some View {
        let groups = Dictionary(grouping: task.checklistItems) { $0.category }
        let sortedCategories = groups.keys.sorted()
        let checked = task.checklistItems.filter { $0.isChecked }.count
        let total = task.checklistItems.count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("SERVICE CHECKLIST", systemImage: "checklist")
                    .font(.caption.weight(.bold)).foregroundStyle(.appTextSecondary).kerning(1)
                Spacer()
                Text("\(checked)/\(total)")
                    .font(.caption.weight(.bold)).foregroundStyle(.appOrange)
            }

            // Progress
            let progress: Double = total > 0 ? Double(checked) / Double(total) : 0
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appDivider).frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appOrange)
                        .frame(width: geo.size.width * progress, height: 7)
                }
            }
            .frame(height: 7)

            ForEach(sortedCategories, id: \.self) { cat in
                VStack(alignment: .leading, spacing: 8) {
                    Text(cat.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.appTextSecondary).kerning(1)
                    ForEach(groups[cat] ?? []) { item in
                        checklistRow(item)
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

    private func checklistRow(_ item: ServiceCheckItem) -> some View {
        Button {
            if let idx = task.checklistItems.firstIndex(where: { $0.id == item.id }) {
                task.checklistItems[idx].isChecked.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(item.isChecked ? .appOrange : Color(.systemGray4))
                Text(item.name)
                    .font(.subheadline)
                    .foregroundStyle(item.isChecked ? .appTextSecondary : .appTextPrimary)
                    .strikethrough(item.isChecked, color: .appTextSecondary)
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action
    @ViewBuilder
    private var actionButton: some View {
        if task.status != .completed {
            let allChecked = task.checklistItems.allSatisfy { $0.isChecked }
            Button {
                isCompleting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    task.status = .completed
                    isCompleting = false
                }
            } label: {
                HStack {
                    if isCompleting { ProgressView().tint(.white) }
                    Label("Mark Service Complete", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(allChecked ? Color.green : Color.gray, in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!allChecked || isCompleting)
            .padding(.horizontal, 16)
            if !allChecked {
                Text("Complete all checklist items to mark service done")
                    .font(.caption)
                    .foregroundStyle(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        } else {
            Label("Service Completed", systemImage: "checkmark.seal.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.green, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Add Part Sheet
    private var addPartSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Input", selection: $newPartFromCatalog) {
                    Text("From Catalog").tag(true)
                    Text("Custom").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                if newPartFromCatalog {
                    List(RepairStaticData.partsCatalog, id: \.self) { part in
                        Button {
                            task.requiredParts.append(
                                InventoryItem(id: UUID(), name: part, partNumber: "", quantity: 1, isAvailable: false)
                            )
                            showAddPart = false
                        } label: {
                            Text(part).foregroundStyle(.appTextPrimary)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        TextField("Part name", text: $newPartName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 16)

                        Button {
                            guard !newPartName.isEmpty else { return }
                            task.requiredParts.append(
                                InventoryItem(id: UUID(), name: newPartName, partNumber: "", quantity: 1, isAvailable: false)
                            )
                            newPartName = ""
                            showAddPart = false
                        } label: {
                            Text("Add Part")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity).frame(height: 48)
                                .background(Color.appOrange, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 16)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Add Required Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddPart = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
