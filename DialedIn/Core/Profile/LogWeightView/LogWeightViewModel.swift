//
//  LogWeightViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class LogWeightViewModel {
    private let userManager: UserManager
    private let userWeightManager: UserWeightManager
    
    var selectedDate = Date()
    var selectedKilograms: Int = 70
    var selectedPounds: Int = 154
    var notes: String = ""
    var unit: UnitOfWeight = .kilograms
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    private var weightKg: Double {
        switch unit {
        case .kilograms:
            return Double(selectedKilograms)
        case .pounds:
            return Double(selectedPounds) * 0.453592
        }
    }
    
    var weightHistory: [WeightEntry] {
        userWeightManager.weightHistory
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.userWeightManager = container.resolve(UserWeightManager.self)!
    }
    
    func loadInitialData() async {
        guard let user = userManager.currentUser else { return }
        
        // Set initial unit based on user preference
        if let preference = user.weightUnitPreference {
            unit = preference == .kilograms ? .kilograms : .pounds
        }
        
        // Set initial weight to current weight if available
        if let currentWeight = user.weightKilograms {
            selectedKilograms = Int(currentWeight)
            selectedPounds = Int(currentWeight * 2.20462)
        }
        
        // Load recent entries
        _ = try? await userWeightManager.getWeightHistory(userId: user.userId, limit: 5)
    }
    
    func saveWeight(onDismiss: @escaping () -> Void) async {
        guard let user = userManager.currentUser else { return }
        
        isLoading = true
        
        do {
            // Save weight entry
            try await userWeightManager.logWeight(
                weightKg,
                date: selectedDate,
                notes: notes.isEmpty ? nil : notes,
                userId: user.userId
            )
            
            // Update user's current weight
            try await userManager.updateWeight(userId: user.userId, weightKg: weightKg)
            
            // Success haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
            
            onDismiss()
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
        
        isLoading = false
    }
    
    func formatWeight(_ weightKg: Double) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weightKg)
        case .pounds:
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
}
