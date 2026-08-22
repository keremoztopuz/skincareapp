import SwiftUI

struct RecentsView: View {
    @Binding var selectedTab: Int
    @StateObject private var vm = RecentsViewModel()
    @State private var selectedRecord: AnalysisRecord? = nil
    @State private var showDetail = false
    @State private var isCompareMode = false
    @State private var compareRecords: [AnalysisRecord] = []
    @State private var showCompare = false
    @State private var showUpgrade = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.brandBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        if vm.records.isEmpty {
                            EmptyStateView(onScanTap: { selectedTab = 2 })
                        } else {
                            // MARK: Header
                            HStack {
                                Text(NSLocalizedString("recent_analysis", comment: ""))
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.brandText)
                                Spacer()
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isCompareMode.toggle()
                                        compareRecords = []
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: isCompareMode ? "xmark" : "arrow.left.arrow.right")
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(isCompareMode ? AppStrings.cancel : AppStrings.compare)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(.brandPrimary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.brandBlush)
                                    .cornerRadius(Radius.card)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                            if isCompareMode {
                                Text(NSLocalizedString("select_2_analyses", comment: ""))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 20)
                                    .transition(.opacity)
                            }

                            // MARK: Filter
                            Menu {
                                Button(NSLocalizedString("all_time", comment: "")) { vm.selectedFilter = "All Time" }
                                Button(NSLocalizedString("this_week", comment: "")) { vm.selectedFilter = "This Week" }
                                Button(NSLocalizedString("this_month", comment: "")) { vm.selectedFilter = "This Month" }
                            } label: {
                                HStack {
                                    Image(systemName: "calendar").font(.system(size: 16))
                                    Text(filterTitle(vm.selectedFilter)).font(.system(size: 16, weight: .medium))
                                    Spacer()
                                    Image(systemName: "chevron.down").font(.system(size: 14))
                                }
                                .foregroundColor(.brandText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(Radius.card)
                                .cardShadow()
                            }
                            .padding(.horizontal, 20)

                            // MARK: Cards
                            ForEach(vm.records, id: \.self) { record in
                                let isSelected = compareRecords.contains(record)
                                SwipeToDeleteContainer(onDelete: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        vm.deleteRecord(record)
                                    }
                                }, disabled: isCompareMode) {
                                    Button {
                                        if isCompareMode {
                                            handleCompareSelection(record)
                                        } else {
                                            selectedRecord = record
                                            showDetail = true
                                        }
                                    } label: {
                                        RecordCard(record: record, isCompareMode: isCompareMode, isSelected: isSelected)
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.spring(response: 0.2), value: isSelected)
                                }
                            }

                            // MARK: Locked Preview
                            if !vm.lockedRecords.isEmpty && !isCompareMode {
                                ZStack {
                                    VStack(spacing: 12) {
                                        ForEach(vm.lockedRecords, id: \.self) { record in
                                            RecordCard(record: record)
                                        }
                                    }
                                    .blur(radius: 8)
                                    .allowsHitTesting(false)

                                    VStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.brandBlush)
                                                .frame(width: 72, height: 72)
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 26))
                                                .foregroundColor(.brandPrimary)
                                        }
                                        .accessibilityHidden(true)

                                        Text(NSLocalizedString("see_all_analyses", comment: ""))
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.brandText)

                                        Text(NSLocalizedString("go_pro_history", comment: ""))
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)

                                        Button {
                                            showUpgrade = true
                                        } label: {
                                            HStack(spacing: 8) {
                                                Image(systemName: "crown.fill")
                                                    .font(.system(size: 14))
                                                Text(NSLocalizedString("go_pro", comment: ""))
                                                    .font(.system(size: 16, weight: .bold))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 14)
                                            .background(Color.brandPrimary)
                                            .cornerRadius(Radius.card)
                                        }
                                    }
                                    .padding(.vertical, 40)
                                }
                            }

                            if isCompareMode {
                                Color.clear.frame(height: 88)
                            }
                        }
                    }
                }

                // MARK: Compare bottom button
                if isCompareMode && compareRecords.count == 2 {
                    VStack(spacing: 0) {
                        Button {
                            showCompare = true
                        } label: {
                            Text(NSLocalizedString("compare_2", comment: ""))
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .background(Color.brandBackground.shadow(.drop(color: .black.opacity(0.07), radius: 8, y: -4)))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showUpgrade) { UpgradeSheetView() }
            .navigationDestination(isPresented: $showDetail) {
                if let record = selectedRecord {
                    ResultView(record: record, isFromRecents: true) {
                        showDetail = false
                    }
                }
            }
            .navigationDestination(isPresented: $showCompare) {
                if compareRecords.count == 2 {
                    CompareView(record1: compareRecords[0], record2: compareRecords[1])
                }
            }
        }
        .onAppear {
            vm.fetchRecords()
        }
    }

    private func handleCompareSelection(_ record: AnalysisRecord) {
        withAnimation(.spring(response: 0.2)) {
            if let idx = compareRecords.firstIndex(of: record) {
                compareRecords.remove(at: idx)
            } else if compareRecords.count < 2 {
                compareRecords.append(record)
            }
        }
    }

    private func filterTitle(_ filter: String) -> String {
        switch filter {
        case "This Week": return AppStrings.thisWeek
        case "This Month": return AppStrings.thisMonth
        default: return AppStrings.allTime
        }
    }

}

struct EmptyStateView: View {
    var onScanTap: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            BrandCircleIcon(systemImage: "camera", size: 160)

            VStack(spacing: 10) {
                Text(NSLocalizedString("no_analysis_yet", comment: ""))
                    .font(.system(size: 24, weight: .bold))
                Text(NSLocalizedString("go_to_camera", comment: ""))
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            Button(action: onScanTap) {
                HStack(spacing: 10) {
                    Image(systemName: "viewfinder").font(.system(size: 20))
                    Text(NSLocalizedString("make_first_scan", comment: "")).font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(Color.brandPrimary)
                .cornerRadius(Radius.card)
            }
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 600)
    }
}

struct SwipeToDeleteContainer<Content: View>: View {
    let onDelete: () -> Void
    let disabled: Bool
    let content: Content

    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false

    private let deleteWidth: CGFloat = 80

    init(onDelete: @escaping () -> Void, disabled: Bool = false, @ViewBuilder content: () -> Content) {
        self.onDelete = onDelete
        self.disabled = disabled
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                onDelete()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
                    Text(NSLocalizedString("delete", comment: ""))
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(width: deleteWidth)
                .frame(maxHeight: .infinity)
                .background(Color.brandPrimary)
                .cornerRadius(Radius.card)
            }
            .padding(.trailing, 20)
            .opacity(showDeleteButton ? 1 : 0)

            content
                .offset(x: offset)
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            guard !disabled else { return }
                            let translation = value.translation.width
                            if translation < 0 {
                                offset = max(translation, -deleteWidth - 20)
                            } else if showDeleteButton {
                                offset = min(-deleteWidth + translation, 0)
                            }
                        }
                        .onEnded { value in
                            guard !disabled else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if value.translation.width < -40 {
                                    offset = -deleteWidth
                                    showDeleteButton = true
                                } else {
                                    offset = 0
                                    showDeleteButton = false
                                }
                            }
                        }
                )
        }
        .clipped()
    }
}

#Preview {
    RecentsView(selectedTab: .constant(3))
}
