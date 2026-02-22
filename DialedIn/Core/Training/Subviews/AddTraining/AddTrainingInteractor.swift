import SwiftUI

@MainActor
protocol AddTrainingInteractor: GlobalInteractor { }

extension CoreInteractor: AddTrainingInteractor { }
