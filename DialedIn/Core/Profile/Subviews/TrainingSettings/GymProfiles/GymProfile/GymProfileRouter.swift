import SwiftUI

@MainActor
protocol GymProfileRouter: GlobalRouter {
    func showEditFreeWeightView(freeWeight: Binding<FreeWeights>)
    func showEditLoadableBarView(loadableBar: Binding<LoadableBars>)
    func showEditFixedWeightBarView(fixedWeightBar: Binding<FixedWeightBars>)
    func showEditBandView(band: Binding<Bands>)
    func showEditBodyWeightView(bodyWeight: Binding<BodyWeights>)
    func showEditLoadableAccessoryView(loadableAccessory: Binding<LoadableAccessoryEquipment>)
    func showEditCableMachineView(cableMachine: Binding<CableMachine>)
    func showEditPlateLoadedMachineView(plateLoadedMachine: Binding<PlateLoadedMachine>)
    func showEditPinLoadedMachineView(pinLoadedMachine: Binding<PinLoadedMachine>)
    
    func showCompleteAccountSetupView()
    func showNotificationsPermissionsView()
    func showOnboardingHealthDataView()
    func showHealthDisclaimerView()
    func showGoalSettingView()
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate)
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate)
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
    
}

extension CoreRouter: GymProfileRouter { }
