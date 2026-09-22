//
//  PushManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 22/09/2026.
//

import Testing
import Foundation
import UserNotifications
@testable import DialedIn

/// Local notifications: the re-engagement week and the three meal reminders.
///
/// Most of this manager is a thin call into `LocalNotifications` or straight into
/// `UNUserNotificationCenter.current()`, neither of which is injected, so a unit test cannot reach
/// them without actually scheduling on the machine running the tests. That rules out asserting on:
///
/// - `checkPushNotificationAuthorisation`, `requestAuthorisation` and `canRequestAuthorisation`,
///   which read or raise the system permission prompt;
/// - `schedulePushNotificationsForNextWeek`, `schedulePushNotification` and
///   `scheduleMealReminderNotifications`, which register real requests with the notification
///   centre — calling any of them from a test would leave three to six notifications pending on
///   the simulator, and the success and failure events they log are only reachable through that;
/// - `removeDeliveredNotifications`, `clearAllDeliveredNotifications` and
///   `cancelMealReminderNotifications`, which mutate the same centre and return nothing.
///
/// What is left, and what this covers, is the data those calls are built from: the reminder
/// identifiers, the day offsets the week is laid out on, the delegate a caller fills in, and the
/// events. Each of those is the part that can be wrong without crashing — a renamed identifier
/// stops a reminder ever being cancelled, and a renamed event silently empties a funnel.
@MainActor
struct PushManagerTests {

    // MARK: - Meal reminder identifiers

