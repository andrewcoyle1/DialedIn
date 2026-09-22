import SwiftUI

struct ExpenditureSettingsDelegate {
    
}

struct ExpenditureSettingsView: View {
    
    @State var presenter: ExpenditureSettingsPresenter
    let delegate: ExpenditureSettingsDelegate
    
    var body: some View {
        List {
            Section {
                CustomLabelButtonView(
                    title: "Estimation Method",
                    subtitle: presenter.estimationMethod.title) {
                        editMenu(
                            options: presenter.estimationMethods,
                            selection: presenter.estimationMethod,
                            onSelect: { presenter.estimationMethod = $0 }
                        )
                    }
                CustomLabelButtonView(
                    title: "Calculation Start Date",
                    subtitle: presenter.calculationStartDateLabel) {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditStartDatePressed()
                            }
                    }
                CustomLabelButtonView(
                    title: "BMR Equation",
                    subtitle: presenter.bmrEquation.title) {
                        editMenu(
                            options: presenter.bmrEquations,
                            selection: presenter.bmrEquation,
                            onSelect: { presenter.bmrEquation = $0 }
                        )
                    }
            } header: {
                Text("Initial Estimate")
            }

            Section {
                CustomLabelButtonView(
                    title: "Calculation Mode",
                    subtitle: presenter.calculationMode.title) {
                        editMenu(
                            options: presenter.calculationModes,
                            selection: presenter.calculationMode,
                            onSelect: { presenter.calculationMode = $0 }
                        )
                    }
                CustomLabelButtonView(
                    title: "Algorithm",
                    subtitle: presenter.algorithmVersion.title) {
                        editMenu(
                            options: presenter.algorithmVersions,
                            selection: presenter.algorithmVersion,
                            onSelect: { presenter.algorithmVersion = $0 }
                        )
                    }
            } header: {
                Text("Expenditure Calculation")
            } footer: {
                Text("Your choice is saved, but the expenditure figure does not adapt day to day yet — the chart shows one estimate until that is built.")
            }

            Section {
                CustomToggleView(
                    title: "Step-Informed Updates",
                    subtitle: "Uses step trends to speed up expenditure updates during periods where the step data improves confidence",
                    bool: Binding(
                        get: { presenter.stepInformedUpdates },
                        set: { presenter.stepInformedUpdates = $0 }
                    )
                )
                CustomToggleView(
                    title: "Predictive Goal Adjustment",
                    subtitle: "Applies a predictive adjustment to expenditure based on the likely impact of goal changes",
                    bool: Binding(
                        get: { presenter.predictiveGoalAdjustments },
                        set: { presenter.predictiveGoalAdjustments = $0 }
                    )
                )
            } header: {
                Text("Expenditure Modifiers")
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presenter.isChoosingStartDate) {
            startDatePicker
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }

    private var startDatePicker: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Start date",
                    selection: Binding(
                        get: { presenter.calculationStartDate },
                        set: { presenter.calculationStartDate = $0 }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                Button("Use Default") {
                    presenter.onClearStartDatePressed()
                }
                .padding(.top)
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .navigationTitle("Calculation Start")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { presenter.isChoosingStartDate = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    /// The row keeps its "Edit" capsule, which opens a menu rather than another screen — these are
    /// all short lists, and each option carries its own explanation.
    private func editMenu<Option: Identifiable & Equatable>(
        options: [Option],
        selection: Option,
        onSelect: @escaping (Option) -> Void
    ) -> some View where Option: ExpenditureOptionDescribing {
        Menu {
            ForEach(options) { option in
                Button {
                    onSelect(option)
                } label: {
                    if option == selection {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            Text("Edit")
                .padding(.horizontal, 8)
                .padding(8)
                .background(Color.secondary.opacity(0.2), in: .capsule)
        }
    }
}

/// Lets one menu helper serve every expenditure option enum without repeating it four times.
protocol ExpenditureOptionDescribing {
    var title: String { get }
    var subtitle: String { get }
}

extension ExpenditureEstimationMethod: ExpenditureOptionDescribing { }
extension BMREquation: ExpenditureOptionDescribing { }
extension ExpenditureCalculationMode: ExpenditureOptionDescribing { }
extension ExpenditureAlgorithmVersion: ExpenditureOptionDescribing { }

extension CoreBuilder {
    
    func expenditureSettingsView(router: AnyRouter, delegate: ExpenditureSettingsDelegate) -> some View {
        ExpenditureSettingsView(
            presenter: ExpenditureSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExpenditureSettingsView(delegate: ExpenditureSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.expenditureSettingsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ExpenditureSettingsDelegate()
    
    return RouterView { router in
        builder.expenditureSettingsView(router: router, delegate: delegate)
    }
    
}
