//
//  ExerciseDetailView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct ExerciseModelDetailView: View {

    @State var presenter: ExerciseModelDetailPresenter

    var delegate: ExerciseModelDetailDelegate

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
        .navigationTitle(delegate.exerciseModel.name)
        .navigationSubtitle(presenter.performedSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
    }
    
    private var aboutSection: some View {
        Group {
            if let url = delegate.exerciseModel.imageURL {
                imageSection(url: url)
            }

            definitionSection

            if !delegate.exerciseModel.muscleGroups.isEmpty {
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
        Section(header: Text("History")) {
            Text("History coming soon.")
                .foregroundColor(.secondary)
        }
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
    }
}

// MARK: - Sections (extracted for type_body_length)
private extension ExerciseModelDetailView {
    var chartsSection: some View {
        Group {
            weightProgressChart
            repsProgressChart
        }
    }

    var weightProgressChart: some View {
        Section(header: Text("Weight Progress Chart")) {
            Text("Charts coming soon.")
                .foregroundColor(.secondary)
        }
    }

    var repsProgressChart: some View {
        Section(header: Text("Reps Progress Chart")) {
            Text("Charts coming soon.")
                .foregroundColor(.secondary)
        }
    }

    var recordsSection: some View {
        Group {
            personalBestSubSection
            recentRecordsSubSection
            allTimeStatsSubSection
        }
    }

    var personalBestSubSection: some View {
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

    var recentRecordsSubSection: some View {
        Section {
            Text("Records coming soon.")
                .foregroundColor(.secondary)
        } header: {
            Text("Recent Records")
        }
    }

    var allTimeStatsSubSection: some View {
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

    var definitionSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise Name")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.name)
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
                Text(delegate.exerciseModel.type?.name ?? "None")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Laterality")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.laterality?.name ?? "None")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Bodyweight")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.isBodyweight ? "Yes" : "No")
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

    var targetMusclesSection: some View {
        let muscles = Array(delegate.exerciseModel.muscleGroups).sorted { $0.key.name < $1.key.name }
        return Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(muscles, id: \.key) { muscle, isSecondary in
                        Text("\(muscle.name): \(isSecondary == .secondary ? "Secondary" : "Primary")")
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

    var movementQualitySection: some View {
        Section {
            rangeOfMotionRow
            stabilityRow
        } header: {
            Text("Movement Quality")
        }
    }

    var rangeOfMotionRow: some View {
        HStack {
            Text("Range of Motion")
            Spacer()
            HStack {
                ForEach(1...5, id: \.self) { value in
                    Capsule()
                        .fill(value <= delegate.exerciseModel.rangeOfMotion ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    var stabilityRow: some View {
        HStack {
            Text("Stability")
            Spacer()
            HStack {
                ForEach(1...5, id: \.self) { value in
                    Capsule()
                        .fill(value <= delegate.exerciseModel.stability ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    var resistanceEquipmentSection: some View {
        Section {
            if delegate.exerciseModel.resistanceEquipment.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(delegate.exerciseModel.resistanceEquipment, id: \.self) { equipment in
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

    var supportEquipmentSection: some View {
        Section {
            if delegate.exerciseModel.supportEquipment.isEmpty {
                Text("None")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(delegate.exerciseModel.supportEquipment, id: \.self) { equipment in
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

    var detailsSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Body Weight Contribution")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseModel.bodyWeightContribution)%")
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
                Text(delegate.exerciseModel.description ?? "None")
                    .foregroundStyle(delegate.exerciseModel.description == nil ? .secondary : .primary)
                    .lineLimit(3)
            }
        } header: {
            Text("Details")
        }
    }

    var metadataSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise ID")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.id)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }
            if !delegate.exerciseModel.authorId.isEmpty {
                HStack(alignment: .firstTextBaseline) {
                    Text("Author ID")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(delegate.exerciseModel.authorId)
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
                Text(delegate.exerciseModel.isSystemExercise ? "Yes" : "No")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Date Created")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.dateCreated.formatted(date: .abbreviated, time: .omitted))
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Date Modified")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseModel.dateModified.formatted(date: .abbreviated, time: .omitted))
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Click Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseModel.clickCount ?? 0)")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Bookmark Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseModel.bookmarkCount ?? 0)")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Favourite Count")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.exerciseModel.favouriteCount ?? 0)")
            }
            if let imageURL = delegate.exerciseModel.imageURL, !imageURL.isEmpty {
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

    func imageSection(url: String) -> some View {
        Section {
            if url.starts(with: "http://") || url.starts(with: "https://") {
                ImageLoaderView(urlString: url, resizingMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 250)
            } else {
                Image(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 250)
            }
        }
        .removeListRowFormatting()
    }

    func descriptionSection(description: String) -> some View {
        Section(header: Text("Description")) {
            Text(description)
                .font(.body)
        }
    }

    var trackableMetricString: String {
        let names = delegate.exerciseModel.trackableMetrics.map { $0.name }
        return names.isEmpty ? "None" : names.joined(separator: " x ")
    }

    var alternateNamesConcatenated: String {
        delegate.exerciseModel.alternateNames.joined(separator: ", ")
    }
}

extension CoreBuilder {
    func exerciseModelDetailView(router: AnyRouter, delegate: ExerciseModelDetailDelegate) -> some View {
        ExerciseModelDetailView(
            presenter: ExerciseModelDetailPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showExerciseModelDetailView(delegate: ExerciseModelDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.exerciseModelDetailView(router: router, delegate: delegate)
        }
    }
}

#Preview("About Section") {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.exerciseModelDetailView(
            router: router,
            delegate: ExerciseModelDetailDelegate(
                exerciseModel: ExerciseModel.mocks[0]
            )
        )
    }
    
}
