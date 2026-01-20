import SwiftUI

@Observable
@MainActor
class ProgramIconPresenter {
    
    private let interactor: ProgramIconInteractor
    private let router: ProgramIconRouter
    
    static let defaultColours: [Color] = [
        .primary,
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        .purple
    ]
    
    static let defaultIcons: [String] = [
        "flag.pattern.checkered",
        "arcade.stick",
        "gamecontroller",
        "figure.walk",
        "airplane.up.right",
        "sailboat.fill",
        "gauge.with.dots.needle.bottom.100percent"
    ]
    
    var colours: [Color] {
        Self.defaultColours
    }
    
    var icons: [String] {
        Self.defaultIcons
    }
    
    private(set) var selectedColour: Color
    private(set) var selectedIcon: String

    init(interactor: ProgramIconInteractor, router: ProgramIconRouter) {
        self.interactor = interactor
        self.router = router
        self.selectedColour = Self.defaultColours.first ?? .accentColor
        self.selectedIcon = Self.defaultIcons.first ?? "flag.pattern.checkered"
    }
    
    func onColourPressed(colour: Color) {
        selectedColour = colour
    }
    
    func onIconPressed(icon: String) {
        selectedIcon = icon
    }
    
    func onNextPressed(name: String) {
        router.showProgramDesignView(delegate: ProgramDesignDelegate(id: UUID().uuidString, name: name, colour: selectedColour, icon: selectedIcon))
    }
}
