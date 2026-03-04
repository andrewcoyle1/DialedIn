import SwiftUI

struct NutritionOverviewDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct NutritionOverviewView: View {
    
    @State var presenter: NutritionOverviewPresenter
    let delegate: NutritionOverviewDelegate
    
    var body: some View {
        List {
            caloriesSection
            macrosSection
            carbsSection
            fatsSection
            proteinsSection
            vitaminsSection
            mineralsSection
            otherSection
        }
        .navigationTitle("Nutrition Overview")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    private var caloriesSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            HStack {
                Text("Calories")
                Spacer()
                Toggle(isOn: $presenter.showsContributors) {
                    Text("Contributors")
                        .lineLimit(1)
                        .font(.subheadline)
                }
                .frame(width: 160)
            }
        }
    }
    
    private var macrosSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Macros")
        }
    }
    
    private var carbsSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var fatsSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Fat Breakdown")
        }
    }
        
    private var proteinsSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Protein Breakdown")
        }
    }
    
    private var vitaminsSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Vitamin Breakdown")
        }
    }
    
    private var mineralsSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Mineral Breakdown")
        }
    }
    
    private var otherSection: some View {
        Section {
            Text("Hello, World!")
        } header: {
            Text("Other")
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionOverviewDelegate()
    
    return RouterView { router in
        builder.nutritionOverviewView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func nutritionOverviewView(router: AnyRouter, delegate: NutritionOverviewDelegate) -> some View {
        NutritionOverviewView(
            presenter: NutritionOverviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showNutritionOverviewView(delegate: NutritionOverviewDelegate) {
        router.showScreen(.push) { router in
            builder.nutritionOverviewView(router: router, delegate: delegate)
        }
    }
    
}
