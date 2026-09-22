//
//  AppToastView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/09/2026.
//

import SwiftUI

/// The app-level toast. Shaped like `ActivityNotificationBannerView` so the two read as the same
/// piece of furniture when either one appears.
struct AppToastView: View {

    let toast: AppToast

    private var iconName: String {
        switch toast.style {
        case .progress: return "arrow.clockwise"
        case .success:  return "checkmark.circle.fill"
        case .failure:  return "exclamationmark.triangle.fill"
        }
    }

    private var iconColour: Color {
        switch toast.style {
        case .progress: return .secondary
        case .success:  return .green
        case .failure:  return .orange
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(iconColour)
                .font(.subheadline)

            Text(toast.message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(3)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack {
        AppToastView(toast: AppToast(style: .progress, message: "Couldn't save your workout. Retrying…"))
        AppToastView(toast: AppToast(style: .success, message: "Workout saved."))
        AppToastView(toast: AppToast(
            style: .failure,
            message: "Couldn't save your workout. It's still on this device — resume it from Training."
        ))
    }
    .padding(.top, 60)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(Color.gray.opacity(0.2))
}
