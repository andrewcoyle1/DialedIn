//
//  FoodDefinitionPresenterTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 21/09/2026.
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// The last step of creating a food: the nutrition panel the user types off a label.
///
/// What is entered here is stored forever and scaled on every future serving, so two things
/// matter more than the rest — that a figure entered per-serving is normalised to per-100g before
/// it is saved, and that a nutrient nobody entered is absent rather than zero.
@MainActor
struct FoodDefinitionPresenterTests {

    // MARK: - Doubles

    private final class Interactor: SpyGlobalInteractor, FoodDefinitionInteractor {
        var currentUser: UserModel? = UserModel(userId: "user-1")
        private(set) var savedFoods: [FoodModel] = []
        var saveError: Error?

        func saveFood(_ ingredient: FoodModel, image: PlatformImage?) async throws {
            if let saveError { throw saveError }
            savedFoods.append(ingredient)
        }
    }

    private final class Router: FoodDefinitionRouter {
        let router: AnyRouter = TestRouting.anyRouter
    }

    /// Holds the meal items the "create and add" path appends to.
    private final class ItemBox {
        var items: [MealItemModel] = []
    }

    private struct Screen {
        let presenter: FoodDefinitionPresenter
        let interactor: Interactor
        let box: ItemBox
        let delegate: FoodDefinitionDelegate
    }

    private func makeScreen(
        option: NutritionDefinitionOption = .standardMass,
        servingWeight: Double? = nil,
        name: String = "Oat Milk",
        brandName: String? = "Brand",
        barcode: String? = "5012345678900"
    ) -> Screen {
        let interactor = Interactor()
        let box = ItemBox()
        let delegate = FoodDefinitionDelegate(
            mealItems: Binding(get: { box.items }, set: { box.items = $0 }),
            nutritionDefinitionOption: option,
            image: nil,
            name: name,
            brandName: brandName,
            barcode: barcode,
            imageFront: nil,
            nutritionImage: nil,
            servingWeight: servingWeight,
            portionSize: 250,
            portionName: "glass"
        )
        return Screen(
            presenter: FoodDefinitionPresenter(interactor: interactor, router: Router()),
            interactor: interactor,
            box: box,
            delegate: delegate
        )
    }

    /// Waits for the presenter's detached save task to reach the interactor.
    private func create(_ screen: Screen) async {
        screen.presenter.onCreatePressed(delegate: screen.delegate)
        await TestManagers.eventually { !screen.interactor.savedFoods.isEmpty }
    }

    // MARK: - What gets stored

    /// The figures typed in are the figures stored.
    @Test("Test Entered Nutrients Are Saved")
    func testEnteredNutrientsAreSaved() async {
        let screen = makeScreen()
        screen.presenter.energy = 250
        screen.presenter.protein = 12
        screen.presenter.carbs = 30
        screen.presenter.fats = 8

        await create(screen)

        let saved = try? #require(screen.interactor.savedFoods.first)
        #expect(saved?.nutrients[.calories] == 250)
        #expect(saved?.nutrients[.protein] == 12)
        #expect(saved?.nutrients[.carbs] == 30)
        #expect(saved?.nutrients[.fatTotal] == 8)
    }

    /// A nutrient left blank is absent, not zero. A label that does not print its iron is not a
    /// food with no iron, and storing 0 would assert something the label never said.
    @Test("Test Untouched Nutrients Are Absent Not Zero")
    func testUntouchedNutrientsAreAbsentNotZero() async {
        let screen = makeScreen()
        screen.presenter.energy = 250

        await create(screen)

        let saved = try? #require(screen.interactor.savedFoods.first)
        #expect(saved?.nutrients[.calories] == 250)
        #expect(saved?.nutrients[.ironMg] == nil)
        #expect(saved?.nutrients[.vitaminCMg] == nil)
    }

