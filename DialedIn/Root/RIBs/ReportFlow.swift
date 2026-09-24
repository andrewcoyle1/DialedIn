//
//  ReportFlow.swift
//  DialedIn
//

import SwiftUI

/// What a report names: the kind of thing, which one, and who made it.
struct ReportedContent: Equatable {
    let type: ReportContentType
    let id: String
    let authorUserId: String?
    /// How the alerts refer to it: "comment", "workout", "profile".
    let noun: String
}

@MainActor
protocol ReportInteractor: GlobalInteractor {
    func report(contentType: ReportContentType, contentId: String, authorUserId: String?, reason: ReportReason, notes: String?) async throws
}

extension CoreInteractor: ReportInteractor { }

/// The one report flow — ask why, send, say whether it went — shared by comments, feed cards and
/// profiles so the three do not drift apart.
@MainActor
final class ReportFlow {
    private let interactor: ReportInteractor
    private let router: GlobalRouter

    /// The content the reason picker is open for.
    private(set) var pending: ReportedContent?

    init(interactor: ReportInteractor, router: GlobalRouter) {
        self.interactor = interactor
        self.router = router
    }

    func start(_ content: ReportedContent) {
        pending = content
        router.showAlert(
            title: "Report \(content.noun.capitalized)",
            subtitle: "Why are you reporting this \(content.noun)?",
            buttons: {
                AnyView(
                    ForEach(ReportReason.allCases) { reason in
                        Button(reason.displayName) {
                            self.onReasonSelected(reason)
                        }
                    }
                )
            }
        )
    }

    func onReasonSelected(_ reason: ReportReason) {
        guard let content = pending else { return }
        pending = nil
        Task {
            do {
                try await interactor.report(
                    contentType: content.type,
                    contentId: content.id,
                    authorUserId: content.authorUserId,
                    reason: reason,
                    notes: nil
                )
                router.showSimpleAlert(
                    title: "Report Sent",
                    subtitle: "Thanks — we will take a look at this \(content.noun)."
                )
            } catch {
                router.showSimpleAlert(title: "Unable to Send Report", subtitle: "Please try again.")
            }
        }
    }
}
