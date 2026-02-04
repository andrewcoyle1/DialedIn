import SwiftUI

@Observable
@MainActor
class DefineWorkoutPresenter {
    
    private let interactor: DefineWorkoutInteractor
    private let router: DefineWorkoutRouter
    private var exercisesBinding: Binding<[WorkoutTemplateExercise]>
    
    /// Local observable mirror of `exercisesBinding` so SwiftUI refreshes when it changes.
    var exercises: [WorkoutTemplateExercise] = [] {
        didSet {
            if exercisesBinding.wrappedValue != exercises {
                exercisesBinding.wrappedValue = exercises
            }
        }
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    struct TargetMuscleSummary: Identifiable, Hashable {
        var id: Muscles { muscle }
        let muscle: Muscles
        let weightedTargetSets: Double
        let exerciseCount: Int
    }
    
    /// Computes target muscles based on the exercises currently included in the workout.
    ///
    /// - `ExerciseModel.muscleGroups[muscle] == false` (0) -> primary muscle (factor 1.0)
    /// - `ExerciseModel.muscleGroups[muscle] == true`  (1) -> secondary muscle (factor 0.5)
    ///
    /// `weightedTargetSets` is the sum of each exercise's setTargets count with the factor applied.
    var targetMuscleSummaries: [TargetMuscleSummary] {
        guard !exercises.isEmpty else { return [] }
        
        var weightedSetCounts: [Muscles: Double] = [:]
        var exerciseCounts: [Muscles: Int] = [:]
        
        for workoutExercise in exercises {
            let setCount = Double(workoutExercise.setTargets.count)
            guard setCount > 0 else { continue }
            
            var seenInThisExercise = Set<Muscles>()
            for (muscle, isSecondary) in workoutExercise.exercise.muscleGroups {
                let factor: Double = isSecondary ? 0.5 : 1.0
                weightedSetCounts[muscle, default: 0] += (setCount * factor)
                
                if !seenInThisExercise.contains(muscle) {
                    exerciseCounts[muscle, default: 0] += 1
                    seenInThisExercise.insert(muscle)
                }
            }
        }
        
        let allMuscles = Set(weightedSetCounts.keys).union(exerciseCounts.keys)
        return allMuscles
            .map { muscle in
                TargetMuscleSummary(
                    muscle: muscle,
                    weightedTargetSets: weightedSetCounts[muscle, default: 0],
                    exerciseCount: exerciseCounts[muscle, default: 0]
                )
            }
            .sorted { $0.muscle.name < $1.muscle.name }
    }
    
    init(
        interactor: DefineWorkoutInteractor,
        router: DefineWorkoutRouter,
        exercises: Binding<[WorkoutTemplateExercise]>
    ) {
        self.interactor = interactor
        self.router = router
        self.exercisesBinding = exercises
        self.exercises = exercises.wrappedValue
    }
    
    func onExercisePressed(exercise: Binding<WorkoutTemplateExercise>) {
        router.showSetTargetView(delegate: SetTargetDelegate(exercise: exercise))
    }
    
    func removeExercise(exercise: WorkoutTemplateExercise) {
        let index = exercises.firstIndex { exerciseItem in
            exercise.id == exerciseItem.id
        }
        guard let index else { return }
        
        exercises.remove(at: index)
    }
    
    func onAddExercisePressed() {
        router.showExercisesPickerView(
            delegate: ExercisesPickerDelegate(
                addedExercises: Binding(get: { self.exercises }, set: { newValue in
                    self.exercises = newValue
                })
            )
        )
    }
}
