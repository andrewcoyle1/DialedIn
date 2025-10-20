//
//  LogWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct LogWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    @Environment(UserWeightManager.self) private var weightManager
    
    @State private var selectedDate = Date()
    @State private var selectedKilograms: Int = 70
    @State private var selectedPounds: Int = 154
    @State private var notes: String = ""
    @State private var unit: UnitOfWeight = .kilograms
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    enum UnitOfWeight {
        case kilograms
        case pounds
    }
    
    private var weightKg: Double {
        switch unit {
        case .kilograms:
            return Double(selectedKilograms)
        case .pounds:
            return Double(selectedPounds) * 0.453592
        }
    }
    
    init() {
        // Initialize with user's unit preference
    }
    
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
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadInitialData()
            }
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker(
                "Date",
                selection: $selectedDate,
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
            Picker("Units", selection: $unit) {
                Text("Metric (kg)").tag(UnitOfWeight.kilograms)
                Text("Imperial (lbs)").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var weightPickerSection: some View {
        Section {
            if unit == .kilograms {
                Picker("Weight", selection: $selectedKilograms) {
                    ForEach((30...200).reversed(), id: \.self) { value in
                        Text("\(value) kg").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: selectedKilograms) { _, newValue in
                    // Update pounds to match
                    selectedPounds = Int(Double(newValue) * 2.20462)
                }
            } else {
                Picker("Weight", selection: $selectedPounds) {
                    ForEach((66...440).reversed(), id: \.self) { value in
                        Text("\(value) lbs").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: selectedPounds) { _, newValue in
                    // Update kilograms to match
                    selectedKilograms = Int(Double(newValue) * 0.453592)
                }
            }
        } header: {
            Text("Weight")
        }
        .removeListRowFormatting()
    }
    
    private var notesSection: some View {
        Section {
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }
    
    @ViewBuilder
    private var recentEntriesSection: some View {
        if !weightManager.weightHistory.isEmpty {
            Section {
                ForEach(weightManager.weightHistory.prefix(5)) { entry in
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
                Text(formatWeight(entry.weightKg))
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
                    await saveWeight()
                }
            }
            .disabled(isLoading)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadInitialData() async {
        guard let user = userManager.currentUser else { return }
        
        // Set initial unit based on user preference
        if let preference = user.weightUnitPreference {
            unit = preference == .kilograms ? .kilograms : .pounds
        }
        
        // Set initial weight to current weight if available
        if let currentWeight = user.weightKilograms {
            selectedKilograms = Int(currentWeight)
            selectedPounds = Int(currentWeight * 2.20462)
        }
        
        // Load recent entries
        do {
            try await weightManager.getWeightHistory(userId: user.userId, limit: 5)
        } catch {
            // Silently fail - not critical for logging new weight
        }
    }
    
    private func saveWeight() async {
        guard let user = userManager.currentUser else { return }
        
        isLoading = true
        
        do {
            // Save weight entry
            try await weightManager.logWeight(
                weightKg,
                date: selectedDate,
                notes: notes.isEmpty ? nil : notes,
                userId: user.userId
            )
            
            // Update user's current weight
            try await userManager.updateWeight(userId: user.userId, weightKg: weightKg)
            
            // Success haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func formatWeight(_ weightKg: Double) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
}

#Preview {
    LogWeightView()
        .previewEnvironment()
}
