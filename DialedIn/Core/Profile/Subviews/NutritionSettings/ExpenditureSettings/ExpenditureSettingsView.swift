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
                    symbolName: "",
                    title: "Estimation Method",
                    subtitle: "Default") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomLabelButtonView(
                    symbolName: "",
                    title: "Calculation Start Date",
                    subtitle: "Default") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomLabelButtonView(
                    symbolName: "",
                    title: "BMR Equation",
                    subtitle: "Configure how your BMR is initially calculated") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {

                            }
                    }
            } header: {
                Text("Initial Estimate")
            }

            Section {
                CustomLabelButtonView(
                    symbolName: "",
                    title: "Calculation Mode",
                    subtitle: "Dynamic") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomLabelButtonView(
                    symbolName: "",
                    title: "Algorithm",
                    subtitle: "Expenditure V1") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
            } header: {
                Text("Expenditure Calculation")
            }

            Section {
                CustomToggleView(
                    symbolName: "",
                    title: "Step-Informed Updates",
                    subtitle: "Uses step trends to speed up expenditure updates during periods where the step data improves confidence",
                    bool: $presenter.stepInformedUpdates
                )
                CustomToggleView(
                    symbolName: "",
                    title: "Predictive Goal Adjustment",
                    subtitle: "Applies a predictive adjustment to expenditure based on the likely impact of goal changes",
                    bool: $presenter.predictiveGoalAdjustments
                )
            } header: {
                Text("Expenditure Modifiers")
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
}

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