    /// Zero entered deliberately is kept — "contains none" is a claim the label can make.
    @Test("Test An Entered Zero Is Kept")
    func testAnEnteredZeroIsKept() async {
        let screen = makeScreen()
        screen.presenter.energy = 250
        screen.presenter.fats = 0

        await create(screen)

        #expect(screen.interactor.savedFoods.first?.nutrients[.fatTotal] == 0)
    }

    /// The food carries what the earlier steps collected.
    @Test("Test The Food Carries Its Identifying Details")
    func testTheFoodCarriesItsIdentifyingDetails() async {
        let screen = makeScreen(name: "Oat Milk", brandName: "Oatly", barcode: "5012345678900")
        screen.presenter.energy = 250

        await create(screen)

        let saved = try? #require(screen.interactor.savedFoods.first)
        #expect(saved?.name == "Oat Milk")
        #expect(saved?.brandName == "Oatly")
        #expect(saved?.barcode == "5012345678900")
        #expect(saved?.authorId == "user-1")
        #expect(saved?.portionSize == 250)
        #expect(saved?.portionName == "glass")
    }

    // MARK: - Normalising to per-100g

    /// Figures typed off a per-serving label are scaled to per-100g before they are stored, since
    /// that is the basis every later serving is computed from. A 50g serving at 100 kcal is a
    /// 200 kcal per 100g food.
    @Test("Test Per Serving Figures Are Normalised To Per Hundred Grams")
    func testPerServingFiguresAreNormalisedToPerHundredGrams() async {
        let screen = makeScreen(option: .serving, servingWeight: 50)
        screen.presenter.energy = 100
        screen.presenter.protein = 5

        await create(screen)

        let saved = try? #require(screen.interactor.savedFoods.first)
        #expect(saved?.nutrients[.calories] == 200)
        #expect(saved?.nutrients[.protein] == 10)
    }

    /// A serving that already weighs 100g needs no adjustment.
    @Test("Test A Hundred Gram Serving Is Unchanged")
    func testAHundredGramServingIsUnchanged() async {
        let screen = makeScreen(option: .serving, servingWeight: 100)
        screen.presenter.energy = 100

        await create(screen)

        #expect(screen.interactor.savedFoods.first?.nutrients[.calories] == 100)
    }

    /// Figures already given per 100g are stored as they are.
    @Test("Test Standard Mass Figures Are Not Scaled")
    func testStandardMassFiguresAreNotScaled() async {
        let screen = makeScreen(option: .standardMass, servingWeight: 50)
        screen.presenter.energy = 100

        await create(screen)

        #expect(screen.interactor.savedFoods.first?.nutrients[.calories] == 100)
    }

    /// Without a serving weight there is nothing to scale by, so the figures are left alone
    /// rather than divided by zero.
    @Test("Test A Serving Without A Weight Is Not Scaled")
    func testAServingWithoutAWeightIsNotScaled() async {
        let screen = makeScreen(option: .serving, servingWeight: nil)
        screen.presenter.energy = 100

        await create(screen)

        #expect(screen.interactor.savedFoods.first?.nutrients[.calories] == 100)
    }

    /// A zero serving weight is the same case, and must not produce an infinite figure.
    @Test("Test A Zero Serving Weight Is Not Scaled")
    func testAZeroServingWeightIsNotScaled() async {
        let screen = makeScreen(option: .serving, servingWeight: 0)
        screen.presenter.energy = 100

        await create(screen)

        let calories = screen.interactor.savedFoods.first?.nutrients[.calories]
        #expect(calories == 100)
        #expect(calories?.isFinite == true)
    }

    // MARK: - Create and add

