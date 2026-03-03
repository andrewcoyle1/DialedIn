import SwiftUI

struct ProgramDesignDelegate {
    let onComplete: (@Sendable () -> Void)?
    var id: String
    var authorId: String
    var name: String
    var colour: Color
    var icon: String
    
    init(
        onComplete: (@Sendable () -> Void)? = nil,
        id: String,
        authorId: String,
        name: String,
        colour: Color,
        icon: String
    ) {
        self.onComplete = onComplete
        self.id = id
        self.authorId = authorId
        self.name = name
        self.colour = colour
        self.icon = icon
    }
}

struct EditTrainingProgramDelegate {
    var program: TrainingProgram
}

struct ProgramDesignView<DefineWorkout: View>: View {
    
    @State var presenter: ProgramDesignPresenter
    let delegate: ProgramDesignDelegate
    
    @ViewBuilder var workoutDefinitionView: (DefineWorkoutDelegate) -> DefineWorkout
    
    init(presenter: ProgramDesignPresenter, delegate: ProgramDesignDelegate, workoutDefinitionView: @escaping (DefineWorkoutDelegate) -> DefineWorkout) {
        self.presenter = presenter
        self.delegate = delegate
        self.workoutDefinitionView = workoutDefinitionView
    }
    
    init(presenter: ProgramDesignPresenter, delegate: EditTrainingProgramDelegate, workoutDefinitionView: @escaping (DefineWorkoutDelegate) -> DefineWorkout) {
        self.presenter = presenter
        self.delegate = ProgramDesignDelegate(id: delegate.program.id, authorId: delegate.program.authorId, name: delegate.program.name, colour: Color(hex: delegate.program.colour), icon: delegate.program.icon)
        self.workoutDefinitionView = workoutDefinitionView
    }
    
    var body: some View {
        workoutDefinitionSection(dayPlan: presenter.selectedWorkoutTemplateModel)
            .navigationTitle("Create Program")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                presenter.onViewAppear()
            }
            .onDisappear {
                presenter.onViewDisappear()
            }
            .toolbar {
                toolbarContent
            }
            .safeAreaInset(edge: .top) {
                topSafeAreaSection
            }
            .safeAreaInset(edge: .bottom) {
                bottomSafeAreaSection
            }
    }
    
    private func workoutDefinitionSection(dayPlan: WorkoutTemplateModel) -> some View {
        
        let gymProfile = presenter.favouriteGymProfile ?? GymProfileModel(
            authorId: presenter.userId,
            freeWeights: [],
            loadableBars: [],
            fixedWeightBars: [],
            bands: [],
            bodyWeights: [],
            supportEquipment: [],
            accessoryEquipment: [],
            loadableAccessoryEquipment: [],
            cableMachines: [],
            plateLoadedMachines: [],
            pinLoadedMachines: []
        )
        let delegate = DefineWorkoutDelegate(
            name: dayPlan.name,
            gymProfile: gymProfile,
            exercises: presenter.selectedWorkoutTemplateModelExercises,
            topSectionStyle: .programDay
        )
        return workoutDefinitionView(delegate)
            .navigationTitle(dayPlan.name)
            // Ensure switching selected day plan rebuilds DefineWorkoutView state.
            .id(dayPlan.id)
    }
    
    private var daySelectionSection: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(presenter.dayPlans) { dayPlan in
                    dayPlanCell(dayPlan)
                }
                Button {
                    presenter.onAddDayPressed()
                } label: {
                    HStack {
                        Text("Add Day")
                        Image(systemName: "plus")
                    }

                }
                .buttonStyle(.glass)
            }
            .padding(8)
        }
        .scrollIndicators(.hidden)
    }
    
    private func dayPlanCell(_ dayPlan: WorkoutTemplateModel) -> some View {
        Group {
            if presenter.selectedWorkoutTemplateModel.id == dayPlan.id {
                Button {
                    presenter.onWorkoutTemplateModelSelected(dayPlan)
                } label: {
                    Text(dayPlan.name)
                        .fontWeight(.bold)
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    presenter.onWorkoutTemplateModelSelected(dayPlan)
                } label: {
                    Text(dayPlan.name)
                        .fontWeight(.regular)
                }
                .buttonStyle(.glass)
            }
        }
    }
    
    private var topSafeAreaSection: some View {
        VStack {
            daySelectionSection
            dayOptionBar
        }
    }
    
    private var bottomSafeAreaSection: some View {
        VStack {
            if !presenter.isProgramActive {
                Button {
                    presenter.onActivatePressed(delegate: delegate)
                } label: {
                    Text("Activate Program")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            }

            if delegate.onComplete == nil {
                Button {
                    presenter.onSavePressed(delegate: delegate)
                } label: {
                    Text("Save Program")
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.horizontal)
    }
    
    private var dayOptionBar: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    OptionCell(imageName: "minus.circle.fill", title: "Remove")
                        .anyButton {
                            presenter.onRemoveWorkoutTemplateModelPressed()
                        }
                        .disabled(!presenter.canRemoveWorkoutTemplateModel)
                        .padding(.leading)
                    
                    OptionCell(imageName: "pencil", title: "Rename")
                        .anyButton {
                            presenter.onRenameWorkoutTemplateModelPressed()
                        }
                        .disabled(presenter.selectedWorkoutTemplateModel.exercises.isEmpty)
                        .padding(.trailing)
                }
            }
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        }
        .listSectionMargins(.vertical, 0)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if delegate.onComplete == nil {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onProgramSettingsPressed(program: $presenter.program)
            } label: {
                Image(systemName: "slider.horizontal.3")
            }
        }
    }
}

extension CoreBuilder {
    
    func programDesignView(router: AnyRouter, delegate: ProgramDesignDelegate) -> some View {
        let program = TrainingProgram(
            id: delegate.id,
            authorId: delegate.authorId,
            name: delegate.name,
            icon: delegate.icon,
            colour: delegate.colour.asHex()
        )
        return ProgramDesignView(
            presenter: ProgramDesignPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                program: program
            ),
            delegate: delegate,
            workoutDefinitionView: { delegate in
                self.defineWorkoutView(router: router, delegate: delegate)
            }
        )
    }

    func editTrainingProgramView(router: AnyRouter, delegate: EditTrainingProgramDelegate) -> some View {
        ProgramDesignView(
            presenter: ProgramDesignPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                ),
                program: delegate.program
            ),
            delegate: delegate,
            workoutDefinitionView: { delegate in
                self.defineWorkoutView(router: router, delegate: delegate)
            }
        )
    }
    
}

extension CoreRouter {
    
    func showProgramDesignView(delegate: ProgramDesignDelegate) {
        router.showScreen(.push) { router in
            builder.programDesignView(router: router, delegate: delegate)
        }
    }
    
    func showEditTrainingProgramView(delegate: EditTrainingProgramDelegate) {
        router.showScreen(.sheet) { router in
            builder.editTrainingProgramView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProgramDesignDelegate(
        id: UUID().uuidString,
        authorId: "user123",
        name: "Preview Program",
        colour: .blue,
        icon: "pencil"
    )
    
    return RouterView { router in
        builder.programDesignView(router: router, delegate: delegate)
    }
    
}

struct OptionCell: View {
    
    let imageName: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(title)
                .font(.caption)
        }
        .padding(8)
        .glassEffect()
//        .background {
//            Capsule()
//                .foregroundStyle(Color.secondary.opacity(0.4))
//        }
    }
}
