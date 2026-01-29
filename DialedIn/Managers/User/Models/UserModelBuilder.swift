//
//  UserModelBuilder.swift
//  DialedIn
//
//  Created by Andrew Coyle on 01/11/2025.
//

import Foundation

struct UserModelBuilder: Sendable, Hashable {
    var gender: Gender
    var dateOfBirth: Date?
    var height: Double?
    var lengthUnitPreference: LengthUnitPreference?
    var weight: Double?
    var weightUnitPreferene: WeightUnitPreference?
    var exerciseFrequency: ExerciseFrequency?
    var activityLevel: ActivityLevel?
    var cardioFitness: CardioFitnessLevel?

    mutating func setGender(_ gender: Gender) {
        self.gender = gender
    }

    mutating func setDateOfBirth(_ dateOfBirth: Date) {
        self.dateOfBirth = dateOfBirth
    }

    mutating func setHeight(_ height: Double, lengthUnitPreference: LengthUnitPreference) {
        self.height = height
        self.lengthUnitPreference = lengthUnitPreference
    }

    mutating func setWeight(_ weight: Double, weightUnitPreferene: WeightUnitPreference) {
        self.weight = weight
        self.weightUnitPreferene = weightUnitPreferene
    }

    mutating func setExerciseFrequency(_ exerciseFrequency: ExerciseFrequency) {
        self.exerciseFrequency = exerciseFrequency
    }

    mutating func setActivityLevel(_ activityLevel: ActivityLevel) {
        self.activityLevel = activityLevel
    }

    mutating func setCardioFitness(_ cardioFitness: CardioFitnessLevel) {
        self.cardioFitness = cardioFitness
    }

    var eventParameters: [String: Any] {
        let params = [
            "gender": self.gender,
            "dateOfBirth": self.dateOfBirth as Any,
            "height": self.height as Any,
            "lengthUnitPreference": self.lengthUnitPreference as Any,
            "weight": self.weight as Any,
            "weightUnitPreferene": self.weightUnitPreferene as Any,
            "exerciseFrequency": self.exerciseFrequency as Any,
            "activityLevel": self.activityLevel as Any,
            "cardioFitness": self.cardioFitness as Any
        ]

        return params
    }

    static var dobMock: UserModelBuilder {
        UserModelBuilder(gender: .male, dateOfBirth: .now)
    }

    static var heightMock: UserModelBuilder {
        UserModelBuilder(gender: .male, dateOfBirth: .now, height: 175)
    }

    static var weightMock: UserModelBuilder {
        UserModelBuilder(
            gender: .male,
            dateOfBirth: .now,
            height: 175,
            lengthUnitPreference: .centimeters,
            weight: 80,
            weightUnitPreferene: .kilograms
        )
    }

    static var exerciseFrequencyMock: UserModelBuilder {
        UserModelBuilder(
            gender: .male,
            dateOfBirth: .now,
            height: 175,
            lengthUnitPreference: .centimeters,
            weight: 80,
            weightUnitPreferene: .kilograms,
            exerciseFrequency: .fiveToSix
        )
    }

    static var activityLevelMock: UserModelBuilder {
        UserModelBuilder(
            gender: .male,
            dateOfBirth: .now,
            height: 175,
            lengthUnitPreference: .centimeters,
            weight: 80,
            weightUnitPreferene: .kilograms,
            exerciseFrequency: .oneToTwo,
            activityLevel: .active
        )
    }

    static var cardioFitnessMock: UserModelBuilder {
        UserModelBuilder(
            gender: .male,
            dateOfBirth: .now,
            height: 175,
            lengthUnitPreference: .centimeters,
            weight: 80,
            weightUnitPreferene: .kilograms,
            exerciseFrequency: .daily,
            activityLevel: .active,
            cardioFitness: .advanced
        )
    }

    static var mock: UserModelBuilder {
        self.cardioFitnessMock
    }
}
