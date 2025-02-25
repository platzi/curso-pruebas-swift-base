//
//  HomeViewUITests.swift
//  GastifyUITests
//
//  Created by Santiago Moreno on 13/02/25.
//

import XCTest

final class HomeViewUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITests")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testHomeView_ElementsExist() {
        XCTAssertTrue(app.staticTexts["AppTitle"].exists, "El título de la app debería estar presente")
        XCTAssertTrue(app.buttons["AddRecordButton"].exists, "El botón de agregar registro debería existir")

        XCTAssertTrue(app.staticTexts["IncomeCard"].exists, "El resumen de gastos debería estar presente")

        XCTAssertTrue(app.staticTexts["OutcomeCard"].exists, "El resumen de gastos debería estar presente")
    }

    func testFilterSelection_ChangesRecords() {
        let todayFilterSelected = app.buttons["Filter_Hoy_Selected"]
        XCTAssertTrue(todayFilterSelected.waitForExistence(timeout: 2.0), "El filtro 'Hoy' debería mostrarse como seleccionado después del tap")

        let weekFilterUnselected = app.buttons["Filter_Esta semana_Unselected"]
        XCTAssertTrue(weekFilterUnselected.exists, "El filtro 'Esta semana' debería existir antes de tocarlo")

        weekFilterUnselected.tap()

        let weekFilterSelected = app.buttons["Filter_Esta semana_Selected"]
        XCTAssertTrue(weekFilterSelected.waitForExistence(timeout: 2.0), "El filtro 'Esta semana' debería mostrarse como seleccionado después del tap")

        let todayFilterUnselected = app.buttons["Filter_Hoy_Unselected"]
        XCTAssertTrue(todayFilterUnselected.exists, "El filtro 'Hoy' debería estar deseleccionado porque se eligio otro filtro")
    }


    func testAddRecord_NavigatesToNewRecordView() {
        let addRecordButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(addRecordButton.exists, "El botón de agregar registro debería existir")

        addRecordButton.tap()

        let newRecordSheet = app.staticTexts["FormRecordTitle"]
        XCTAssertTrue(newRecordSheet.waitForExistence(timeout: 3.0), "El sheet de nuevo registro debería mostrarse")
    }

    func testNavigationToRecordDetail() {
        let firstRecord = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'Record_'")).firstMatch
        XCTAssertTrue(firstRecord.exists, "Debería haber al menos un registro para seleccionar")

        firstRecord.tap()

        let detailView = app.buttons["RecordDetailDeleteButton"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2.0), "Debería navegar a la vista de detalles del registro")
    }
}
