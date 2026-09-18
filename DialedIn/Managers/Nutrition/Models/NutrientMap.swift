//
//  NutrientMap.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/03/2026.
//

import Foundation

struct NutrientMap: Codable, Equatable, Hashable, Sendable, ExpressibleByDictionaryLiteral {
    private var storage: [NutrientKey: Double]

    init(_ dict: [NutrientKey: Double] = [:]) { storage = dict }

    init(dictionaryLiteral elements: (NutrientKey, Double)...) {
        storage = Dictionary(uniqueKeysWithValues: elements)
    }

    // MARK: Codable — encode/decode as [String: Double]
    func encode(to encoder: Encoder) throws {
        let stringDict = Dictionary(uniqueKeysWithValues: storage.map { ($0.key.rawValue, $0.value) })
        try stringDict.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        let stringDict = try [String: Double](from: decoder)
        storage = Dictionary(uniqueKeysWithValues: stringDict.compactMap {
            guard let key = NutrientKey(rawValue: $0.key) else { return nil }
            return (key, $0.value)
        })
    }

    // MARK: Subscripts
    subscript(key: NutrientKey) -> Double? {
        get { storage[key] }
        set { storage[key] = newValue }
    }

    subscript(key: NutrientKey, default defaultValue: Double) -> Double {
        get { storage[key, default: defaultValue] }
        set { storage[key, default: defaultValue] = newValue }
    }

    // MARK: mapValues
    func mapValues(_ transform: (Double) throws -> Double) rethrows -> NutrientMap {
        NutrientMap(try storage.mapValues(transform))
    }

    /// Nutrients are stored per 100g/100ml, so logging an amount means scaling every value by the
    /// same factor. Callers pass `amount / 100`, not the amount itself.
    func scaled(by factor: Double) -> NutrientMap {
        mapValues { $0 * factor }
    }

    /// Sums two snapshots nutrient by nutrient, for totalling a plate or a day.
    ///
    /// A nutrient present in one map and absent from the other is carried through as-is: absent
    /// means "this food's data does not record it", not "this food contains none of it", but for a
    /// total there is nothing better to do than add what is known.
    static func + (lhs: NutrientMap, rhs: NutrientMap) -> NutrientMap {
        NutrientMap(lhs.storage.merging(rhs.storage) { $0 + $1 })
    }

    static func += (lhs: inout NutrientMap, rhs: NutrientMap) {
        lhs = lhs + rhs
    }

    /// The nutrients this map actually records, in `NutrientKey` declaration order so a breakdown
    /// reads total-first (total fat before saturated, carbs before fibre).
    func recordedKeys(in category: Macros) -> [NutrientKey] {
        category.details.filter { storage[$0] != nil }
    }
}

extension NutrientMap: Sequence {
    func makeIterator() -> Dictionary<NutrientKey, Double>.Iterator {
        storage.makeIterator()
    }
}
