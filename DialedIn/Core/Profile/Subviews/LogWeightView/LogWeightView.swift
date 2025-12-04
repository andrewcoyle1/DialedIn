//
//  LogWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct LogWeightView: View {

    @State var presenter: LogWeightPresenter
    
    var body: some View {
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
        .task {
            await presenter.loadInitialData()
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker(
                "Date",
                selection: $presenter.selectedDate,
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
            Picker("Units", selection: $presenter.unit) {
                Text("Metric (kg)").tag(UnitOfWeight.kilograms)
                Text("Imperial (lbs)").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var weightPickerSection: some View {
        Section {
            if presenter.unit == .kilograms {
                Picker("Weight", selection: $presenter.selectedKilograms) {
                    ForEach((30...200).reversed(), id: \.self) { value in
                        Text("\(value) kg").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedKilograms) { _, newValue in
                    // Update pounds to match
                    presenter.selectedPounds = Int(Double(newValue) * 2.20462)
                }
            } else {
                Picker("Weight", selection: $presenter.selectedPounds) {
                    ForEach((66...440).reversed(), id: \.self) { value in
                        Text("\(value) lbs").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedPounds) { _, newValue in
                    // Update kilograms to match
                    presenter.selectedKilograms = Int(Double(newValue) * 0.453592)
                }
            }
        } header: {
            Text("Weight")
        }
        .removeListRowFormatting()
    }
    
    private var notesSection: some View {
        Section {
            TextField("Notes (optional)", text: $presenter.notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }
    
    @ViewBuilder
    private var recentEntriesSection: some View {
        if !presenter.weightHistory.isEmpty {
            Section {
                ForEach(presenter.weightHistory.prefix(5)) { entry in
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
                Text(presenter.formatWeight(entry.weightKg))
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
                presenter.onDismissPressed()
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                Task {
                    await presenter.saveWeight()
                }
            }
            .disabled(presenter.isLoading)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.logWeightView(router: router)
    }
    .previewEnvironment()
}
