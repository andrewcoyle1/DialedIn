//
//  RemoteReportService.swift
//  BrainBolt
//
//  Created by Assistant on 14/08/2025.
//

import Foundation

protocol RemoteReportService: Sendable {
    func submit(report: ReportSubmission) async throws
}
