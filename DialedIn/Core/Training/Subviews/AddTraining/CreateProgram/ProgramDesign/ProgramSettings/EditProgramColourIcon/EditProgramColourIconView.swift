import SwiftUI

struct EditProgramColourIconView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var presenter: EditProgramColourIconPresenter

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ForEach(presenter.colours, id: \.self) { colour in
                    ZStack {
                        Circle().opacity(0.3)
                        Image(systemName: presenter.selectedIcon)
                    }
                    .foregroundStyle(colour)
                    .overlay {
                        Circle()
                            .stroke(colour == presenter.selectedColour ? colour : Color.clear, lineWidth: 4)
                    }
                    .anyButton {
                        presenter.onColourPressed(colour)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            LazyVGrid(columns: Array(repeating: GridItem(), count: 6)) {
                ForEach(presenter.icons, id: \.self) { icon in
                    ZStack {
                        Circle()
                            .opacity(0.3)
                            .frame(maxWidth: 40)
                        Image(systemName: icon)
                    }
                    .foregroundStyle(presenter.selectedColour)
                    .padding(.vertical, 4)
                    .overlay {
                        Circle()
                            .stroke(icon == presenter.selectedIcon ? presenter.selectedColour : Color.clear, lineWidth: 4)
                    }
                    .anyButton {
                        presenter.onIconPressed(icon)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .background(colorScheme.backgroundSecondary)
        .navigationTitle("Colour & Icon")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { presenter.onCancelPressed() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { presenter.onSavePressed() }
            }
        }
    }
}

extension CoreBuilder {
    func editProgramColourIconView(router: AnyRouter, colour: String, icon: String, onSave: @escaping (String, String) -> Void) -> some View {
        let coreRouter = CoreRouter(router: router, builder: self)
        return EditProgramColourIconView(
            presenter: EditProgramColourIconPresenter(
                colour: colour,
                icon: icon,
                onSave: onSave,
                router: coreRouter
            )
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    RouterView { router in
        builder.editProgramColourIconView(
            router: router,
            colour: Color.blue.asHex(),
            icon: "flag.pattern.checkered",
            onSave: { _, _ in }
        )
    }
}
