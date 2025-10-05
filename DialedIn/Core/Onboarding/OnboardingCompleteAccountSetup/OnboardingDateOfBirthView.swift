//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingDateOfBirthView: View {
    
    let gender: Gender
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case height(gender: Gender, dateOfBirth: Date)
    }
    var body: some View {
        List {
            DatePicker(selection: $dateOfBirth, displayedComponents: .date) {
                Text("When were you born?")
                    .foregroundStyle(Color.secondary)
            }
            .removeListRowFormatting()
        }
        .navigationTitle("Date of birth")
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.accent)
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                }
                .anyButton(.press) {
                    onContinue()
                }
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .height = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .height(gender, dateOfBirth) = navigationDestination {
                OnboardingHeightView(gender: gender, dateOfBirth: dateOfBirth)
            } else {
                EmptyView()
            }
        }
    }

    private func onContinue() {
        navigationDestination = .height(gender: gender, dateOfBirth: dateOfBirth)
    }
}

#Preview {
    NavigationStack {
        OnboardingDateOfBirthView(gender: .male)
    }
    .previewEnvironment()
}