    /// Creating from inside a meal drops the new food straight onto the plate, at 100g — the
    /// basis its nutrients were just normalised to.
    @Test("Test Create And Add Puts The Food On The Plate")
    func testCreateAndAddPutsTheFoodOnThePlate() async {
        let screen = makeScreen(name: "Oat Milk")
        screen.presenter.energy = 250

        screen.presenter.onCreateAndAddPressed(delegate: screen.delegate)
        await TestManagers.eventually { !screen.box.items.isEmpty }

        let added = try? #require(screen.box.items.first)
        let saved = try? #require(screen.interactor.savedFoods.first)
        #expect(added?.displayName == "Oat Milk")
        #expect(added?.sourceId == saved?.id)
        #expect(added?.amount == 100)
        #expect(added?.unit == "grams")
    }

    /// Plain create does not touch the plate.
    @Test("Test Plain Create Leaves The Plate Alone")
    func testPlainCreateLeavesThePlateAlone() async {
        let screen = makeScreen()
        screen.presenter.energy = 250

        await create(screen)

        #expect(screen.box.items.isEmpty)
    }

    // MARK: - Failure

    /// A failed save is reported and nothing reaches the plate.
    @Test("Test A Failed Save Is Reported")
    func testAFailedSaveIsReported() async {
        let screen = makeScreen()
        screen.presenter.energy = 250
        screen.interactor.saveError = URLError(.notConnectedToInternet)

        screen.presenter.onCreateAndAddPressed(delegate: screen.delegate)
        await TestManagers.eventually {
            screen.interactor.trackedEventNames.contains("FoodDefinitionView_CreateFood_Fail")
        }

        #expect(screen.interactor.savedFoods.isEmpty)
        #expect(screen.box.items.isEmpty)
    }

    /// Signed out there is nobody to attribute the food to, so nothing is written and the attempt
    /// is not even logged as started.
    @Test("Test No User Means No Food Is Created")
    func testNoUserMeansNoFoodIsCreated() async {
        let screen = makeScreen()
        screen.interactor.currentUser = nil
        screen.presenter.energy = 250

        screen.presenter.onCreatePressed(delegate: screen.delegate)

        #expect(screen.interactor.savedFoods.isEmpty)
        #expect(screen.interactor.trackedEventNames.contains("FoodDefinitionView_CreateFood_Start") == false)
    }

    // MARK: - Known gaps

    /// Twenty-one of the nutrient fields this screen collects are discarded on save, because
    /// `NutrientKey` has no case to store them under.
    ///
    /// This pins the gap rather than endorsing it: the user types trans fats, omega-3 and its
    /// fractions, omega-6, starch, added sugars, alcohol, water and all eleven amino acids into
    /// the form, presses Create, and none of it is kept. Closing it means extending `NutrientKey`,
    /// not changing this screen.
    @Test("Test Nutrients With No Key Are Discarded")
    func testNutrientsWithNoKeyAreDiscarded() async {
        let screen = makeScreen()
        screen.presenter.energy = 250
        screen.presenter.transFats = 1.5
        screen.presenter.omega3 = 0.8
        screen.presenter.leucine = 2.2
        screen.presenter.alcohol = 12
        screen.presenter.starch = 30

        await create(screen)

        let saved = try? #require(screen.interactor.savedFoods.first)
        // The one nutrient with a key survives; the rest leave no trace at all. They cannot even
        // be looked up to assert their absence — there is no `NutrientKey` to look them up by.
        let storedKeys = Array(saved?.nutrients ?? NutrientMap()).map(\.key)
        #expect(storedKeys == [.calories])
        #expect(saved?.nutrients[.calories] == 250)
    }

    /// The create flow logs a start and a failure but never a success, so the success rate cannot
    /// be read from the events. `createFoodSuccess` is declared on both this presenter and
    /// `CreateFoodPresenter` and logged by neither.
    @Test("Test Success Is Not Logged")
    func testSuccessIsNotLogged() async {
        let screen = makeScreen()
        screen.presenter.energy = 250

        await create(screen)

        #expect(screen.interactor.trackedEventNames.contains("FoodDefinitionView_CreateFood_Start"))
        #expect(screen.interactor.trackedEventNames.contains("FoodDefinitionView_CreateFood_Success") == false)
    }
}
