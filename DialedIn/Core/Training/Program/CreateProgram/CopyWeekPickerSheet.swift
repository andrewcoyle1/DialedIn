//
//  CopyWeekPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI
import CustomRouting

struct CopyWeekPickerDelegate {
    let availableWeeks: [Int]
    let onSelect: (Int) -> Void
}

protocol CopyWeekPickerInteractor {

}

extension CoreInteractor: CopyWeekPickerInteractor { }

@MainActor
protocol CopyWeekPickerRouter {
    func dismissScreen()
}

extension CoreRouter: CopyWeekPickerRouter { }

@Observable
@MainActor
class CopyWeekPickerPresenter {
    private let interactor: CopyWeekPickerInteractor
    private let router: CopyWeekPickerRouter

    init(
        interactor: CopyWeekPickerInteractor,
        router: CopyWeekPickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

struct CopyWeekPickerView: View {

    @State var presenter: CopyWeekPickerPresenter

    let delegate: CopyWeekPickerDelegate

    var body: some View {
        List {
            if delegate.availableWeeks.isEmpty {
                Text("No previous weeks available")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(delegate.availableWeeks, id: \.self) { week in
                    Button {
                        delegate.onSelect(week)
                    } label: {
                        HStack {
                            Text("Week \(week)")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Copy from Week")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = CopyWeekPickerDelegate(
        availableWeeks: [1, 2, 3],
        onSelect: { week in
            print("Selected week \(week)")
        }
    )
    RouterView { router in
        builder.copyWeekPickerView(router: router, delegate: delegate)
    }
}
