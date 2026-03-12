import SwiftUI

@Observable
@MainActor
class EditProgramColourIconPresenter {

    private let router: EditProgramColourIconRouter

    var selectedColour: Color
    var selectedIcon: String

    var colours: [Color] { ProgramIconPresenter.defaultColours }
    var icons: [String] { ProgramIconPresenter.defaultIcons }

    private let onSave: (String, String) -> Void

    init(colour: String, icon: String, onSave: @escaping (String, String) -> Void, router: EditProgramColourIconRouter) {
        self.selectedColour = Color(hex: colour)
        self.selectedIcon = icon
        self.onSave = onSave
        self.router = router
    }

    func onColourPressed(_ colour: Color) {
        selectedColour = colour
    }

    func onIconPressed(_ icon: String) {
        selectedIcon = icon
    }

    func onSavePressed() {
        onSave(selectedColour.asHex(), selectedIcon)
        router.dismissScreen()
    }

    func onCancelPressed() {
        router.dismissScreen()
    }
}
