//
//  GenericTemplatePickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/10/2025.
//

import Foundation

/// Generic view model for template picker views
@Observable
@MainActor
class GenericTemplatePickerPresenter<Template: TemplateModel> {
    private let getAllLocalTemplates: () throws -> [Template]
    private let getTemplatesByName: (String) async throws -> [Template]
    private let getTopTemplatesByClicks: (Int) async throws -> [Template]
    private let getTemplatesForAuthor: (String) async throws -> [Template]
    private let getAuthId: () -> String?
    
    let configuration: TemplatePickerConfiguration<Template>

    let onSelect: (Template) -> Void
    let onCancel: () -> Void

    var searchText: String = ""
    var officialResults: [Template] = []
    var userResults: [Template] = []
    var isLoading: Bool = false

    init(
        getAllLocalTemplates: @escaping () throws -> [Template],
        getTemplatesByName: @escaping (String) async throws -> [Template],
        getTopTemplatesByClicks: @escaping (Int) async throws -> [Template],
        getTemplatesForAuthor: @escaping (String) async throws -> [Template],
        getAuthId: @escaping () -> String?,
        configuration: TemplatePickerConfiguration<Template>,
        onSelect: @escaping (Template) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.getAllLocalTemplates = getAllLocalTemplates
        self.getTemplatesByName = getTemplatesByName
        self.getTopTemplatesByClicks = getTopTemplatesByClicks
        self.getTemplatesForAuthor = getTemplatesForAuthor
        self.getAuthId = getAuthId
        self.configuration = configuration
        self.onSelect = onSelect
        self.onCancel = onCancel
    }

    func loadTopTemplates() async {
        isLoading = true
        defer { isLoading = false }
        // Include local and remote templates
        let localAll = (try? getAllLocalTemplates()) ?? []
        let uid = getAuthId()
        let remoteTop = (try? await getTopTemplatesByClicks(15)) ?? []
        var remoteUser: [Template] = []
        if let id = uid {
            remoteUser = (try? await getTemplatesForAuthor(id)) ?? []
        }
        let combined = mergeUnique(localAll + remoteTop + remoteUser)
        userResults = combined.filter { configuration.extractAuthorId($0) == uid }
        officialResults = combined.filter { configuration.extractAuthorId($0) != uid }
    }

    func runSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { await loadTopTemplates(); return }
        isLoading = true
        defer { isLoading = false }
        // Local and remote search
        let localAll = (try? getAllLocalTemplates()) ?? []
        let uid = getAuthId()
        let localMatches = localAll.filter { template in
            template.name.localizedCaseInsensitiveContains(query)
        }
        let remoteFound = (try? await getTemplatesByName(query)) ?? []
        var remoteUser: [Template] = []
        if let id = uid {
            remoteUser = (try? await getTemplatesForAuthor(id)) ?? []
        }
        let combined = mergeUnique(localMatches + remoteFound + remoteUser)
        userResults = combined.filter { configuration.extractAuthorId($0) == uid }
        officialResults = combined.filter { configuration.extractAuthorId($0) != uid }
    }

    private func mergeUnique(_ items: [Template]) -> [Template] {
        var seen = Set<String>()
        var merged: [Template] = []
        for item in items where !seen.contains(item.id) {
            seen.insert(item.id)
            merged.append(item)
        }
        return merged
    }
}
