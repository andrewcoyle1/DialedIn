//
//  WorkoutsView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct WorkoutsView: View {
    
    @State private var showAddWorkoutModal: Bool = false
    
    private let workouts: [WorkoutTemplateModel] = WorkoutTemplateModel.mocks
    
    @State private var searchText: String = ""
    
    var body: some View {
        Group {
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
