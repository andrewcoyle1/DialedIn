//
//  ExerciseDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExerciseDetailView: View {
    
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(UserManager.self) private var userManager
    
    var exerciseTemplate: ExerciseTemplateModel
    var records: [(String, String)] = [
        ("2024-05-12", "100 kg x 5 reps"),
        ("2024-04-28", "97.5 kg x 4 reps"),
        ("2024-04-14", "95 kg x 6 reps"),
        ("2024-03-30", "92.5 kg x 7 reps")
    ]
    @State var section: CustomSection = .description
    @State private var isBookmarked: Bool = false
    @State private var isFavourited: Bool = false
    
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
        .navigationSubtitle("Performed 14 times")
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
        .task {
            let user = userManager.currentUser
            // Always treat authored templates as bookmarked
            let isAuthor = user?.userId == exerciseTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false)
            isFavourited = user?.favouritedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false
        }
        .onChange(of: userManager.currentUser) { _, _ in
            let user = userManager.currentUser
            let isAuthor = user?.userId == exerciseTemplate.authorId
            isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false)
            isFavourited = user?.favouritedExerciseTemplateIds?.contains(exerciseTemplate.id) ?? false
        }
#if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
#endif
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
                // Dummy data for demonstration
                
                // TODO: This will need to be removed
                // swiftlint:disable:next large_tuple
                let dummyHistory: [(id: UUID, date: Date, reps: Int, weight: Double, notes: String?)] = [
                    (UUID(), Date().addingTimeInterval(-86400 * 2), 10, 60.0, "Felt strong, good form."),
                    (UUID(), Date().addingTimeInterval(-86400 * 5), 8, 62.5, nil),
                    (UUID(), Date().addingTimeInterval(-86400 * 10), 12, 55.0, "Tried a new grip.")
                ]
                
                if dummyHistory.isEmpty {
                    Text("No history yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(dummyHistory, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(entry.reps) reps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(entry.weight, specifier: "%.1f") kg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
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
                Text("Weight lifted over last 5 sessions")
                    .font(.subheadline)
                HStack(alignment: .bottom, spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 20, height: 40)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 20, height: 60)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 20, height: 50)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 20, height: 70)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 20, height: 65)
                }
                .padding(.vertical, 8)
                Text("60kg, 62.5kg, 61kg, 65kg, 64kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var repsProgressChart: some View {
        Section(header: Text("Reps Progress Chart")) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reps performed over last 5 sessions")
                    .font(.subheadline)
                HStack(alignment: .bottom, spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 20, height: 30)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 20, height: 35)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 20, height: 32)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 20, height: 38)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green)
                        .frame(width: 20, height: 36)
                }
                .padding(.vertical, 8)
                Text("10, 8, 12, 9, 11 reps")
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
            ImageLoaderView(urlString: url, resizingMode: .fill)
                .frame(maxWidth: .infinity, minHeight: 180)
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
