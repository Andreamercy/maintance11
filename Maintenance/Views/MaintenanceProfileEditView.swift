import SwiftUI

/// Profile edit sheet — self-contained, no external dependencies.
struct MaintenanceProfileEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var phone: String = StaticData.userProfile.email
    @State private var address: String = "42 Andheri East, Mumbai - 400069"
    @State private var emergencyContactName: String = "Priya Sharma"
    @State private var emergencyContactPhone: String = "+91 98765 43210"
    @State private var isSaving = false

    var body: some View {
        Form {
            Section("Contact") {
                TextField("Phone Number", text: $phone).keyboardType(.phonePad)
                TextField("Address", text: $address, axis: .vertical).lineLimit(2...4)
            }
            Section("Emergency Contact") {
                TextField("Contact Name", text: $emergencyContactName)
                TextField("Contact Phone", text: $emergencyContactPhone).keyboardType(.phonePad)
            }
        }
        .navigationTitle("Edit Profile")
        .tint(.appOrange)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    isSaving = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isSaving = false
                        dismiss()
                    }
                }
                .disabled(isSaving)
                .fontWeight(.semibold)
            }
        }
        .disabled(isSaving)
    }
}
