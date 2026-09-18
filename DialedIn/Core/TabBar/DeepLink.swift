//
//  DeepLink.swift
//  DialedIn
//

import Foundation

/// A destination the app can be sent to from outside it — a `compound://` URL or a push
/// notification payload.
///
/// `AnalyticsPresenter.handleDeepLink` used to parse a URL's query items into a loop whose body was
/// `// Do something with value`, and `handlePushNotificationRecieved` did the same over the payload.
/// Both fired analytics and navigated nowhere, and the `compound` scheme in Info.plist had no
/// destinations behind it at all.
enum DeepLink: Equatable {

    case tab(Tab)

    /// The tab bar's roots. `Add` is the search tab, which SwiftUI owns through `Tab(role: .search)`.
    enum Tab: String, CaseIterable, Identifiable {
        case dashboard
        case training
        case nutrition
        case analytics

        var id: String { rawValue }

        /// Matches `TabBarScreen.title`, which is what the `TabView` selection is keyed on.
        var title: String {
            rawValue.capitalized
        }
    }

    /// Parses `compound://tab/nutrition`, and tolerates `compound://tab?name=nutrition` because the
    /// old handler read query items and someone may have links in that shape.
    ///
    /// Returns nil for anything unrecognised rather than guessing — an unknown link should do
    /// nothing visible, not land somewhere arbitrary.
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

        let host = components.host?.lowercased()
        let firstPath = components.path
            .split(separator: "/")
            .first
            .map { String($0).lowercased() }
        let queryName = components.queryItems?
            .first { $0.name.lowercased() == "name" || $0.name.lowercased() == "tab" }?
            .value?
            .lowercased()

        guard host == "tab" else { return nil }
        guard let name = firstPath ?? queryName, let tab = Tab(rawValue: name) else { return nil }
        self = .tab(tab)
    }

    /// The same destinations from a push payload, so a notification tap and a link agree on what
    /// they mean. Reads `deep_link` as a full URL string, or `tab` as a bare name.
    init?(pushUserInfo: [AnyHashable: Any]) {
        if let link = pushUserInfo["deep_link"] as? String, let url = URL(string: link) {
            self.init(url: url)
            return
        }
        if let name = (pushUserInfo["tab"] as? String)?.lowercased(), let tab = Tab(rawValue: name) {
            self = .tab(tab)
            return
        }
        return nil
    }
}
