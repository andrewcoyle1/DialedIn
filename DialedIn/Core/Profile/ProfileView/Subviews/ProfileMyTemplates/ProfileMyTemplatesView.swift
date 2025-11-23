//
//  ProfileMyTemplatesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import CustomRouting

struct ProfileMyTemplatesView: View {

    @State var viewModel: ProfileMyTemplatesViewModel

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
            let templateIds = viewModel.currentUser?.createdExerciseTemplateIds ?? []
            let count = templateIds.count

            Button {
                viewModel.navToExerciseTemplateList()
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
            let templateIds = viewModel.currentUser?.createdWorkoutTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                viewModel.navToWorkoutTemplateList()
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
            let templateIds = viewModel.currentUser?.createdRecipeTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                viewModel.navToRecipeTemplateList()
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
            let templateIds = viewModel.currentUser?.createdIngredientTemplateIds ?? []
            let count = templateIds.count
            
            Button {
                viewModel.navToIngredientTemplateList()
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
