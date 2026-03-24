import SwiftUI

/// Spare parts request sheet — static data, no external dependencies.
struct SparePartsRequestSheet: View {

    let maintenanceTaskId: UUID
    let workOrderId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var partName = ""
    @State private var partNumber = ""
    @State private var quantity = 1
    @State private var estimatedCost: Double? = nil
    @State private var supplier = ""
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var submittedRequests: [LocalSparePartsRequest] = []
    @State private var showSuccess = false

    struct LocalSparePartsRequest: Identifiable {
        let id = UUID()
        let partName: String
        let quantity: Int
        let reason: String
        let status: String
    }

    private var canSubmit: Bool {
        !partName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reason.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                Section("New Request") {
                    TextField("Part Name *", text: $partName)
                    TextField("Part Number", text: $partNumber)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                    HStack {
                        Text("Est. Unit Cost")
                        Spacer()
                        TextField("₹", value: $estimatedCost, format: .number)
                            .multilineTextAlignment(.trailing).frame(width: 100)
                    }
                    TextField("Supplier", text: $supplier)
                    TextField("Reason *", text: $reason)
                }

                Section {
                    Button {
                        submitRequest()
                    } label: {
                        HStack {
                            Spacer()
                            if isSubmitting { ProgressView().tint(.white) }
                            Text("Submit Request").font(.subheadline.weight(.semibold))
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(canSubmit ? Color.appOrange : Color.gray)
                    }
                    .disabled(!canSubmit || isSubmitting)
                }

                if !submittedRequests.isEmpty {
                    Section("Submitted Requests") {
                        ForEach(submittedRequests) { req in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(req.partName).font(.subheadline.weight(.medium))
                                    Spacer()
                                    Text(req.status)
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color.appOrange, in: Capsule())
                                }
                                Text("Qty: \(req.quantity) • \(req.reason)")
                                    .font(.caption).foregroundStyle(.appTextSecondary).lineLimit(1)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Spare Parts")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.appOrange)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func submitRequest() {
        isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            submittedRequests.append(LocalSparePartsRequest(
                partName: partName,
                quantity: quantity,
                reason: reason,
                status: "Pending"
            ))
            partName = ""; partNumber = ""; quantity = 1; estimatedCost = nil; supplier = ""; reason = ""
            isSubmitting = false
        }
    }
}
