//
//  ExerciseDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExerciseDetailView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(ExerciseHistoryManager.self) private var exerciseHistoryManager
    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseUnitPreferenceManager.self) private var unitPreferenceManager
    
    var exerciseTemplate: ExerciseTemplateModel
    @State private var history: [ExerciseHistoryEntryModel] = []
    @State private var records: [(String, String)] = []
    @State private var isLoadingHistory: Bool = false
    @State var section: CustomSection = .description
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    @State private var unitPreference: ExerciseUnitPreference?
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    enum CustomSection: Hashable {
        case description
        case history
        case charts
        case records
    }
    var body: some View {
        List {
            pickerSection
            switch section {
            case .description:
                aboutSection
            case .history:
                historySection
            case .charts:
                chartsSection
            case .records:
                recordsSection
            }
        }
        .navigationTitle(exerciseTemplate.name)
        .navigationSubtitle(performedSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $showAlert)
        .toolbar {
            #if DEBUG || MOCK
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
            #endif
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await onFavoritePressed()
                    }
                } label: {
                    Image(systemName: isFavourited ? "heart.fill" : "heart")
                }
            }
            // Hide bookmark button when the current user is the author
            if userManager.currentUser?.userId != nil && userManager.currentUser?.userId != exerciseTemplate.authorId {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await onBookmarkPressed()
                        }
                    } label: {
                        Image(systemName: isBookmarked ? "book.closed.fill" : "book.closed")
                    }
                }
            }
        }
        .task { await loadInitialState() }
        .onChange(of: userManager.currentUser) { _, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == exerciseTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false)
            isFavourited = user?.favouritedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
    }
    private var performedSubtitle: String {
        if isLoadingHistory { return "Loading…" }
        let count = history.count
        if count == 0 { return "No history yet" }
        if count == 1 { return "Performed 1 time" }
        return "Performed \(count) times"
    }

    private func loadInitialState() async {
        let user = userManager.currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == exerciseTemplate.authorId
        isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false)
        isFavourited = user?.favouritedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false
        // Load unit preferences for this exercise
        unitPreference = unitPreferenceManager.getPreference(for: exerciseTemplate.id)
        await loadHistory()
    }

    private func loadHistory() async {
        guard let userId = userManager.currentUser?.userId else { return }
        isLoadingHistory = true
        do {
            var filtered: [ExerciseHistoryEntryModel] = []
            // Remote by author, filter by template
            let remoteItems = try await exerciseHistoryManager.getExerciseHistoryForAuthor(authorId: userId, limitTo: 200)
            filtered = remoteItems.filter { $0.templateId == exerciseTemplate.id }
            // Fallback to local cache if remote empty
            if filtered.isEmpty {
                if let localItems = try? exerciseHistoryManager.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
                    filtered = localItems.filter { $0.authorId == userId }
                }
            }
            await MainActor.run {
                history = filtered
                records = buildRecords(from: filtered)
                isLoadingHistory = false
            }
        } catch {
            // Try local on error
            if let localItems = try? exerciseHistoryManager.getLocalExerciseHistoryForTemplate(templateId: exerciseTemplate.id, limitTo: 200) {
                let filtered = localItems.filter { $0.authorId == userId }
                await MainActor.run {
                    history = filtered
                    records = buildRecords(from: filtered)
                    isLoadingHistory = false
                }
            } else {
                await MainActor.run { isLoadingHistory = false }
            }
        }
    }

    private func buildRecords(from entries: [ExerciseHistoryEntryModel]) -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Simple record sample: best weight x reps from first set of each entry
        // You can refine to compute 1RM, best volume, etc.
        let tuples: [(String, String)] = entries.compactMap { entry in
            guard let first = entry.sets.first else { return nil }
            let dateStr = formatter.string(from: entry.performedAt)
            if let weight = first.weightKg, let reps = first.reps {
                return (dateStr, String(format: "%.0f kg x %d reps", weight, reps))
            } else if let reps = first.reps {
                return (dateStr, "Reps: \(reps)")
            } else if let durationSec = first.durationSec {
                return (dateStr, "Duration: \(durationSec)s")
            } else if let distanceMeters = first.distanceMeters {
                return (dateStr, String(format: "%.0f m", distanceMeters))
            }
            return (dateStr, "Completed")
        }
        return tuples
    }
    
    private func authorSection(id: String) -> some View {
        Section(header: Text("Author ID")) {
            Text(id)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    private func onBookmarkPressed() async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await exerciseTemplateManager.favouriteExerciseTemplate(id: exerciseTemplate.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            try await exerciseTemplateManager.bookmarkExerciseTemplate(id: exerciseTemplate.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
            } else {
                try await userManager.removeBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    private func onFavoritePressed() async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await exerciseTemplateManager.bookmarkExerciseTemplate(id: exerciseTemplate.id, isBookmarked: true)
                try await userManager.addBookmarkedExerciseTemplate(exerciseId: exerciseTemplate.id)
                isBookmarked = true
            }
            try await exerciseTemplateManager.favouriteExerciseTemplate(id: exerciseTemplate.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            } else {
                try await userManager.removeFavouritedExerciseTemplate(exerciseId: exerciseTemplate.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
}

#Preview("About Section") {
    NavigationStack {
        ExerciseDetailView(exerciseTemplate: ExerciseTemplateModel.mocks[0])
    }
    .previewEnvironment()
}

#Preview("History Section") {
    NavigationStack {
        ExerciseDetailView(exerciseTemplate: ExerciseTemplateModel.mocks[0], section: .history)
    }
    .previewEnvironment()
}

#Preview("Charts Section") {
    NavigationStack {
        ExerciseDetailView(exerciseTemplate: ExerciseTemplateModel.mocks[0], section: .charts)
    }
    .previewEnvironment()
}

#Preview("Records Section") {
    NavigationStack {
        ExerciseDetailView(exerciseTemplate: ExerciseTemplateModel.mocks[0], section: .records)
    }
    .previewEnvironment()
}

