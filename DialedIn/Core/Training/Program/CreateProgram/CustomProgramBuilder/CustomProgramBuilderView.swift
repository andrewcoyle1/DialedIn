//
//  CustomProgramBuilderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import CustomRouting

struct CustomProgramBuilderView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var viewModel: CustomProgramBuilderViewModel

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
        .onChange(of: viewModel.durationWeeks) { _, newValue in
            viewModel.resizeWeeks(to: newValue)
        }
        .onAppear {
            viewModel.resizeWeeks(to: viewModel.durationWeeks)
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                viewModel.dismissScreen()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await viewModel.saveTemplate()
                }
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .disabled(!viewModel.canContinue)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.onStartProgramPressed()
            } label: {
                Label("Start…", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canContinue)
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Program name", text: $viewModel.name)
            TextField("Description (optional)", text: $viewModel.descriptionText, axis: .vertical)
                .lineLimit(1...4)
            Stepper(value: $viewModel.durationWeeks, in: 1...52) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(viewModel.durationWeeks) week\(viewModel.durationWeeks == 1 ? "" : "s")")
                        .foregroundStyle(.secondary)
                }
            }
            Picker("Difficulty", selection: $viewModel.difficulty) {
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
                isSelected: { viewModel.selectedFocusAreas.contains($0) },
                toggle: { area in
                    if viewModel.selectedFocusAreas.contains(area) {
                        viewModel.selectedFocusAreas.remove(area)
                    } else {
                        viewModel.selectedFocusAreas.insert(area)
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
            CarouselView(items: viewModel.weeks) { week in
                weekSchedule(week: week)
            } onSelectionChange: { selectedWeek in
                if let selectedWeek = selectedWeek {
                    viewModel.selectedWeek = selectedWeek.weekNumber
                }
            }
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Schedule")
                Spacer()
                if viewModel.selectedWeek > 1 {
                    Button {
                        viewModel.showingCopyWeekPicker = true
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                }
                Text("Week \(viewModel.selectedWeek)")
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
                    if let selection = viewModel.weeks[safe: viewModel.selectedWeek - 1]?.mappings[day] {
                        Button {
                            viewModel.editingDayOfWeek = day
                            viewModel.onWorkoutPickerPressed(day: day)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "dumbbell.fill")
                                Text(selection.name)
                            }
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Button {
                            viewModel.editingDayOfWeek = day
                            viewModel.onWorkoutPickerPressed(day: day)
                        } label: {
                            Label("Select Workout", systemImage: "plus.circle")
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            Toggle("Deload week", isOn: Binding(
                get: { viewModel.weeks[safe: viewModel.selectedWeek - 1]?.isDeloadWeek ?? false },
                set: { newValue in
                    if let index = viewModel.weeks.firstIndex(where: { $0.weekNumber == viewModel.selectedWeek }) {
                        viewModel.weeks[index].isDeloadWeek = newValue
                    }
                }
            ))
            
            TextField("Notes (optional)", text: Binding(
                get: { viewModel.weeks[safe: viewModel.selectedWeek - 1]?.notes ?? "" },
                set: { newValue in
                    if let index = viewModel.weeks.firstIndex(where: { $0.weekNumber == viewModel.selectedWeek }) {
                        viewModel.weeks[index].notes = newValue
                    }
                }
            ), axis: .vertical)
            .lineLimit(1...3)
        }
        .padding()
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
