//
//  OnboardingTrainingSplitView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingSplitView: View {

    @State var presenter: OnboardingTrainingSplitPresenter

    var delegate: OnboardingTrainingSplitDelegate

    var body: some View {
        List {
            ForEach(TrainingSplitType.allCases, id: \.self) { split in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(split.description)
                                .font(.headline)
                            Text(split.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Typically \(split.typicalDaysPerWeek) days per week")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: presenter.selectedSplit == split ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedSplit == split ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.selectedSplit = split }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Split")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToSchedule(delegate: delegate)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedSplit == nil)
        }
    }
}

extension CoreBuilder {
    func onboardingTrainingSplitView(router: AnyRouter, delegate: OnboardingTrainingSplitDelegate) -> some View {
        OnboardingTrainingSplitView(
            presenter: OnboardingTrainingSplitPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingTrainingSplitView(delegate: OnboardingTrainingSplitDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingSplitView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTrainingSplitView(
            router: router,
            delegate: OnboardingTrainingSplitDelegate.mock
        )
    }
    
}

enum TrainingSplitType: CaseIterable {
    case ppl
    case bodyparts
    case upperLower
    case fullBody
    
    var description: String {
        switch self {
        case .ppl: return "Push/Pull/Legs"
        case .bodyparts: return "Bodyparts"
        case .upperLower: return "Upper/Lower"
        case .fullBody: return "Full Body"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .ppl:
            return "Push pull legs split"
        case .bodyparts:
            return "Bodyparts split"
        case .upperLower:
            return "Upper lower split"
        case .fullBody:
            return "Full Body split"
        }
    }
    
    var typicalDaysPerWeek: Int {
        switch self {
        case .ppl: return 6
        case .bodyparts: return 5
        case .upperLower: return 4
        case .fullBody: return 3
        }
    }
}
