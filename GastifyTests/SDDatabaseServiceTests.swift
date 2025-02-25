//
//  SDDatabaseServiceTests.swift
//  GastifyTests
//
//  Created by Santiago Moreno on 13/02/25.
//

import XCTest
@testable import Gastify

class SDDatabaseServiceTests: XCTestCase {
    var databaseService: SDDatabaseService!

    override func setUp() {
        super.setUp()
        let expectation = XCTestExpectation(description: "Initialize database service")

        Task { @MainActor in
            self.databaseService = SDDatabaseService()
            await self.clearDatabase()
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    override func tearDown() {
        databaseService = nil
        super.tearDown()
    }

    func clearDatabase() async {
        let allRecords = await databaseService.fetchRecords(filter: .today)
        for record in allRecords {
            _ = await databaseService.deleteRecord(record)
        }
    }

    func testSaveNewRecord_ShouldPersistRecord() async {
        let record = Record(id: UUID().uuidString, title: "Test Record", date: Date(), type: .income, amount: 100.0)

        let success = await databaseService.saveNewRecord(record)
        XCTAssertTrue(success, "Record should be saved successfully")

        let fetchedRecords = await databaseService.fetchRecords(filter: .today)
        XCTAssertTrue(fetchedRecords.contains { $0.id == record.id }, "Saved record should be retrievable")
    }

    func testFetchRecords_ShouldReturnStoredRecords() async {
        let record = Record(id: UUID().uuidString, title: "Fetch Test", date: Date(), type: .outcome, amount: 50.0)
        _ = await databaseService.saveNewRecord(record)

        let fetchedRecords = await databaseService.fetchRecords(filter: .today)
        XCTAssertGreaterThan(fetchedRecords.count, 0, "There should be at least one record fetched")
    }

    func testUpdateRecord_ShouldModifyExistingRecord() async {
        let record = Record(id: UUID().uuidString, title: "Original Name", date: Date(), type: .income, amount: 75.0)
        _ = await databaseService.saveNewRecord(record)

        let updatedRecord = Record(id: record.id, title: "Updated Name", date: record.date, type: .income, amount: 150.0)
        let success = await databaseService.updateRecord(updatedRecord)
        XCTAssertTrue(success, "Record should be updated successfully")

        let fetchedRecords = await databaseService.fetchRecords(filter: .today)
        XCTAssertTrue(fetchedRecords.contains { $0.id == updatedRecord.id && $0.title == "Updated Name" }, "Updated record should reflect changes")
    }

    func testDeleteRecord_ShouldRemoveRecordFromDatabase() async {
        let record = Record(id: UUID().uuidString, title: "To Be Deleted", date: Date(), type: .outcome, amount: 25.0)
        _ = await databaseService.saveNewRecord(record)

        let deleteSuccess = await databaseService.deleteRecord(record)
        XCTAssertTrue(deleteSuccess, "Record should be deleted successfully")

        let fetchedRecords = await databaseService.fetchRecords(filter: .today)
        XCTAssertFalse(fetchedRecords.contains { $0.id == record.id }, "Deleted record should not be retrievable")
    }

    func testGetTotals_ShouldReturnCorrectSum() async {
        let incomeRecord = Record(id: UUID().uuidString, title: "Income", date: Date(), type: .income, amount: 100.0)
        let outcomeRecord = Record(id: UUID().uuidString, title: "Outcome", date: Date(), type: .outcome, amount: 50.0)

        _ = await databaseService.saveNewRecord(incomeRecord)
        _ = await databaseService.saveNewRecord(outcomeRecord)

        let totals = await databaseService.getTotals()
        XCTAssertEqual(totals.income, 100.0, "Total income should match saved records")
        XCTAssertEqual(totals.outcome, 50.0, "Total outcome should match saved records")
    }
}
