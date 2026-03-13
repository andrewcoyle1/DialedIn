//
//  MealItemLabel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/03/2026.
//

import SwiftUI

struct MealItemLabel: View {
    let mealItem: MealItemModel
    var showImage: Bool = true
    var showCalories: Bool = true
    var showMacros: Bool = true
    let onEditPressed: (MealItemModel) -> Void

    var body: some View {
        HStack {
            if showImage {
                ImageLoaderView(resizingMode: .fill, clipShape: AnyShape(Circle()))
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30, maxHeight: 30)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(mealItem.displayName)
                    .font(.subheadline)
                HStack(spacing: 4) {
                    if showCalories {
                        Text("\(Int(mealItem.calories ?? 0)) kcal")
                    }
                    if showMacros {
                        Text(String(format: "%.1f P", mealItem.proteinGrams ?? 0))
                        Text(String(format: "%.1f F", mealItem.fatGrams ?? 0))
                        Text(String(format: "%.1f C", mealItem.carbGrams ?? 0))
                    }
                    Divider()
                    Text(String(format: "%g %@", mealItem.amount, mealItem.unit))
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .lineLimit(1)

            Spacer()
            Button {
                onEditPressed(mealItem)
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
        }
    }
}

#Preview {
    List {
        HStack {
            ZStack {

            }
            .frame(width: 80)
            MealItemLabel(
                mealItem: .mock,
                onEditPressed: { _ in

                }
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {

            }
        }
    }
}
