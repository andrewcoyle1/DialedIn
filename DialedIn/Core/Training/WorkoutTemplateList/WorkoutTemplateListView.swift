//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct WorkoutTemplateListView: View {
    
    @State var presenter: WorkoutTemplateListPresenter
    
    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView()
            } else if presenter.hasWorkouts {
                ContentUnavailableView(
                    "No Workouts",
                    systemImage: "dumbbell",
                    description: Text("No workouts found, try creating a new one.")
                )
            } else {
                List {
                    myWorkoutsSection
                    favouriteWorkoutsSection
                }
            }
        }
    }
    
    private var myWorkoutsSection: some View {
        Section {
            ForEach(presenter.myWorkouts) { template in
                CustomListCellView(
                    imageName: template.imageURL,
                    title: template.name,
                    subtitle: template.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(template: template)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("My Workouts")
        }
    }
    
    private var favouriteWorkoutsSection: some View {
        Section {
            ForEach(presenter.favouriteWorkouts) { template in
                CustomListCellView(
                    imageName: template.imageURL,
                    title: template.name,
                    subtitle: template.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(template: template)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Favourite Workouts")
        }
    }
    
    private var bookmarkedWorkoutsSection: some View {
        Section {
            ForEach(presenter.bookmarkedWorkouts) { template in
                CustomListCellView(
                    imageName: template.imageURL,
                    title: template.name,
                    subtitle: template.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(template: template)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Bookmarked Workouts")
        }
    }
    
    private var systemWorkoutsSection: some View {
        Section {
            ForEach(presenter.myWorkouts) { template in
                CustomListCellView(
                    imageName: template.imageURL,
                    title: template.name,
                    subtitle: template.description
                )
                .anyButton(.highlight) {
                    presenter.onWorkoutPressed(template: template)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("System Workouts")
        }
    }
}
 
#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.workoutTemplateListView(
            router: router
        )
    }
    .previewEnvironment()
}
