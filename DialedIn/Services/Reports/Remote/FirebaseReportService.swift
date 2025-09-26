//
//  FirebaseReportService.swift
//  BrainBolt
//
//  Created by Assistant on 14/08/2025.
//

import Foundation
import FirebaseFirestore

struct FirebaseReportService: RemoteReportService {
    var collection: CollectionReference { Firestore.firestore().collection("reports") }
    
    func submit(report: ReportSubmission) async throws {
        try await collection.document(report.reportId).setData([
            "report_id": report.reportId,
            "reporter_user_id": report.reporterUserId,
            "reported_user_id": report.reportedUserId as Any,
            "content_type": report.contentType.rawValue,
            "content_id": report.contentId,
            "reason": report.reason.rawValue,
            "notes": report.notes as Any,
            "created_at": Timestamp(date: report.createdAt)
        ])
    }
}
