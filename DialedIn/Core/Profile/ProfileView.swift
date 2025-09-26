//
//  ProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(UserManager.self) private var userManager: UserManager
    @State private var showDevSettings: Bool = false
    @State private var showCreateProfileSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                profileSection
                
                exerciseTemplateSection
                workoutTemplateSection
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .sheet(isPresented: $showCreateProfileSheet) {
                CreateAccountView()
                    .presentationDetents([
                        .fraction(0.4)
                    ])
                // OnboardingCreateProfileView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDevSettings = true
                    } label: {
                        Image(systemName: "info")
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
    
    private var exerciseTemplateSection: some View {
        Section {
            Text("Coming soon")
        } header: {
            Text("Exercise Templates")
        }
    }
    
    private var workoutTemplateSection: some View {
        Section {
            Text("Coming soon")
        } header: {
            Text("Workout Templates")
        }
    }
}

#Preview("User Has Image") {
    ProfileView()
        .previewEnvironment()
}

#Preview("User Has No Image") {
    ProfileView()
        .environment(UserManager(services: MockUserServices(user: UserModel(
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
                                                                    exerciseTemplateIds: [],
                                                                    workoutTemplateIds: [],
                                                                    blockedUserIds: [])
                )
            )
        )
        .previewEnvironment()
}
