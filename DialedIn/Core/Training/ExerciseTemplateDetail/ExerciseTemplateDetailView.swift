//
//  ExerciseDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct ExerciseTemplateDetailView: View {

    @State var presenter: ExerciseTemplateDetailPresenter

    var delegate: ExerciseTemplateDetailDelegate

    var body: some View {
        List {
            pickerSection
            switch presenter.section {
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
        .navigationTitle(delegate.exerciseTemplate.name)
        .navigationSubtitle(presenter.performedSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .task { await presenter.loadInitialState(exerciseTemplate: delegate.exerciseTemplate) }
        .onChange(of: presenter.currentUser) { _, _ in
            let user = presenter.currentUser
            let isAuthor = user?.userId == delegate.exerciseTemplate.authorId
            presenter.isBookmarked = isAuthor || (user?.bookmarkedExerciseTemplateIds?.contains(delegate.exerciseTemplate.id) ?? false) || (user?.createdExerciseTemplateIds?.contains(delegate.exerciseTemplate.id) ?? false)
            presenter.isFavourited = user?.favouritedExerciseTemplateIds?.contains(delegate.exerciseTemplate.id) ?? false
        }
    }
    
    private var aboutSection: some View {
        Group {
            if let url = delegate.exerciseTemplate.imageURL {
                imageSection(url: url)
            }
            
            if let description = delegate.exerciseTemplate.description {
                descriptionSection(description: description)
            }
            
            if !delegate.exerciseTemplate.instructions.isEmpty {
                instructionsSection
            }
            
            if !delegate.exerciseTemplate.muscleGroups.isEmpty {
                muscleGroupsSection
            }
            
            categorySection
            
            dateCreatedSection
            if let authorId = delegate.exerciseTemplate.authorId {
                authorSection(id: authorId)
            }
        }
    }
    
    private var historySection: some View {
        Group {
            Section(header: Text("History")) {
                if presenter.isLoadingHistory {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if presenter.history.isEmpty {
                    Text("No history yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(presenter.history, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.performedAt, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if let first = entry.sets.first {
                                    if let reps = first.reps { Text("\(reps) reps").font(.caption).foregroundColor(.secondary) }
                                    if let weightKg = first.weightKg, let pref = presenter.unitPreference {
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
                let weights: [Double] = presenter.history.compactMap { $0.sets.first?.weightKg }
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(weights.enumerated()), id: \.offset) { _, weightKg in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 20, height: CGFloat(max(10, min(100, weightKg))))
                    }
                }
                .padding(.vertical, 8)
                if let pref = presenter.unitPreference {
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
                let reps: [Int] = presenter.history.compactMap { $0.sets.first?.reps }
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
            ForEach(presenter.records, id: \.0) { date, record in
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
            Picker("Section", selection: $presenter.section) {
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
                ForEach(Array(delegate.exerciseTemplate.instructions.enumerated()), id: \.offset) { index, instruction in
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
                ForEach(delegate.exerciseTemplate.muscleGroups, id: \.self) { group in
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
            Text(delegate.exerciseTemplate.type.description)
        }
    }
    
    private var dateCreatedSection: some View {
        Section(header: Text("Date Created")) {
            Text(delegate.exerciseTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
        }
    }
    
    private func authorSection(id: String) -> some View {
        Section(header: Text("Author ID")) {
            Text(id)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await presenter.onFavoritePressed(exerciseTemplate: delegate.exerciseTemplate)
                }
            } label: {
                Image(systemName: presenter.isFavourited ? "heart.fill" : "heart")
            }
        }
        // Hide bookmark button when the current user is the author
        if presenter.currentUser?.userId != nil && presenter.currentUser?.userId != delegate.exerciseTemplate.authorId {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await presenter.onBookmarkPressed(exerciseTemplate: delegate.exerciseTemplate)
                    }
                } label: {
                    Image(systemName: presenter.isBookmarked ? "book.closed.fill" : "book.closed")
                }
            }
        }
    }
}

extension CoreBuilder {
    func exerciseTemplateDetailView(router: AnyRouter, delegate: ExerciseTemplateDetailDelegate) -> some View {
        ExerciseTemplateDetailView(
            presenter: ExerciseTemplateDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.exerciseTemplateDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview("About Section") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.exerciseTemplateDetailView(
            router: router,
            delegate: ExerciseTemplateDetailDelegate(
                exerciseTemplate: ExerciseTemplateModel.mocks[0]
            )
        )
    }
    .previewEnvironment()
}
