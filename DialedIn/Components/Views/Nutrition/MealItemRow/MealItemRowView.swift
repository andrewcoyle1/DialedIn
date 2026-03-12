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

    var body: some View {
        HStack {
            ZStack {
                if item == mealLogModel.items.first {
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
            .frame(width: 80, alignment: .leading)
 
            HStack {
                Text("• \(item.displayName)")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(item.amount)) \(item.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(colorScheme.backgroundPrimary, in: .capsule)
        }
    }
}

#Preview {
    let mealLogModel: MealLogModel = MealLogModel.mock
    
    List {
        ForEach(mealLogModel.items) { item in
            MealItemRowView(mealLogModel: mealLogModel, item: item)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                
            }
        }
        .removeListRowFormatting()
        .listRowSeparator(.hidden)
    }
}
