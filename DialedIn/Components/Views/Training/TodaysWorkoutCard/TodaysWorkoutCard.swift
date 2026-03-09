//
//  TodaysWorkoutCard.swift
//  DialedIn
//
//  Created by Andrew Coyle on 09/03/2026.
//

import SwiftUI

struct TodaysWorkoutCardDelegate {
    let todaysWorkoutTemplate: WorkoutTemplateModel
}

struct TodaysWorkoutCard: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: TodaysWorkoutCardPresenter
    let delegate: TodaysWorkoutCardDelegate
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Workout")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.leading)
            VStack(alignment: .leading, spacing: 12) {
                if presenter.isTodayRestDay {
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
                } else {
                    Button {
                        presenter.onTodaysWorkoutPressed()
                    } label: {
                        VStack(alignment: .leading) {
                            HStack(spacing: -10) {
                                ForEach(delegate.todaysWorkoutTemplate.exercises.prefix(5)) { exercise in
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
                                    Text(delegate.todaysWorkoutTemplate.name)
                                        .font(.title3.bold())
                                        .foregroundStyle(.primary)
                                    Text("\(delegate.todaysWorkoutTemplate.exercises.count) exercise\(delegate.todaysWorkoutTemplate.exercises.count == 1 ? "" : "s")")
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

extension CoreBuilder {
    func todaysWorkoutCard(router: AnyRouter, delegate: TodaysWorkoutCardDelegate) -> some View {
        TodaysWorkoutCard(
            presenter: TodaysWorkoutCardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = TodaysWorkoutCardDelegate(todaysWorkoutTemplate: .mock)
    
    RouterView { router in
        List {
            Section {
                TabView {
                    Tab {
                        builder.todaysWorkoutCard(router: router, delegate: delegate)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 240)
                
            }
            .listSectionMargins(.all, 0)
        }
    }
}
