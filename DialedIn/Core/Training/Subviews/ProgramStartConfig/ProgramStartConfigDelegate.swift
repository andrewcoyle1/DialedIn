//
//  ProgramStartConfigDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

struct ProgramStartConfigDelegate {
    let template: ProgramTemplateModel
    let onStart: (Date, Date?, String?) -> Void
}
