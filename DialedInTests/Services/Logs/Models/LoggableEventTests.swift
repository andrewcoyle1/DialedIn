//
//  LoggableEventTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation
import os

struct LoggableEventTests {

    // MARK: - AnyLoggableEvent Initialization Tests
    
    @Test("Test Basic Initialization")
    func testBasicInitialization() {
        let randomEventName = String.random
        let randomType = LogType.info
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            type: randomType
        )
        
        #expect(event.eventName == randomEventName)
        #expect(event.type == randomType)
        #expect(event.parameters == nil)
    }
    
    @Test("Test Initialization With Parameters")
    func testInitializationWithParameters() {
        let randomEventName = String.random
        let randomParameters: [String: Any] = [
            "key1": "value1",
            "key2": 42,
            "key3": true
        ]
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: randomParameters
        )
        
        #expect(event.eventName == randomEventName)
        #expect(event.parameters?["key1"] as? String == "value1")
        #expect(event.parameters?["key2"] as? Int == 42)
        #expect(event.parameters?["key3"] as? Bool == true)
    }
    
    @Test("Test Initialization With Default Type")
    func testInitializationWithDefaultType() {
        let randomEventName = String.random
        
        let event = AnyLoggableEvent(eventName: randomEventName)
        
        #expect(event.type == .analytic)
    }
    
    @Test("Test Initialization With All Parameters")
    func testInitializationWithAllParameters() {
        let randomEventName = String.random
        let randomParameters: [String: Any] = [
            "user_id": String.random,
            "action": "button_tap"
        ]
        let randomType = LogType.warning
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: randomParameters,
            type: randomType
        )
        
        #expect(event.eventName == randomEventName)
        #expect(event.parameters?.count == 2)
        #expect(event.type == randomType)
    }
    
    @Test("Test Initialization With Nil Parameters")
    func testInitializationWithNilParameters() {
        let randomEventName = String.random
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: nil
        )
        
        #expect(event.eventName == randomEventName)
        #expect(event.parameters == nil)
    }
    
    // MARK: - AnyLoggableEvent Type Tests
    
    @Test("Test All LogType Cases")
    func testAllLogTypeCases() {
        let randomEventName = String.random
        
        let infoEvent = AnyLoggableEvent(eventName: randomEventName, type: .info)
        let analyticEvent = AnyLoggableEvent(eventName: randomEventName, type: .analytic)
        let warningEvent = AnyLoggableEvent(eventName: randomEventName, type: .warning)
        let severeEvent = AnyLoggableEvent(eventName: randomEventName, type: .severe)
        
        #expect(infoEvent.type == .info)
        #expect(analyticEvent.type == .analytic)
        #expect(warningEvent.type == .warning)
        #expect(severeEvent.type == .severe)
    }
    
    // MARK: - AnyLoggableEvent Parameter Tests
    
    @Test("Test Parameters With Different Types")
    func testParametersWithDifferentTypes() {
        let randomEventName = String.random
        let parameters: [String: Any] = [
            "string": "test",
            "int": 100,
            "double": 3.14,
            "bool": true,
            "array": [1, 2, 3],
            "nested": ["key": "value"]
        ]
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: parameters
        )
        
        #expect(event.parameters?["string"] as? String == "test")
        #expect(event.parameters?["int"] as? Int == 100)
        #expect(event.parameters?["double"] as? Double == 3.14)
        #expect(event.parameters?["bool"] as? Bool == true)
        #expect(event.parameters?["array"] as? [Int] == [1, 2, 3])
        #expect((event.parameters?["nested"] as? [String: String])?["key"] == "value")
    }
    
    @Test("Test Empty Parameters Dictionary")
    func testEmptyParametersDictionary() {
        let randomEventName = String.random
        let emptyParameters: [String: Any] = [:]
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: emptyParameters
        )
        
        #expect(event.parameters?.isEmpty == true)
    }
    
    // MARK: - LoggableEvent Protocol Conformance Tests
    
    @Test("Test AnyLoggableEvent Conforms To LoggableEvent")
    func testAnyLoggableEventConformsToLoggableEvent() {
        let randomEventName = String.random
        let event: LoggableEvent = AnyLoggableEvent(eventName: randomEventName)
        
        #expect(event.eventName == randomEventName)
        #expect(event.type == .analytic)
    }
    
    @Test("Test Protocol Requirements")
    func testProtocolRequirements() {
        let randomEventName = String.random
        let randomParameters: [String: Any] = ["key": "value"]
        let randomType = LogType.severe
        
        let event: LoggableEvent = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: randomParameters,
            type: randomType
        )
        
        // Verify protocol properties exist and are accessible
        let eventName = event.eventName
        let parameters = event.parameters
        let type = event.type
        
        #expect(eventName == randomEventName)
        #expect(parameters?["key"] as? String == "value")
        #expect(type == randomType)
    }
    
    // MARK: - LogType Enum Tests
    
    @Test("Test LogType Emoji Property")
    func testLogTypeEmojiProperty() {
        #expect(LogType.info.emoji == "👋")
        #expect(LogType.analytic.emoji == "📈")
        #expect(LogType.warning.emoji == "⚠️")
        #expect(LogType.severe.emoji == "🚨")
    }
    
    @Test("Test LogType OSLogType Property")
    func testLogTypeOSLogTypeProperty() {
        #expect(LogType.info.OSLogType == .info)
        #expect(LogType.analytic.OSLogType == .default)
        #expect(LogType.warning.OSLogType == .error)
        #expect(LogType.severe.OSLogType == .fault)
    }
    
    // MARK: - Edge Cases
    
    @Test("Test Event With Empty Event Name")
    func testEventWithEmptyEventName() {
        let event = AnyLoggableEvent(eventName: "")
        
        #expect(event.eventName.isEmpty)
    }
    
    @Test("Test Event With Long Event Name")
    func testEventWithLongEventName() {
        let longEventName = String(repeating: "a", count: 1000)
        let event = AnyLoggableEvent(eventName: longEventName)
        
        #expect(event.eventName.count == 1000)
    }
    
    @Test("Test Event With Very Large Parameters Dictionary")
    func testEventWithVeryLargeParametersDictionary() {
        let randomEventName = String.random
        var largeParameters: [String: Any] = [:]
        
        for iteration in 0..<100 {
            largeParameters["key\(iteration)"] = "value\(iteration)"
        }
        
        let event = AnyLoggableEvent(
            eventName: randomEventName,
            parameters: largeParameters
        )
        
        #expect(event.parameters?.count == 100)
    }
    
    @Test("Test Multiple Events With Same Event Name")
    func testMultipleEventsWithSameEventName() {
        let eventName = "test_event"
        
        let event1 = AnyLoggableEvent(eventName: eventName, type: .info)
        let event2 = AnyLoggableEvent(eventName: eventName, type: .analytic)
        
        #expect(event1.eventName == event2.eventName)
        #expect(event1.type != event2.type)
    }
}
