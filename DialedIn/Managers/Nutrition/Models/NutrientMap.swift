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
}

extension NutrientMap: Sequence {
    func makeIterator() -> Dictionary<NutrientKey, Double>.Iterator {
        storage.makeIterator()
    }
}
