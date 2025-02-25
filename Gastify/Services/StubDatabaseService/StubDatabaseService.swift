//
//  StubDatabaseService.swift
//  Gastify
//
//  Created by Santiago Moreno on 26/01/25.
//

import Foundation

class StubDatabaseService: DatabaseServiceProtocol {
    func fetchRecords(filter: FilterItem) async -> [Record] {
        return []
    }

    func saveNewRecord(_ record: Record) async -> Bool {
        return false
    }

    func updateRecord(_ record: Record) async -> Bool {
        return false
    }

    func deleteRecord(_ record: Record) async -> Bool {
        return false
    }

    func getTotals() async -> (income: Double, outcome: Double) {
        return (0.0, 0.0)
    }
}
