//
//  ProfileMyTemplatesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileMyTemplatesView: View {

    @State var presenter: ProfileMyTemplatesPresenter

    var body: some View {
        Section {
            exerciseTemplateSection
            workoutTemplateSection
            recipeTemplateSection
            ingredientTemplateSection
        } header: {
            Text("My Templates")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Group {
            let templateIds = presenter.currentUser?.createdExerciseTemplateIds ?? []
            let count = templateIds.count

            Button {
                presenter.navToExerciseTemplateList()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Exercise Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var workoutTemplateSection: some View {
        Group {
            let templateIds = presenter.currentUser?.createdWorkoutTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                presenter.navToWorkoutTemplateList()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workout Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var recipeTemplateSection: some View {
        Group {
            let templateIds = presenter.currentUser?.createdRecipeTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                presenter.navToRecipeTemplateList()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipe Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var ingredientTemplateSection: some View {
        Group {
            let templateIds = presenter.currentUser?.createdIngredientTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                presenter.navToIngredientTemplateList()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ingredient Templates")
                        .font(.headline)
                    
                    Text("\(count) templates")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            builder.profileMyTemplatesView(router: router)
        }
    }
    .previewEnvironment()
}
