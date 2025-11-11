//
//  ProfileMyTemplatesView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfileMyTemplatesView: View {

    @State var viewModel: ProfileMyTemplatesViewModel

    @Binding var path: [TabBarPathOption]

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
                viewModel.navToExerciseTemplateList(path: $path)
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
                viewModel.navToWorkoutTemplateList(path: $path)
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
                viewModel.navToRecipeTemplateList(path: $path)
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
                viewModel.navToIngredientTemplateList(path: $path)
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
    @Previewable @State var path: [TabBarPathOption] = []
    NavigationStack {
        List {
            ProfileMyTemplatesView(viewModel: ProfileMyTemplatesViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), path: $path)
        }
    }
    .previewEnvironment()
}
