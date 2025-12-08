//
//  CustomProgramBuilderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct CustomProgramBuilderView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var presenter: CustomProgramBuilderPresenter

    var body: some View {
        List {
            detailsSection
            focusAreasSection
            scheduleSection
        }
        .navigationTitle("Custom Program")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar { toolbarContent }
        .onChange(of: presenter.durationWeeks) { _, newValue in
            presenter.resizeWeeks(to: newValue)
        }
        .onAppear {
            presenter.resizeWeeks(to: presenter.durationWeeks)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
            
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await presenter.saveTemplate()
                }
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(!presenter.canContinue)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onStartProgramPressed()
            } label: {
                Label("Start…", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!presenter.canContinue)
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Program name", text: $presenter.name)
            TextField("Description (optional)", text: $presenter.descriptionText, axis: .vertical)
                .lineLimit(1...4)
            Stepper(value: $presenter.durationWeeks, in: 1...52) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(presenter.durationWeeks) week\(presenter.durationWeeks == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                }
            }
            Picker("Difficulty", selection: $presenter.difficulty) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    Label(level.description, systemImage: level.systemImage)
                        .tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var focusAreasSection: some View {
        Section {
            WrappingChips(
                items: FocusArea.allCases,
                isSelected: { presenter.selectedFocusAreas.contains($0) },
                toggle: { area in
                    if presenter.selectedFocusAreas.contains(area) {
                        presenter.selectedFocusAreas.remove(area)
                    } else {
                        presenter.selectedFocusAreas.insert(area)
                    }
                },
                label: { area in
                    HStack(spacing: 6) {
                        Image(systemName: area.systemImage)
                        Text(area.description)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            )
            .removeListRowFormatting()
        } header: {
            Text("Focus Areas")
        } footer: {
            Text("Choose one or more areas to emphasize")
        }
    }
    
    private var scheduleSection: some View {
        Section {
            CarouselView(items: presenter.weeks) { week in
                weekSchedule(week: week)
            } onSelectionChange: { selectedWeek in
                if let selectedWeek = selectedWeek {
                    presenter.selectedWeek = selectedWeek.weekNumber
                }
            }
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Schedule")
                Spacer()
                if presenter.selectedWeek > 1 {
                    Button {
                        presenter.onCopyWeekPickerPressed()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                }
                Text("Week \(presenter.selectedWeek)")
                    .font(.subheadline)
            }
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func weekSchedule(week: WeekScheduleState) -> some View {
        VStack(spacing: 12) {
            let days: [(Int, String)] = [
                (1, "Sunday"), (2, "Monday"), (3, "Tuesday"), (4, "Wednesday"),
                (5, "Thursday"), (6, "Friday"), (7, "Saturday")
            ]
            
            ForEach(days, id: \.0) { (day, label) in
                HStack {
                    Text(label)
                    Spacer()
                    if let selection = presenter.weeks[safe: presenter.selectedWeek - 1]?.mappings[day] {
                        Button {
                            presenter.editingDayOfWeek = day
                            presenter.onWorkoutPickerPressed(day: day)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "dumbbell.fill")
                                Text(selection.name)
                            }
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Button {
                            presenter.editingDayOfWeek = day
                            presenter.onWorkoutPickerPressed(day: day)
                        } label: {
                            Label("Select Workout", systemImage: "plus.circle")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Toggle("Deload week", isOn: Binding(
                get: { presenter.weeks[safe: presenter.selectedWeek - 1]?.isDeloadWeek ?? false },
                set: { newValue in
                    if let index = presenter.weeks.firstIndex(where: { $0.weekNumber == presenter.selectedWeek }) {
                        presenter.weeks[index].isDeloadWeek = newValue
                    }
                }
            ))
            
            TextField("Notes (optional)", text: Binding(
                get: { presenter.weeks[safe: presenter.selectedWeek - 1]?.notes ?? "" },
                set: { newValue in
                    if let index = presenter.weeks.firstIndex(where: { $0.weekNumber == presenter.selectedWeek }) {
                        presenter.weeks[index].notes = newValue
                    }
                }
            ), axis: .vertical)
            .lineLimit(1...3)
        }
        .padding()
    }
}

extension CoreBuilder {
    func customProgramBuilderView(router: AnyRouter) -> some View {
        CustomProgramBuilderView(
            presenter: CustomProgramBuilderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {
    func showCustomProgramBuilderView() {
        router.showScreen(.push) { router in
            builder.customProgramBuilderView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.customProgramBuilderView(router: router)
    }
    .previewEnvironment()
}

// MARK: - Local Types and Helpers

private extension Array {
    subscript(safe index: Int) -> Element? {
        (indices).contains(index) ? self[index] : nil
    }
}

// MARK: - WrappingChips

private struct WrappingChips<Item: Hashable>: View {
    let items: [Item]
    let isSelected: (Item) -> Bool
    let toggle: (Item) -> Void
    let label: (Item) -> any View
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    toggle(item)
                } label: {
                    HStack(spacing: 6) {
                        AnyView(label(item))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isSelected(item) ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.12))
                    .foregroundStyle(isSelected(item) ? Color.accent : Color.primary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
