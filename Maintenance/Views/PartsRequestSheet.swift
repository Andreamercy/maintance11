import SwiftUI

struct PartsRequestSheet: View {
    let task: RepairTask
    var onSubmit: ([RequestedPart]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var requestedParts: [RequestedPart] = []
    @State private var isSubmitting = false

    private let catalog = RepairStaticData.partsCatalog

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appSurface.ignoresSafeArea()
                VStack(spacing: 0) {
                    headerBanner
                    inventoryList
                    addPartButton
                    if !requestedParts.isEmpty {
                        submitButton
                    }
                }
            }
            .navigationTitle("Request Parts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header
    private var headerBanner: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(task.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.appTextPrimary)
            Text("Inventory requirements below. Add any additional parts needed and submit to admin.")
                .font(.caption)
                .foregroundStyle(.appTextSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appOrange.opacity(0.08))
    }

    // MARK: - Pre-listed inventory requirements
    private var inventoryList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !task.inventoryRequirements.isEmpty {
                    sectionHeader("Inventory Requirements")
                    ForEach(task.inventoryRequirements) { item in
                        inventoryRow(item)
                        Divider().padding(.leading, 16)
                    }
                }

                if !requestedParts.isEmpty {
                    sectionHeader("Additional Parts Requested")
                    ForEach($requestedParts) { $part in
                        partEditRow(part: $part)
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color.appCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(.appTextSecondary)
            .kerning(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inventoryRow(_ item: InventoryItem) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(item.isAvailable ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline).foregroundStyle(.appTextPrimary)
                Text(item.partNumber).font(.system(size: 10, design: .monospaced)).foregroundStyle(.appTextSecondary)
            }
            Spacer()
            Text("x\(item.quantity)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.appTextSecondary)
            Text(item.isAvailable ? "Available" : "Missing")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(item.isAvailable ? Color.green : Color.red, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Part Edit Row
    private func partEditRow(part: Binding<RequestedPart>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if part.wrappedValue.isFromDropdown {
                // Dropdown mode
                Menu {
                    ForEach(catalog, id: \.self) { catItem in
                        Button(catItem) {
                            part.name.wrappedValue = catItem
                        }
                    }
                    Button("Other (type below)") {
                        part.isFromDropdown.wrappedValue = false
                        part.name.wrappedValue = ""
                    }
                } label: {
                    HStack {
                        Text(part.wrappedValue.name.isEmpty ? "Select part…" : part.wrappedValue.name)
                            .foregroundStyle(part.wrappedValue.name.isEmpty ? .appTextSecondary : .appTextPrimary)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "chevron.down").font(.caption).foregroundStyle(.appTextSecondary)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appDivider, lineWidth: 1))
                }
            } else {
                HStack {
                    TextField("Type part name…", text: part.name)
                        .font(.subheadline)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appDivider, lineWidth: 1))
                    Button {
                        part.isFromDropdown.wrappedValue = true
                    } label: {
                        Image(systemName: "list.bullet").foregroundStyle(.appOrange)
                    }
                }
            }

            HStack(spacing: 10) {
                TextField("Part #", text: part.partNumber)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appDivider, lineWidth: 1))
                    .frame(maxWidth: 110)

                Stepper("Qty: \(part.wrappedValue.quantity)", value: part.quantity, in: 1...99)
                    .font(.caption)
            }

            TextField("Reason (optional)", text: part.reason)
                .font(.caption)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(Color.appSurface, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.appDivider, lineWidth: 1))

            Button(role: .destructive) {
                requestedParts.removeAll { $0.id == part.wrappedValue.id }
            } label: {
                Label("Remove", systemImage: "trash")
                    .font(.caption).foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Add Part
    private var addPartButton: some View {
        Button {
            requestedParts.append(
                RequestedPart(name: "", partNumber: "", quantity: 1, reason: "", isFromDropdown: true)
            )
        } label: {
            Label("Add Required Part", systemImage: "plus.circle.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.appOrange)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.appOrange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.appOrange.opacity(0.25), lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Submit
    private var submitButton: some View {
        Button {
            isSubmitting = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onSubmit(requestedParts.filter { !$0.name.isEmpty })
                isSubmitting = false
                dismiss()
            }
        } label: {
            HStack {
                if isSubmitting { ProgressView().tint(.white) }
                Label("Submit to Admin", systemImage: "paperplane.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.appOrange, in: RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSubmitting || requestedParts.filter { !$0.name.isEmpty }.isEmpty)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
