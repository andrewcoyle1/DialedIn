//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(UserManager.self) private var userManager: UserManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    @Environment(RecipeTemplateManager.self) private var recipeTemplateManager
    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    @State private var showNotifications: Bool = false
    
    @State private var showCreateProfileSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                profileSection
                myTemplatesSection
            }
            .navigationTitle("Profile")
            .navigationSubtitle(Date.now.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.large)
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView, content: {
                DevSettingsView()
            })
            #endif
            .sheet(isPresented: $showCreateProfileSheet) {
                CreateAccountView()
                    .presentationDetents([
                        .fraction(0.4)
                    ])
                // OnboardingCreateProfileView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
            .toolbar {
                toolbarContent
            }
        }
    }
}

#Preview("User Has Image") {
    ProfileView()
        .previewEnvironment()
}

#Preview("User Has No Image") {
    ProfileView()
        .environment(
            UserManager(
                services: MockUserServices(
                    user: UserModel(
                        userId: UUID().uuidString,
                        email: "alicecooper@gmail.com",
                        isAnonymous: false,
                        firstName: "",
                        lastName: "Cooper",
                        dateOfBirth: Calendar.current.date(from: DateComponents(year: 2000, month: 11, day: 13)),
                        gender: .male,
                        profileImageUrl: nil,
                        creationDate: Date(),
                        creationVersion: nil,
                        lastSignInDate: Date(),
                        didCompleteOnboarding: true,
                        blockedUserIds: [])
                )
            )
        )
        .previewEnvironment()
}

extension ProfileView {
    
    private var myTemplatesSection: some View {
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
            let templateIds = userManager.currentUser?.createdExerciseTemplateIds ?? []
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
            let templateIds = userManager.currentUser?.createdWorkoutTemplateIds ?? []
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
            let templateIds = userManager.currentUser?.createdRecipeTemplateIds ?? []
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
            let templateIds = userManager.currentUser?.createdIngredientTemplateIds ?? []
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
    
    private var profileSection: some View {
        Section {
            Group {
                if let user = userManager.currentUser,
                   let firstName = user.firstName, !firstName.isEmpty {
                    // User has a profile
                    CustomListCellView(
                        imageName: user.profileImageUrl ?? Constants.randomImage,
                        title: "\(firstName) \(user.lastName ?? "")",
                        subtitle: {
                            if let dob = user.dateOfBirth {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .medium
                                return "\(formatter.string(from: dob))"
                            } else {
                                return nil
                            }
                        }()
                    )
                    .removeListRowFormatting()
                } else {
                    // User does not have a profile
                    Button {
                        showCreateProfileSheet = true
                    } label: {
                        CustomListCellView(
                            imageName: nil,
                            title: "Create your profile",
                            subtitle: "Tap to get started",
                            isSelected: true,
                            iconName: "person.circle",
                            iconSize: CGFloat(32)
                        )
                        
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("Profile")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                onNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gear")
            }
        }
    }
    
    private func onNotificationsPressed() {
        showNotifications = true
    }
    
}
