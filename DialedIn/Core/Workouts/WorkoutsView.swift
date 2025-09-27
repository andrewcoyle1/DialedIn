//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct WorkoutsView: View {
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(UserManager.self) private var userManager
    @State private var showAddWorkoutModal: Bool = false
    @State private var workouts: [WorkoutTemplateModel] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        Group {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Loading...")
                }
                .foregroundStyle(Color.secondary)
                .removeListRowFormatting()
            }
            ForEach(workouts) { workout in
                CustomListCellView(
                    imageName: workout.imageURL,
                    title: workout.name
                )
                .removeListRowFormatting()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddWorkoutModal = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
        .searchable(text: $searchText)
        .task { await loadTopWorkouts() }
        .showCustomAlert(alert: $showAlert)
        .sheet(isPresented: $showAddWorkoutModal) {
            CreateWorkoutView()
        }
    }
}

#Preview {
    NavigationStack {
        List {
            Section {
                WorkoutsView()
            } header: {
                Text("Workout Templates")
            }
        }
    }
    .previewEnvironment()
}

extension WorkoutsView {
    private func loadTopWorkouts() async {
        isLoading = true
        do {
            let top = try await workoutTemplateManager.getTopWorkoutTemplatesByClicks(limitTo: 20)
            await MainActor.run {
                workouts = top
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                showAlert = AnyAppAlert(
                    title: "Unable to Load Workouts",
                    subtitle: "Please try again later."
                )
            }
        }
    }
}
