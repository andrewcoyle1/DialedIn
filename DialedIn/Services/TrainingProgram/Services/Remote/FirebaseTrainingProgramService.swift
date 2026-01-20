//
//  FirebaseTrainingProgramSercice.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/01/2026.
//

import FirebaseFirestore

struct FirebaseTrainingProgramService: RemoteTrainingProgramService {
    var collection: CollectionReference {
        Firestore.firestore().collection("training_programs")
    }
}
