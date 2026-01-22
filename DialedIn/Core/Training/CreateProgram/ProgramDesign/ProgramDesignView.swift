import SwiftUI

struct ProgramDesignDelegate {
    var id: String
    var authorId: String
    var name: String
    var colour: Color
    var icon: String
}

struct ProgramDesignView: View {
    
    @State var presenter: ProgramDesignPresenter
    let delegate: ProgramDesignDelegate
    
    var body: some View {
        List {
            dayOptionBar
            
            overviewCard()
            
            exercisesSection
        }
        .navigationTitle("Create Program")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ProgramDesignView")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .top) {
            daySelectionSection
        }
        .safeAreaInset(edge: .bottom) {
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
    }
    
    private var daySelectionSection: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(presenter.dayPlans) { dayPlan in
                    VStack {
                        Text(dayPlan.name)
                            .fontWeight(presenter.selectedDayPlan.id == dayPlan.id ? .bold : .regular)
                    }
                    .anyButton {
                        presenter.onDayPlanSelected(dayPlan)
                    }
                    .frame(minWidth: 50)
                }
                HStack {
                    Text("Add Day")
                    ZStack {
                        Circle()
                            .foregroundColor(.secondary.opacity(0.4))
                        Image(systemName: "plus")
                            .font(.caption2)
                    }
                    .frame(width: 20, height: 20)
                }
                .padding(8)
                .anyButton {
                    presenter.onAddDayPressed()
                }
            }
            .padding(8)
        }
        .scrollIndicators(.hidden)
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
                    
                    OptionCell(imageName: "pencil", title: "Rename")
                        .anyButton {
                            presenter.onRenameDayPlanPressed()
                        }
                        .disabled(presenter.selectedDayPlan.exercises.isEmpty)
                }
            }
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        }
        .listSectionMargins(.vertical, 0)
    }
    
    @ViewBuilder
    private func overviewCard() -> some View {
        if presenter.selectedDayPlan.exercises.isEmpty {
            Section {
                HStack {
                    Image(systemName: "sun.max")
                    Text("You can convert the rest day into a workout day by add exercises below")
                }
                .frame(maxWidth: .infinity)
                
            } header: {
                Text("Rest Day")
            }
        } else {
            Section {
                ScrollView {
                    HStack {
                        ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                            Text(muscle.description)
                        }
                    }
                }
            } header: {
                Text("Target Muscles")
            }
        }
    }
    
    private var exercisesSection: some View {
        Section {
            ForEach(presenter.selectedDayPlan.exercises, id: \.id) { exercise in
                Text(exercise.exercise.name)
            }
            Text("Add Exercises")
                .underline()
                .anyButton {
                    presenter.onAddExercisePressed()
                }
        } header: {
            Text(String.countCaption(count: presenter.selectedDayPlan.exercises.count, unit: "Exercise"))
        }
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
            delegate: delegate
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
    let container = DevPreview.shared.container
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
        .background {
            Capsule()
                .foregroundStyle(Color.secondary.opacity(0.4))
        }
    }
}
