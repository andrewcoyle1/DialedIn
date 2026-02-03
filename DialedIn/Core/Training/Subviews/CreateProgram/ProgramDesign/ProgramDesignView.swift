import SwiftUI

struct ProgramDesignDelegate {
    var id: String
    var authorId: String
    var name: String
    var colour: Color
    var icon: String
}

struct ProgramDesignView<DefineWorkout: View>: View {
    
    @State var presenter: ProgramDesignPresenter
    let delegate: ProgramDesignDelegate
    
    @ViewBuilder var workoutDefinitionView: (DefineWorkoutDelegate) -> DefineWorkout
    
    var body: some View {
        workoutDefinitionSection(dayPlan: presenter.selectedDayPlan)
            .navigationTitle("Create Program")
            .navigationBarTitleDisplayMode(.inline)
            .screenAppearAnalytics(name: "ProgramDesignView")
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
    
    private func workoutDefinitionSection(dayPlan: DayPlan) -> some View {
        let gymProfile = presenter.gymProfile ?? GymProfileModel(
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
            exercises: presenter.selectedDayPlanExercises,
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
    
    private func dayPlanCell(_ dayPlan: DayPlan) -> some View {
        Group {
            if presenter.selectedDayPlan.id == dayPlan.id {
                Button {
                    presenter.onDayPlanSelected(dayPlan)
                } label: {
                    Text(dayPlan.name)
                        .fontWeight(.bold)
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    presenter.onDayPlanSelected(dayPlan)
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
            HStack {
                Spacer()
                Text("Activate Program")
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.vertical)
            .background {
                Capsule()
                    .frame(maxWidth: .infinity)
            }
            .anyButton {
                presenter.onActivatePressed(delegate: delegate)
            }
            .padding()
            
            Text("Save Program")
                .anyButton {
                    presenter.onSavePressed(delegate: delegate)
                }
        }
        .frame(maxWidth: .infinity)

    }
    
    private var dayOptionBar: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    OptionCell(imageName: "minus.circle.fill", title: "Remove")
                        .anyButton {
                            presenter.onRemoveDayPlanPressed()
                        }
                        .disabled(!presenter.canRemoveDayPlan)
                        .padding(.leading)
                    
                    OptionCell(imageName: "pencil", title: "Rename")
                        .anyButton {
                            presenter.onRenameDayPlanPressed()
                        }
                        .disabled(presenter.selectedDayPlan.exercises.isEmpty)
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
    
    func programDesignView(router: Router, delegate: ProgramDesignDelegate) -> some View {
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
    
}

extension CoreRouter {
    
    func showProgramDesignView(delegate: ProgramDesignDelegate) {
        router.showScreen(.push) { router in
            builder.programDesignView(router: router, delegate: delegate)
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
    .previewEnvironment()
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
