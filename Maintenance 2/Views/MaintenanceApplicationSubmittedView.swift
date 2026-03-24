import SwiftUI

/// Application submitted screen — static, no external dependencies.
struct MaintenanceApplicationSubmittedView: View {
    @State private var checkmarkProgress: CGFloat = 0
    @State private var contentAppeared = false
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            Color.appSurface.ignoresSafeArea()
            mainContent
        }
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) { checkmarkProgress = 1 }
            withAnimation(.spring(duration: 0.6, bounce: 0.2).delay(0.8)) { contentAppeared = true }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 40)

                // Animated checkmark
                ZStack {
                    Circle()
                        .strokeBorder(Color.appOrange.opacity(0.2), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: checkmarkProgress)
                        .stroke(Color.appOrange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.appOrange)
                        .opacity(checkmarkProgress)
                }
                .frame(width: 100, height: 100)

                VStack(spacing: 10) {
                    Text("Application Submitted!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.appTextPrimary)

                    Text("Your technician profile is under review.\nA fleet administrator will verify your credentials shortly.")
                        .font(.subheadline)
                        .foregroundStyle(.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                .opacity(contentAppeared ? 1 : 0)
                .offset(y: contentAppeared ? 0 : 20)

                // Status card
                HStack(spacing: 12) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.appOrange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Status").font(.caption2).foregroundStyle(.appTextSecondary)
                        Text("Pending Review").font(.system(size: 16, weight: .semibold)).foregroundStyle(.appTextPrimary)
                    }
                    Spacer()
                    Text("Pending")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.appOrange)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.appOrange.opacity(0.1), in: Capsule())
                }
                .padding(18)
                .background(Color.appCardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                .padding(.horizontal, 24)
                .opacity(contentAppeared ? 1 : 0)

                // Refresh button
                Button {
                    withAnimation { isRefreshing = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isRefreshing = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isRefreshing {
                            ProgressView().scaleEffect(0.8).tint(.appOrange)
                        } else {
                            Image(systemName: "arrow.clockwise").font(.subheadline)
                        }
                        Text(isRefreshing ? "Checking…" : "Refresh Status").font(.subheadline)
                    }
                    .foregroundStyle(.appOrange)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(Color.appOrange.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.appOrange.opacity(0.15), lineWidth: 1))
                }
                .disabled(isRefreshing)
                .padding(.horizontal, 24)
                .opacity(contentAppeared ? 1 : 0)

                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    MaintenanceApplicationSubmittedView()
}
