//
//  MuscleGroupCardItem.swift
//  DialedIn
//

import Foundation

struct MuscleGroupCardItem: Identifiable {
    let muscle: Muscles
    let last7DaysData: [Double]
    let totalSets: Double
    var id: Muscles { muscle }
}
