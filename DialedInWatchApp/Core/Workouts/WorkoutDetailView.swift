//
//  WorkoutDetailView.swift
//  DialedInWatchApp
//
//  Created by Andrew Coyle on 25/10/2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    let template: WorkoutTemplateModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(template.name)
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                if let description = template.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercises")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(template.exercises) { exercise in
                        HStack {
                            Text(exercise.name)
                                .font(.body)
                            Spacer()
                            if let imageName = exercise.imageURL {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Button {
                    Task {
                        await startWorkout()
                    }
                } label: {
                    Text("Start Workout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .navigationTitle(template.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startWorkout() async {
        try? await Task.sleep(for: .seconds(1))
        print("Start workout")
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            template: WorkoutTemplateModel.mocks[0]
        )
    }
}
