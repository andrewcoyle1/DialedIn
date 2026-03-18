//
//  TrainingProgramLibraryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct TrainingProgramLibraryView<ProgramDisclosureGroup: View, InactiveSection: View>: View {

    @State var presenter: TrainingProgramLibraryPresenter

    @ViewBuilder var trainingProgramDisclosueGroup: (TrainingProgramDisclosureGroupDelegate) -> ProgramDisclosureGroup
    @ViewBuilder var inactiveProgramSection: (InactiveTrainingProgramDelegate) -> InactiveSection
    
    var body: some View {
        List {
            if let activeTrainingProgram = presenter.activeTrainingProgram {
                activeTrainingProgramSection(activeTrainingProgram: activeTrainingProgram)
            }
            if !presenter.nonActiveTrainingPrograms.isEmpty {
                savedProgramsSection
            }
            if presenter.savedPrograms.isEmpty && presenter.activeTrainingProgram == nil {
                emptyState
            }
        }
        .navigationTitle("My Programs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }
    
    private func activeTrainingProgramSection(activeTrainingProgram: TrainingProgram) -> some View {
        Section {
            trainingProgramDisclosueGroup(TrainingProgramDisclosureGroupDelegate(trainingProgram: activeTrainingProgram))
        } header: {
            Text("Active Training Program")
        }
    }

    private var savedProgramsSection: some View {
        Section {
            inactiveProgramSection(InactiveTrainingProgramDelegate(inactivePrograms: presenter.nonActiveTrainingPrograms))
//            ForEach(presenter.nonActiveTrainingPrograms) { program in
//                savedProgramRow(program)
//                    .swipeActions(edge: .trailing) {
//                        Button(role: .destructive) {
//                            presenter.showDeleteAlert(program: program)
//                        }
//                    }
//            }
        } header: {
            Text("Saved Programs")
        } footer: {
            Text("These are saved program designs. Start a program from a template to generate a scheduled plan.")
        }
    }
    
    private func savedProgramRow(_ program: TrainingProgram) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: program.colour).opacity(0.2))
                
                Image(systemName: program.icon)
                    .foregroundStyle(Color(hex: program.colour))
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(program.name)
                    .font(.headline)
                
                Text("\(program.workoutTemplates.count) days • \(program.numMicrocycles) cycles")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .anyButton {
            presenter.onSavedProgramPressed(program)
        }
    }
        
    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Programs", systemImage: "calendar.badge.clock")
        } description: {
            Text("Create your first training program to get started")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                presenter.onCreateProgramPressed()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

extension CoreBuilder {
    func trainingProgramLibraryView(router: AnyRouter) -> some View {
        TrainingProgramLibraryView(
            presenter: TrainingProgramLibraryPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            ),
            trainingProgramDisclosueGroup: { delegate in
                self.trainingProgramDisclosureGroupView(router: router, delegate: delegate)
            },
            inactiveProgramSection: { delegate in
                self.inactiveTrainingProgramView(router: router, delegate: delegate)
            }
        )
    }
}

extension CoreRouter {
    func showTrainingProgramLibraryView() {
        router.showScreen(.sheet) { router in
            builder.trainingProgramLibraryView(router: router)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.trainingProgramLibraryView(router: router)
    }
    
}
