//
//  MealItemRowView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 12/03/2026.
//

import SwiftUI

struct MealItemRowView: View {

    @Environment(\.colorScheme) private var colorScheme

    var mealLogModel: MealLogModel
    var item: MealItemModel
    var showTimestamp: Bool = true
    var timestampSide: TimestampSide = .left
    var showImage: Bool = true
    var showCalories: Bool = true
    var showMacros: Bool = true
    var onEditPressed: (MealItemModel) -> Void

    var body: some View {
        HStack {
            if timestampSide == .left {
                timestampColumn
                itemLabel
            } else {
                itemLabel
                timestampColumn
            }
        }
        .removeListRowFormatting()
    }

    private var timestampColumn: some View {
        ZStack {
            if showTimestamp && item == mealLogModel.items.first {
                Text(
                    mealLogModel.date.formatted(
                        date: .omitted,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading)
                .padding(.leading, 8)
            }
        }
        .frame(width: 80, alignment: timestampSide == .left ? .leading : .trailing)
    }

    private var itemLabel: some View {
        MealItemLabel(
            mealItem: item,
            showImage: showImage,
            showCalories: showCalories,
            showMacros: showMacros,
            onEditPressed: { meal in
                onEditPressed(meal)
            }
        )
        .padding()
        .background(
            colorScheme.backgroundPrimary,
            in: .containerRelative
        )
    }
}

#Preview {
    @Previewable @State var mealLogModel: MealLogModel = MealLogModel.mock
    let newMealItem = MealItemModel(
        itemId: UUID().uuidString,
        sourceType: .ingredient,
        sourceId: UUID().uuidString,
        displayName: "Mixed Berry Protein Smoothie",
        amount: 1,
        unit: "serving"
    )
    mealLogModel.items.append(newMealItem)

    return List {
        Group {
            ForEach(mealLogModel.items) { item in
                Section {
                    MealItemRowView(
                        mealLogModel: mealLogModel,
                        item: item,
                        onEditPressed: { meal in
                            print(meal.displayName)
                        }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            mealLogModel.items.removeAll { meal in
                                meal.id == item.id
                            }
                        }
                    }
                }
            }
            Section {
                MealItemRowView(
                    mealLogModel: mealLogModel,
                    item: newMealItem,
                    onEditPressed: { meal in
                        print(meal.displayName)
                    }
                )
            }
        }
        .listSectionMargins(.vertical, 4)
        .listRowSeparator(.hidden)
    }
}
