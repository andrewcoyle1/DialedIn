import SwiftUI

struct ProgramSettingsView: View {
    
    @State var presenter: ProgramSettingsPresenter
    @Binding var program: TrainingProgram
    
    var body: some View {
        List {
            Section {
                editProgramName
                editCycleCount
                editColourAndIcon
                editDayOrder
                editDeload
                editPeriodisation
            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Program Settings")
        .navigationSubtitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .screenAppearAnalytics(name: "ProgramSettingsView")
        .toolbar {
            toolbarContent
        }
    }
    
    private var editProgramName: some View {
        HStack {
            Image(systemName: "pencil")
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text("Name")
                Text(program.name)
                    .font(.caption2)
            }
            Spacer()
            Text("Edit")
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.secondary.opacity(0.2))
                }
                .anyButton(.press) {
                    
                }
        }
    }
    
    private var editCycleCount: some View {
        Stepper(value: $program.numMicrocycles, in: 1...16) {
            HStack {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .frame(width: 24)

                VStack(alignment: .leading) {
                    Text("Number of cycles")
                    Text("\(program.numMicrocycles) cycles")
                        .font(.caption2)
                }
            }
        }
    }
    
    private var editColourAndIcon: some View {
        HStack {
            Image(systemName: program.icon)
                .frame(width: 24)
                .foregroundStyle(Color(program.colour))
            VStack(alignment: .leading) {
                Text("Colour & Icon")
                Text("\(program.colour.description.capitalized), \(program.icon.capitalized)")
                    .font(.caption2)
            }
            Spacer()
            Text("Edit")
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.secondary.opacity(0.2))
                }
                .anyButton(.press) {
                    
                }

        }
    }
    
    private var editDayOrder: some View {
        HStack {
            Image(systemName: "calendar")
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text("Day Order")
                Text(dayOrderSubtitle)
                    .font(.caption2)
            }
            Spacer()
            Text("Edit")
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.secondary.opacity(0.2))
                }
                .anyButton(.press) {
                    
                }
        }
    }
    
    private var editDeload: some View {
        HStack {
            Image(systemName: "cloud.fill")
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text("Deload")
                Text(program.deload.title.capitalized)
                    .font(.caption2)
            }
            Spacer()
            Text("Edit")
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.secondary.opacity(0.2))
                }
                .anyButton(.press) {
                    
                }
        }
    }
    
    private var editPeriodisation: some View {
        Toggle(isOn: $program.periodisation) {
            HStack {
                Image(systemName: "water.waves")
                    .frame(width: 24)

                VStack(alignment: .leading) {
                    Text("Periodisation")
                    Text("Organise your training into phases that vary intensity and volume to support continuous progress and effective recovery.")
                        .font(.caption2)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    
    private var dayOrderSubtitle: String {
        var subtitle = ""
        for plan in program.dayPlans {
            if plan.exercises.isEmpty {
                subtitle += "R "
            } else {
                subtitle += "W "
            }
        }
        return subtitle
    }
}

extension CoreBuilder {
    
    func programSettingsView(router: Router, program: Binding<TrainingProgram>) -> some View {
        ProgramSettingsView(
            presenter: ProgramSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            program: program
        )
    }
    
}

extension CoreRouter {
    
    func showProgramSettingsView(program: Binding<TrainingProgram>) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.65)]))) { router in
            builder.programSettingsView(router: router, program: program)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let program = Binding.constant(
        TrainingProgram(authorId: "user123", name: "Preview Program", icon: "pencil", colour: Color.blue.asHex())
    )
    
    return RouterView { router in
        builder.programSettingsView(router: router, program: program)
    }
    .previewEnvironment()
}
