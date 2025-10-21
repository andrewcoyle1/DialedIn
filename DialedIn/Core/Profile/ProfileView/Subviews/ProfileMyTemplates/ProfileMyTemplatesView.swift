//
//  ProfileMyTemplatesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

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
            
            NavigationLink {
                ExerciseTemplateListView(templateIds: templateIds)
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
            
            NavigationLink {
                WorkoutTemplateListView(templateIds: templateIds)
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
            
            NavigationLink {
                RecipeTemplateListView(templateIds: templateIds)
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
            
            NavigationLink {
                IngredientTemplateListView(templateIds: templateIds)
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
    NavigationStack {
        List {
            ProfileMyTemplatesView(viewModel: ProfileMyTemplatesViewModel(container: DevPreview.shared.container))
        }
    }
    .previewEnvironment()
}
