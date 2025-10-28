//
//  Concurrency+EXT.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/09/2025.
//

import Foundation

// These Objective-C bridged collection types are commonly passed across async boundaries
// when calling SDKs like Firebase. We mark them as @unchecked Sendable since their
// thread-safety is managed by the underlying SDK usage.
extension NSDictionary: @unchecked @retroactive Sendable {}
extension NSArray: @unchecked @retroactive Sendable {}
