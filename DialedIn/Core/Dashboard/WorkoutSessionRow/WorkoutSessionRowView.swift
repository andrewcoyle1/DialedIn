//
//  WorkoutSessionRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/02/2026.
//

import SwiftUI

struct WorkoutSessionRowDelegate {
    let session: WorkoutSessionModel
    let author: UserModel
        
    @MainActor
    static var mock: Self {
        Self(session: .mock, author: .mock)
    }
}

struct WorkoutSessionRowView<AuthorHeader: View>: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var presenter: WorkoutSessionRowPresenter

    @ViewBuilder var authorHeader: (AuthorHeaderDelegate) -> AuthorHeader
    
    // MARK: - Computed Properties

    private var durationFormatted: String? {
        guard let endedAt = presenter.session.endedAt else { return nil }
        let total = Int(endedAt.timeIntervalSince(presenter.session.dateCreated))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private var workingSets: [WorkoutSetModel] {
        presenter.session.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }
    }

    private var totalVolumeKg: Double {
        workingSets.reduce(0) { $0 + (($1.weightKg ?? 0) * Double($1.reps ?? 0)) }
    }

    // MARK: - Body

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                authorHeader(AuthorHeaderDelegate(author: presenter.author, date: presenter.session.dateCreated))
                sessionContent
            }
            .frame(maxWidth: .infinity)
            footerBar
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
    }

    // MARK: - Session Title and Stats

    private var sessionContent: some View {
        VStack {
            sessionTitleAndStats
            exerciseList
        }
        .anyButton {
            presenter.onWorkoutPressed()
        }

    }
    
    private var sessionTitleAndStats: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(presenter.session.name)
                .font(.headline)
            HStack(spacing: 20) {
                StatItem(header: "Exercises", value: "\(presenter.session.exercises.count)")
                StatItem(header: "Sets", value: "\(workingSets.count)")
                if totalVolumeKg > 0 {
                    StatItem(header: "Volume", value: formatVolume(totalVolumeKg))
                }
                Spacer()
                if let duration = durationFormatted {
                    StatItem(alignment: .trailing, header: "Duration", value: duration)
                }
            }
        }
    }

    // MARK: - Exercise List

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(presenter.session.exercises) { exercise in
                HStack {
                    Text(exercise.name)
                        .font(.subheadline)
                    Spacer()
                    Text(setsDescription(for: exercise))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
            }
        }
    }

    // MARK: - Footer Bar

    private var footerBar: some View {
        HStack {
            Button {
                presenter.onLikeButtonPressed()
            } label: {
                Label("\(presenter.likeCount)", systemImage: presenter.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
            }
            .frame(maxWidth: .infinity)
            Button {
                presenter.onCommentButtonPressed()
            } label: {
                Image(systemName: "bubble")
            }
            .frame(maxWidth: .infinity)
            Button {
                presenter.onShareButtonPressed()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func setsDescription(for exercise: WorkoutExerciseModel) -> String {
        let sets = exercise.sets.filter { !$0.isWarmup }
        guard !sets.isEmpty else { return "\(exercise.setTargets.count) sets" }
        let count = sets.count
        switch exercise.trackingMode {
        case .weightReps:
            if let first = sets.first, let reps = first.reps, let weight = first.weightKg {
                return "\(count) × \(reps) @ \(formatWeight(weight)) kg"
            }
            if let first = sets.first, let reps = first.reps {
                return "\(count) × \(reps)"
            }
        case .repsOnly:
            if let first = sets.first, let reps = first.reps {
                return "\(count) × \(reps)"
            }
        case .timeOnly:
            if let first = sets.first, let secs = first.durationSec {
                return "\(count) × \(formatDuration(secs))"
            }
        case .distanceTime:
            if let first = sets.first, let meters = first.distanceMeters {
                return "\(count) × \(formatDistance(meters))"
            }
        }
        return "\(count) sets"
    }

    private func formatWeight(_ kilograms: Double) -> String {
        let value = (kilograms * 10).rounded() / 10
        return value == Double(Int(value)) ? "\(Int(value))" : String(format: "%.1f", value)
    }

    private func formatVolume(_ kilograms: Double) -> String {
        kilograms >= 1000 ? String(format: "%.1f t", kilograms / 1000) : "\(Int(kilograms)) kg"
    }

    private func formatDuration(_ seconds: Int) -> String {
        seconds >= 60 ? "\(seconds / 60)m" : "\(seconds)s"
    }

    private func formatDistance(_ meters: Double) -> String {
        meters >= 1000 ? String(format: "%.1f km", meters / 1000) : "\(Int(meters)) m"
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)

    RouterView { router in
        List {
            builder.workoutSessionRowView(router: router, delegate: .mock)
        }
    }
}

extension CoreBuilder {
    func workoutSessionRowView(router: AnyRouter, delegate: WorkoutSessionRowDelegate) -> some View {
        WorkoutSessionRowView(
            presenter: WorkoutSessionRowPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            authorHeader: { delegate in
                self.authorHeaderView(router: router, delegate: delegate)
            }
        )
    }
}
