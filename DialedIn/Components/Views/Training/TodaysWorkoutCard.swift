//
//  TodaysWorkoutCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

import SwiftUI

struct TodaysWorkoutCard: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isRestDay: Bool
    var isTodayCompleted: Bool
    var todaysWorkoutTemplate: WorkoutTemplateModel
    var onTap: () -> Void
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("Today's Workout")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.leading)
                VStack(alignment: .leading, spacing: 12) {
                    if isRestDay {
                        HStack(spacing: 12) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading) {
                                Text("Rest Day")
                                    .font(.title3.bold())
                                Text("Recovery is part of the process.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    } else if isTodayCompleted {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text(todaysWorkoutTemplate.name)
                                    .font(.title3.bold())
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    } else {
                        Button {
                            onTap()
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(spacing: -10) {
                                    ForEach(todaysWorkoutTemplate.exercises.prefix(5)) { exercise in
                                        exerciseCircle(exercise: exercise.exercise)
                                    }
                                }
                                .frame(maxHeight: .infinity)
                                Divider()
                                HStack(spacing: 12) {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.title2)
                                        .foregroundStyle(.accent)
                                    VStack(alignment: .leading) {
                                        Text(todaysWorkoutTemplate.name)
                                            .font(.title3.bold())
                                            .foregroundStyle(.primary)
                                        Text("\(todaysWorkoutTemplate.exercises.count) exercise\(todaysWorkoutTemplate.exercises.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .frame(height: 200)
                .background(colorScheme.backgroundPrimary)
                .cornerRadius(24)
            }
            .padding(.horizontal)
            .background(colorScheme.backgroundSecondary)
            .padding(.vertical)
        }
        
        @ViewBuilder
        private func exerciseCircle(exercise: ExerciseModel) -> some View {
            ZStack {
                Circle()
                    .fill(Color(uiColor: .secondarySystemBackground))

                ImageLoaderView(
                    urlString: exercise.imageURL ?? "SplashScreen",
                    resizingMode: .fit,
                    clipShape: AnyShape(Circle())
                )
            }
            .frame(width: 100, height: 100)
            .overlay(Circle().stroke(Color(uiColor: .systemBackground), lineWidth: 2))
        }
}

#Preview {
    List {
        Section {
            TabView {
                Tab {
                    TodaysWorkoutCard(
                        isRestDay: false,
                        isTodayCompleted: false,
                        todaysWorkoutTemplate: .mock,
                        onTap: {
                            
                        }
                    )
                    
                }
            }
            .tabViewStyle(.page)
            .frame(height: 240)

        }
        .listSectionMargins(.all, 0)
    }
}
