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

            definitionSection

            if !delegate.exerciseTemplate.muscleGroups.isEmpty {
                targetMusclesSection
            }

            movementQualitySection

            resistanceEquipmentSection
            supportEquipmentSection

            detailsSection
            
            #if DEBUG
            metadataSection
            #endif
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
    
    private var definitionSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise Name")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.name)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Trackable Metrics")
                    .fontWeight(.semibold)
                Spacer()
                Text(trackableMetricString)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Type")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.type?.name ?? "None")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Laterality")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.laterality?.name ?? "None")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Bodyweight")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.isBodyweight ? "Yes" : "No")
            }
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Definition")
                Spacer()
                Text("Template")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var targetMusclesSection: some View {
        let muscles = Array(delegate.exerciseTemplate.muscleGroups).sorted { $0.key.name < $1.key.name }
        return Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(muscles, id: \.key) { muscle, isSecondary in
                        Text("\(muscle.name): \(isSecondary ? "Secondary" : "Primary")")
                    }
                }
            }
            .scrollIndicators(.hidden)
        } header: {
            HStack {
                Text("Target Muscles")
                Spacer()
                Text("Template")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var movementQualitySection: some View {
        Section {
            rangeOfMotionRow
            stabilityRow
        } header: {
            Text("Movement Quality")
        }
    }

    private var rangeOfMotionRow: some View {
        HStack {
            Text("Range of Motion")
            Spacer()
            HStack {
                ForEach(1...5, id: \.self) { value in
                    Capsule()
                        .fill(value <= delegate.exerciseTemplate.rangeOfMotion ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    private var stabilityRow: some View {
        HStack {
            Text("Stability")
            Spacer()
            HStack {
                ForEach(1...5, id: \.self) { value in
                    Capsule()
                        .fill(value <= delegate.exerciseTemplate.stability ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    private var resistanceEquipmentSection: some View {
        Section {
            if delegate.exerciseTemplate.resistanceEquipment.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(delegate.exerciseTemplate.resistanceEquipment, id: \.self) { equipment in
                            VStack {
                                ImageLoaderView()
                                    .frame(height: 200)
                                Text("\(equipment.kind.rawValue): \(equipment.equipmentId)")
                            }
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Resistance Equipment")
                Spacer()
                Text("Template")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var supportEquipmentSection: some View {
        Section {
            if delegate.exerciseTemplate.supportEquipment.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(delegate.exerciseTemplate.supportEquipment, id: \.self) { equipment in
                            VStack {
                                ImageLoaderView()
                                    .frame(height: 200)
                                Text("\(equipment.kind.rawValue): \(equipment.equipmentId)")
                            }
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Support Equipment")
                Spacer()
                Text("Template")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var detailsSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Body Weight Contribution")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseTemplate.bodyWeightContribution)%")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Alternative Names")
                    .fontWeight(.semibold)
                Spacer()
                Text(alternateNamesConcatenated)
                    .foregroundStyle(alternateNamesConcatenated.isEmpty ? .secondary : .primary)
                    .lineLimit(2)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Description")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.description ?? "None")
                    .foregroundStyle(delegate.exerciseTemplate.description == nil ? .secondary : .primary)
                    .lineLimit(3)
            }
        } header: {
            Text("Details")
        }
    }

    private var metadataSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise ID")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.id)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
            if !delegate.exerciseTemplate.authorId.isEmpty {
                HStack(alignment: .firstTextBaseline) {
                    Text("Author ID")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(delegate.exerciseTemplate.authorId)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("System Exercise")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.isSystemExercise ? "Yes" : "No")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Date Created")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.dateCreated.formatted(date: .abbreviated, time: .omitted))
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Date Modified")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseTemplate.dateModified.formatted(date: .abbreviated, time: .omitted))
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Click Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseTemplate.clickCount ?? 0)")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Bookmark Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseTemplate.bookmarkCount ?? 0)")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Favourite Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseTemplate.favouriteCount ?? 0)")
            }
            if let imageURL = delegate.exerciseTemplate.imageURL, !imageURL.isEmpty {
                HStack(alignment: .firstTextBaseline) {
                    Text("Image URL")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(imageURL)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                }
            }
        } header: {
            Text("Metadata")
        }
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
    
    private var trackableMetricString: String {
        let names = delegate.exerciseTemplate.trackableMetrics.map { $0.name }
        return names.isEmpty ? "None" : names.joined(separator: " x ")
    }

    private var alternateNamesConcatenated: String {
        delegate.exerciseTemplate.alternateNames.joined(separator: ", ")
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
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.exerciseTemplateDetailView(
            router: router,
            delegate: ExerciseTemplateDetailDelegate(
                exerciseTemplate: ExerciseModel.mocks[0]
            )
        )
    }
    .previewEnvironment()
}
