//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import SwiftfulRouting

struct TrainingView<ProgramView: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: TrainingPresenter

    @ViewBuilder var programView: () -> ProgramView

    var body: some View {
        List {
            programView()
            workoutLibraryButton
            exerciseLibraryButton
            workoutHistoryLibraryButton
        }
        .navigationTitle("Training")
        .navigationSubtitle(presenter.navigationSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
    }
    
    private var workoutLibraryButton: some View {
        Section {
            Button {
                presenter.onWorkoutLibraryPressed()
            } label: {
                Text("Workout Library")
            }
        } header: {
            Text("Workout Library")
        }
    }
    
    private var exerciseLibraryButton: some View {
        Section {
            Button {
                presenter.onExerciseLibraryPressed()
            } label: {
                Text("Exercise Library")
            }
        } header: {
            Text("Exercise Library")
        }
    }
    
    private var workoutHistoryLibraryButton: some View {
        Section {
            Button {
                presenter.onWorkoutHistoryPressed()
            } label: {
                Text("Workout History")
            }
        } header: {
            Text("Workout History")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
                presenter.onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
    }
}

extension CoreBuilder {
    func trainingView(router: AnyRouter) -> some View {
        TrainingView(
            presenter: TrainingPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            programView: {
                self.programView(router: router)
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}
