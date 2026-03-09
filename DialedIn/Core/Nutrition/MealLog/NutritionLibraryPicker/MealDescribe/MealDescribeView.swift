import SwiftUI

struct MealDescribeDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct MealDescribeView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: MealDescribePresenter
    let delegate: MealDescribeDelegate
    
    var body: some View {
        List {
            Section {
                PromptedTextEditor(
                    text: $presenter.descriptionText,
                    prompt: "Describe your meal"
                )
            } header: {
                HStack {
                    Text("Meal Description")
                    Spacer()
                    Text("\(presenter.descriptionText.count)/500")
                }
            } footer: {
                Text("Common foods only")
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .searchable(text: .constant(""), prompt: "Filter Recipes")
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Text("Log Foods")
                }
                .buttonStyle(.glassProminent)
            }
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = MealDescribeDelegate()
    
    return RouterView { router in
        builder.mealDescribeView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func mealDescribeView(router: AnyRouter, delegate: MealDescribeDelegate) -> some View {
        MealDescribeView(
            presenter: MealDescribePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showMealDescribeView(delegate: MealDescribeDelegate) {
        router.showScreen(.push) { router in
            builder.mealDescribeView(router: router, delegate: delegate)
        }
    }
    
}
