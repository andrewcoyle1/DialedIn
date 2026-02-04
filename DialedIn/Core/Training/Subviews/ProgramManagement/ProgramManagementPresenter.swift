//
//  ProgramManagementPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProgramManagementPresenter {
    private let interactor: ProgramManagementInteractor
    private let router: ProgramManagementRouter

    private(set) var isLoading = false
    
    private(set) var savedPrograms: [TrainingProgram] = []
    
    init(
        interactor: ProgramManagementInteractor,
        router: ProgramManagementRouter
    ) {
        self.interactor = interactor
        self.router = router
        
        Task { [weak self] in
            await self?.loadSavedPrograms()
        }
    }
    
    func loadSavedPrograms() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            savedPrograms = try interactor.readAllLocalTrainingPrograms()
        } catch {
            savedPrograms = []
        }
    }

    func showDeleteAlert(program: TrainingProgram) {
        router.showAlert(
            title: "Delete Program",
            subtitle: "Are you sure you want to delete your active program '\(program.name)'? This will remove all scheduled workouts and you'll need to create or select a new program.",
            buttons: {
                AnyView(
                    Group {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            Task {
                                await self.deleteProgram(program)
                            }
                        }
                    }
                )
            }
        )
    }

    func onSavedProgramPressed(_ program: TrainingProgram) {
        let programBinding = Binding<TrainingProgram>(
            get: { [weak self] in
                self?.savedPrograms.first { $0.id == program.id } ?? program
            },
            set: { [weak self] newValue in
                if let index = self?.savedPrograms.firstIndex(where: { $0.id == newValue.id }) {
                    self?.savedPrograms[index] = newValue
                }
            }
        )
        router.showProgramSettingsView(program: programBinding)
    }
    
    func deleteProgram(_ program: TrainingProgram) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await interactor.deleteTrainingProgram(program: program)
            await loadSavedPrograms()
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
        
    func onCreateProgramPressed() {
        router.showCreateProgramView(delegate: CreateProgramDelegate())
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
