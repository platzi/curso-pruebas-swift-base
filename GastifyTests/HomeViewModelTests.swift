//
//  HomeViewModelTests.swift
//  GastifyTests
//
//  Created by Santiago Moreno on 13/02/25.
//

import XCTest
import Combine
@testable import Gastify

class HomeViewModelTests: XCTestCase {
    var viewModel: HomeViewModel!
    var mockDatabaseService: MockDatabaseService!
    var stubDatabaseService: StubDatabaseService!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockDatabaseService = MockDatabaseService()
        stubDatabaseService = StubDatabaseService()
    }

    override func tearDown() {
        viewModel = nil
        mockDatabaseService = nil
        stubDatabaseService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testGetTotals_UpdatesTotalIncomeAndOutcome() async {
        viewModel = HomeViewModel(mockDatabaseService)

        let expectation = XCTestExpectation(description: "Fetch totals from database")

        Task {
            viewModel.getTotals()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(viewModel.totalIncome, 1000.0, "Total income should match mock data")
        XCTAssertEqual(viewModel.totalOutcome, 500.0, "Total outcome should match mock data")
    }

    func testGetRecords_UpdatesRecordsArray() async {
        viewModel = HomeViewModel(mockDatabaseService)

        let expectation = XCTestExpectation(description: "Fetch records from database")

        Task {
            viewModel.getRecords()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(viewModel.records.count, 2, "Records count should match mock data")
    }

    func testFilterSelection_UpdatesActiveFilterAndFetchesRecords() async {
        viewModel = HomeViewModel(mockDatabaseService)
        viewModel.filterSelected(.month)

        XCTAssertEqual(viewModel.activeFilter, .month, "Active filter should be updated")

        let expectation = XCTestExpectation(description: "Fetch records for selected filter")

        Task {
            viewModel.getRecords()
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(viewModel.records.count, 2, "Records should be fetched for selected filter")
    }

    func testNavigationToDetail_AppendsToPath() {
        viewModel = HomeViewModel(stubDatabaseService)
        let record = Record(id: "1", title: "Test Record 1", date: Date(), type: .income, amount: 100.0)

        viewModel.goToDetail(record)

        XCTAssertEqual(viewModel.path.count, 1, "Navigation path should have one entry")
        XCTAssertEqual(viewModel.path.first, .recordDetail(record), "Path should contain the correct record detail route")
    }

    func testNewRecord_ShowsSheet() {
        viewModel = HomeViewModel(stubDatabaseService)

        viewModel.newRecord()

        XCTAssertEqual(viewModel.sheet, .newRecord, "Sheet should be set to newRecord")
    }
}
