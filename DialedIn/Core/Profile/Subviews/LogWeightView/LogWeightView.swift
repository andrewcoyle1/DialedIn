//
//  LogWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct LogWeightView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel: LogWeightViewModel
    
    var body: some View {
        NavigationStack {
            List {
                dateSection
                unitPickerSection
                weightPickerSection
                notesSection
                recentEntriesSection
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker(
                "Date",
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
        } header: {
            Text("Date")
        } footer: {
            Text("Select the date for this weight entry")
        }
    }
    
    private var unitPickerSection: some View {
        Section {
            Picker("Units", selection: $viewModel.unit) {
                Text("Metric (kg)").tag(UnitOfWeight.kilograms)
                Text("Imperial (lbs)").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var weightPickerSection: some View {
        Section {
            if viewModel.unit == .kilograms {
                Picker("Weight", selection: $viewModel.selectedKilograms) {
                    ForEach((30...200).reversed(), id: \.self) { value in
                        Text("\(value) kg").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: viewModel.selectedKilograms) { _, newValue in
                    // Update pounds to match
                    viewModel.selectedPounds = Int(Double(newValue) * 2.20462)
                }
            } else {
                Picker("Weight", selection: $viewModel.selectedPounds) {
                    ForEach((66...440).reversed(), id: \.self) { value in
                        Text("\(value) lbs").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: viewModel.selectedPounds) { _, newValue in
                    // Update kilograms to match
                    viewModel.selectedKilograms = Int(Double(newValue) * 0.453592)
                }
            }
        } header: {
            Text("Weight")
        }
        .removeListRowFormatting()
    }
    
    private var notesSection: some View {
        Section {
            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }
    
    @ViewBuilder
    private var recentEntriesSection: some View {
        if !viewModel.weightHistory.isEmpty {
            Section {
                ForEach(viewModel.weightHistory.prefix(5)) { entry in
                    recentEntryRow(entry)
                }
            } header: {
                Text("Recent Entries")
            }
        }
    }
    
    private func recentEntryRow(_ entry: WeightEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatWeight(entry.weightKg))
                    .font(.headline)
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let notes = entry.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                Task {
                    await viewModel.saveWeight(onDismiss: {
                        dismiss()
                    })
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    LogWeightView(viewModel: LogWeightViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}

enum UnitOfWeight {
    case kilograms
    case pounds
}
