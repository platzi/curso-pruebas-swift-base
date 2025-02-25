//
//  HomeViewModelIntegrationTests.swift
//  GastifyTests
//
//  Created by Santiago Moreno on 13/02/25.
//

import XCTest
@testable import Gastify

class HomeViewModelIntegrationTests: XCTestCase {
    var viewModel: HomeViewModel!
    var databaseService: SDDatabaseService!

    override func setUp() {
        super.setUp()

        let expectation = XCTestExpectation(description: "Initialize database service")

        Task { @MainActor in
            self.databaseService = SDDatabaseService()
            await self.clearDatabase()
            self.viewModel = HomeViewModel(self.databaseService)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }


    override func tearDown() {
        viewModel = nil
        databaseService = nil
        super.tearDown()
    }

    func clearDatabase() async {
        let allRecords = await databaseService.fetchRecords(filter: .today)
        for record in allRecords {
            _ = await databaseService.deleteRecord(record)
        }
    }

    func testGetTotals_UpdatesTotalIncomeAndOutcome() async {
        let expectation = XCTestExpectation(description: "Fetch totals from database")

        Task {
            viewModel.getTotals()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertGreaterThanOrEqual(viewModel.totalIncome, 0, "Total income should be a valid amount")
        XCTAssertGreaterThanOrEqual(viewModel.totalOutcome, 0, "Total outcome should be a valid amount")
    }

    func testGetRecords_UpdatesRecordsArray() async {
        let expectation = XCTestExpectation(description: "Fetch records from database")

        Task {
            viewModel.getRecords()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2.0)

        XCTAssertNotNil(viewModel.records, "Records should not be nil")
    }
}
