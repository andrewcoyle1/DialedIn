import SwiftUI
import PhotosUI

struct FoodPackagingDelegate {
    let name: String
    let brandName: String?
    let barcode: String?
    let image: PlatformImage?
    var eventParameters: [String: Any]? {
        nil
    }
}

struct FoodPackagingView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: FoodPackagingPresenter
    let delegate: FoodPackagingDelegate
    
    var body: some View {
        List {
            Section { } header: {
                Text("Photos of Food Packaging")
            }
            .listSectionSpacing(0)
            Section {
                Image(systemName: "camera")
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .anyButton(.press) {
                        presenter.onFrontImageSelectorPressed()
                    }
            } header: {
                Text("Product Front")
            }
            Section {
                Image(systemName: "camera")
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .anyButton(.press) {
                        presenter.onRearImageSelectorPressed()
                    }
            } header: {
                Text("Nutrition Facts")
            }
            Section {
                Text("How these photos are used.")
                    .bold()
                +
                Text(" Photos for each new product submission and edit are used by DialedIn and ")
                +
                Text("Open Food Facts")
                    .underline()
                +
                Text(" to increase the quality of the global barcode database. Photos will be made public, but won't be stored in your custom food.")
            } footer: {
                HStack {
                    Text("Don't ask for product images again")
                    Spacer()
                    Image(systemName: "checkmark.circle")
                }
            }
        }
        .navigationTitle("Create Food")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onNextPressed(delegate: delegate)
            } label: {
                Text("Next")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
        .photosPicker(isPresented: $presenter.isFrontImagePickerPresented, selection: $presenter.selectedFrontPhotoItem, matching: .images)
        .photosPicker(isPresented: $presenter.isRearImagePickerPresented, selection: $presenter.selectedRearPhotoItem, matching: .images)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FoodPackagingDelegate(
        name: "Coke Zero",
        brandName: "Coca Cola",
        barcode: "5000112633320",
        image: nil
    )
    
    return RouterView { router in
        builder.foodPackagingView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func foodPackagingView(router: AnyRouter, delegate: FoodPackagingDelegate) -> some View {
        FoodPackagingView(
            presenter: FoodPackagingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showFoodPackagingView(delegate: FoodPackagingDelegate) {
        router.showScreen(.push) { router in
            builder.foodPackagingView(router: router, delegate: delegate)
        }
    }
    
}
