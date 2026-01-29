//
//  CopyWeekPickerSheet.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI
import SwiftfulRouting

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
                        presenter.onSelect(week: week, onSelect: delegate.onSelect)
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

extension CoreBuilder {
    func copyWeekPickerView(router: AnyRouter, delegate: CopyWeekPickerDelegate) -> some View {
        CopyWeekPickerView(
            presenter: CopyWeekPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showCopyWeekPickerView(delegate: CopyWeekPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.copyWeekPickerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
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