extension ExerciseDetailView {
    
    private var aboutSection: some View {
        Group {
            if let url = exerciseTemplate.imageURL {
                imageSection(url: url)
            }
            
            if let description = exerciseTemplate.description {
                descriptionSection(description: description)
            }
            
            if !exerciseTemplate.instructions.isEmpty {
                instructionsSection
            }
            
            if !exerciseTemplate.muscleGroups.isEmpty {
                muscleGroupsSection
            }
            
            categorySection
            
            dateCreatedSection
            if let authorId = exerciseTemplate.authorId {
                authorSection(id: authorId)
            }
        }
    }
    
    private var historySection: some View {
        Group {
            Section(header: Text("History")) {
                if isLoadingHistory {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if history.isEmpty {
                    Text("No history yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(history, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.performedAt, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if let first = entry.sets.first {
                                    if let reps = first.reps { Text("\(reps) reps").font(.caption).foregroundColor(.secondary) }
                                    if let weightKg = first.weightKg, let pref = unitPreference {
                                        let displayWeight = UnitConversion.formatWeight(weightKg, unit: pref.weightUnit)
                                        Text("\(displayWeight) \(pref.weightUnit.abbreviation)").font(.caption).foregroundColor(.secondary)
                                    }
                                }
                            }
                            if let notes = entry.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    private var chartsSection: some View {
        Group {
            weightProgressChart
            repsProgressChart
        }
    }
    
    private var weightProgressChart: some View {
        Section(header: Text("Weight Progress Chart")) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Weight lifted over last sessions")
                    .font(.subheadline)
                let weights: [Double] = history.compactMap { $0.sets.first?.weightKg }
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(weights.enumerated()), id: \.offset) { _, weightKg in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 20, height: CGFloat(max(10, min(100, weightKg))))
                    }
                }
                .padding(.vertical, 8)
                if let pref = unitPreference {
                    Text(weights.map { UnitConversion.formatWeight($0, unit: pref.weightUnit) + pref.weightUnit.abbreviation }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(weights.map { String(format: "%.1fkg", $0) }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var repsProgressChart: some View {
        Section(header: Text("Reps Progress Chart")) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reps performed over last sessions")
                    .font(.subheadline)
                let reps: [Int] = history.compactMap { $0.sets.first?.reps }
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(reps.enumerated()), id: \.offset) { _, reps in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green)
                            .frame(width: 20, height: CGFloat(max(10, min(100, reps * 5))))
                    }
                }
                .padding(.vertical, 8)
                Text(reps.map { String($0) }.joined(separator: ", ") + " reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var recordsSection: some View {
        Group {
            personalBestSubSection
            
            recentRecordsSubSection
            
            allTimeStatsSubSection
        }
    }
    
    private var personalBestSubSection: some View {
        Section {
            HStack {
                VStack {
                    
                    Text("100 kg x 5 reps")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Achieved on 2024-05-12")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack {
                    Text("1RM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("112 kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text("Personal Best")
        }
    }
    
    private var recentRecordsSubSection: some View {
        Section {
            ForEach(records, id: \.0) { date, record in
                HStack {
                    Text(record)
                        .font(.body)
                    Spacer()
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        } header: {
            Text("Recent Records")
        }
    }
    
    private var allTimeStatsSubSection: some View {
        Section {
            HStack(spacing: 24) {
                VStack {
                    Text("Total Sets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("124")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                VStack {
                    Text("Total Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("812")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                VStack {
                    Text("Total Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("72,500 kg")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        } header: {
            Text("All-Time Stats")
        }
        .padding(.vertical, 8)
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Section", selection: $section) {
                Text("About").tag(CustomSection.description)
                Text("History").tag(CustomSection.history)
                Text("Charts").tag(CustomSection.charts)
                Text("Records").tag(CustomSection.records)
            }
            .pickerStyle(.segmented)
        }
        .listSectionSpacing(0)
        .removeListRowFormatting()
    }
    
    private func imageSection(url: String) -> some View {
        Section {
            if url.starts(with: "http://") || url.starts(with: "https://") {
                ImageLoaderView(urlString: url, resizingMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 250)

            } else {
                // Treat as bundled asset name
                Image(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 250)

            }
            
            // ImageLoaderView(urlString: url, resizingMode: .fill)
        }
        .removeListRowFormatting()
    }
    
    private func descriptionSection(description: String) -> some View {
        Section(header: Text("Description")) {
            Text(description)
                .font(.body)
        }
    }
    
    private var instructionsSection: some View {
        Section(header: Text("Instructions")) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(exerciseTemplate.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .fontWeight(.semibold)
                        Text(instruction)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var muscleGroupsSection: some View {
        Section(header: Text("Muscle Groups")) {
            let columns = [GridItem(.adaptive(minimum: 90), spacing: 8, alignment: .leading)]
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(exerciseTemplate.muscleGroups, id: \.self) { group in
                    Text(group.description)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var categorySection: some View {
        Section(header: Text("Category")) {
            Text(exerciseTemplate.type.description)
        }
    }
    
    private var dateCreatedSection: some View {
        Section(header: Text("Date Created")) {
            Text(exerciseTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
        }
    }
}
