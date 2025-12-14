//
//  WorkoutNotesDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/12/2025.
//

import SwiftUI

struct WorkoutNotesDelegate {
    var notes: Binding<String>
    let onSave: () -> Void
}
