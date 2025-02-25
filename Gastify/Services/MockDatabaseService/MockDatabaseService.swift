//
//  MockDatabaseService.swift
//  Gastify
//
//  Created by Santiago Moreno on 26/01/25.
//

import Foundation

class MockDatabaseService: DatabaseServiceProtocol {
    var fetchRecordsResult: [Record] = [
        Record(id: "1", title: "Record 1", date: Date(), type: .income, amount: 500.0),
        Record(id: "2", title: "Record 2", date: Date(), type: .outcome, amount: 250.0)
    ]
    var saveNewRecordResult: Bool = true
    var updateRecordResult: Bool = true
    var deleteRecordResult: Bool = true
    var totalsResult: (income: Double, outcome: Double) = (1000.0, 500.0)

    func fetchRecords(filter: FilterItem) async -> [Record] {
        return fetchRecordsResult
    }

    func saveNewRecord(_ record: Record) async -> Bool {
        return saveNewRecordResult
    }

    func updateRecord(_ record: Record) async -> Bool {
        return updateRecordResult
    }

    func deleteRecord(_ record: Record) async -> Bool {
        return deleteRecordResult
    }

    func getTotals() async -> (income: Double, outcome: Double) {
        return totalsResult
    }
}
