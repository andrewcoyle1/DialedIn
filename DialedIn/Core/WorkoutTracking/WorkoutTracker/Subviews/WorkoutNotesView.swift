//
//  WorkoutNotesView.swift
//  DialedIn
//
//  Created by AI Assistant on 21/10/2025.
//

import SwiftUI

struct WorkoutNotesView: View {
    @Binding var notes: String
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $notes)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Workout Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Workout Notes View") {
    Text("Hello")
        .sheet(isPresented: Binding.constant(true)) {
            WorkoutNotesView(notes: Binding.constant("")) {
                // Implement save action for preview if needed
            }
        }
}