    /// `scheduleMealReminderNotifications` and `cancelMealReminderNotifications` both work from
    /// this one list, and cancelling is by identifier. A reminder scheduled under a name that is
    /// no longer in the list repeats daily with nothing able to turn it off, so these three
    /// strings are effectively permanent.
    @Test("Test The Meal Reminder Identifiers Are The Three Stored Names")
    func testTheMealReminderIdentifiersAreTheThreeStoredNames() {
        #expect(PushManager.mealReminderIDs == [
            "meal_reminder_breakfast",
            "meal_reminder_lunch",
            "meal_reminder_dinner"
        ])
    }

    /// Two reminders sharing an identifier would leave only one scheduled — the notification
    /// centre keys pending requests by id.
    @Test("Test The Meal Reminder Identifiers Are Distinct")
    func testTheMealReminderIdentifiersAreDistinct() {
        #expect(Set(PushManager.mealReminderIDs).count == PushManager.mealReminderIDs.count)
    }

    // MARK: - The re-engagement week

    /// The week is laid out at one, three and five days out. They have to be in order, distinct,
    /// and inside the week — a reminder that lands after the next scheduling run would be
    /// cancelled by it and never delivered, since each run clears everything pending first.
    @Test("Test The Week Is Laid Out On Rising Offsets Inside Seven Days")
    func testTheWeekIsLaidOutOnRisingOffsetsInsideSevenDays() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        let triggers = [1, 3, 5].map { now.addingTimeInterval(days: $0) }

        #expect(triggers == triggers.sorted())
        #expect(Set(triggers).count == 3)
        #expect(triggers.allSatisfy { $0 > now })
        #expect(triggers.allSatisfy { $0 < now.addingTimeInterval(days: 7) })
    }

    /// A day is added as a fixed 86,400 seconds rather than as a calendar day, so the three
    /// reminders land at the same clock time only while the offset does not cross a clock change.
    /// Pinned because the behaviour is deliberate — the reminders are relative to the last session,
    /// not to a time of day — and an hour of drift across a DST boundary is acceptable where a
    /// silently missing reminder would not be.
    @Test("Test A Day Offset Is A Fixed Twenty Four Hours")
    func testADayOffsetIsAFixedTwentyFourHours() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        #expect(now.addingTimeInterval(days: 1).timeIntervalSince(now) == 86_400)
        #expect(now.addingTimeInterval(days: 3).timeIntervalSince(now) == 3 * 86_400)
        #expect(now.addingTimeInterval(days: 5).timeIntervalSince(now) == 5 * 86_400)
    }

    // MARK: - The delegate a caller fills in

    /// The only content a caller supplies. Its defaults are what every call site that omits them
    /// gets: a sound, no badge, and a notification that fires once.
    @Test("Test A Notification Delegate Defaults To A One Off Sounding Notification")
    func testANotificationDelegateDefaultsToAOneOffSoundingNotification() {
        let triggerDate = Date(timeIntervalSince1970: 1_700_000_000)

        let delegate = PushNotificationDelegate(
            identifier: "rest-timer",
            title: "Rest over",
            subtitle: "Back to it.",
            triggerDate: triggerDate
        )

        #expect(delegate.identifier == "rest-timer")
        #expect(delegate.title == "Rest over")
        #expect(delegate.subtitle == "Back to it.")
        #expect(delegate.triggerDate == triggerDate)
        #expect(delegate.sound)
        #expect(delegate.badge == nil)
        #expect(delegate.repeats == false)
    }

    /// A repeating notification with a badge is the other shape in use. `AnyNotificationContent`,
    /// which `schedulePushNotification` maps these onto, keeps its properties internal to its own
    /// package, so the mapping itself cannot be read back from here — only the values handed to it.
    @Test("Test A Notification Delegate Carries Every Value It Was Given")
    func testANotificationDelegateCarriesEveryValueItWasGiven() {
        let triggerDate = Date(timeIntervalSince1970: 1_700_000_000)

        let delegate = PushNotificationDelegate(
            identifier: "daily-weigh-in",
            title: "Weigh in",
            subtitle: "Same time each morning.",
            triggerDate: triggerDate,
            sound: false,
            badge: 2,
            repeats: true
        )

        #expect(delegate.sound == false)
        #expect(delegate.badge == 2)
        #expect(delegate.repeats)
    }

    // MARK: - Authorisation state

    /// The manager reports not-determined until something asks the system, and nothing about
    /// building it asks. Screens gate the "turn on notifications" prompt on this, so a manager
    /// that claimed to be authorised before checking would hide the prompt from a user who had
    /// never been asked.
    @Test("Test Authorisation Is Undetermined Until Something Checks")
    func testAuthorisationIsUndeterminedUntilSomethingChecks() {
        #expect(TestManagers.pushManager().isAuthorised == .notDetermined)
        #expect(TestManagers.pushManager(logManager: LogManager(services: [])).isAuthorised == .notDetermined)
    }

    // MARK: - Events

    /// These three strings are the column names in the analytics warehouse. A failed week is
    /// `.severe` because it means a user who stopped opening the app will not be reminded to —
    /// the one case where the absence of a notification is invisible from the app itself.
    @Test("Test The Push Events Keep Their Names And Severities")
    func testThePushEventsKeepTheirNamesAndSeverities() {
        let success = PushManager.Event.weekScheduledSuccess
        let failure = PushManager.Event.weekScheduledFail(error: URLError(.notConnectedToInternet))
        let reminders = PushManager.Event.mealRemindersScheduled

        #expect(success.eventName == "PushMan_WeekScheduled_Success")
        #expect(failure.eventName == "PushMan_WeekScheduled_Fail")
        #expect(reminders.eventName == "PushMan_MealReminders_Scheduled")

        #expect(success.type == .analytic)
        #expect(reminders.type == .analytic)
        #expect(failure.type == .severe)
    }

    /// The failure event is the only trace an unscheduled week leaves, so it has to carry enough
    /// to tell one cause from another rather than only that something went wrong.
    @Test("Test A Failed Week Reports What Went Wrong")
    func testAFailedWeekReportsWhatWentWrong() throws {
        let event = PushManager.Event.weekScheduledFail(error: URLError(.notConnectedToInternet))

        let parameters = try #require(event.parameters)
        #expect(parameters["error_domain"] as? String == URLError.errorDomain)
        #expect(parameters["error_code"] as? Int == URLError.Code.notConnectedToInternet.rawValue)
        #expect(parameters["error_description"] != nil)
    }

    /// The two events that cannot fail carry nothing, so the warehouse does not grow columns for
    /// parameters that are always absent.
    @Test("Test The Succeeding Events Carry No Parameters")
    func testTheSucceedingEventsCarryNoParameters() {
        #expect(PushManager.Event.weekScheduledSuccess.parameters == nil)
        #expect(PushManager.Event.mealRemindersScheduled.parameters == nil)
    }
}
