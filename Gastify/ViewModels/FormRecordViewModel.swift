//
//  FormRecordViewModel.swift
//  Gastify
//
//  Created by Santiago Moreno on 5/01/25.
//

import Foundation

class FormRecordViewModel: ObservableObject {

    @Published var loading = false
    @Published var selectedType: RcordType = .income
    @Published var title: String = ""
    @Published var amount: String = ""

    let types: [RcordType] = [.income, .outcome]
    let record: Record?
    let databaseService: DatabaseServiceProtocol
    private let maxDigits = 10
    private let maxDecimals = 2

    init(_ databaseService: DatabaseServiceProtocol, record: Record? = nil) {
        self.databaseService = databaseService
        self.record = record
        self.setUpInfoIfNeeded()
    }

    var isButtonDisabled: Bool {
        if title.isEmpty || amount.isEmpty {
            return true
        } else if let amount = Double(self.amount) {
            return amount <= 0
        }
        return true
    }

    var buttonTitle: String {
        self.record == nil ? "Guardar nuevo registro" : "Actualizar registro"
    }

    func validateAndFormatAmount(_ newValue: String) {
        var filtered = newValue.filter { "0123456789,.".contains($0) }

        filtered = filtered.replacingOccurrences(of: ",", with: ".")

        if filtered.filter({ $0 == "." }).count > 1 {
            let components = filtered.components(separatedBy: ".")
            filtered = components[0] + "." + components[1...].joined()
        }

        if filtered.filter({ $0 != "." }).count > maxDigits {
            return
        }

        if let decimalIndex = filtered.firstIndex(of: ".") {
            let decimals = filtered[filtered.index(after: decimalIndex)...]
            if decimals.count > maxDecimals {
                return
            }
        }
        amount = filtered
    }

    func typeSelected(_ type: RcordType) {
        if self.record == nil {
            self.selectedType = type
        }
    }

    func isSelectedType(_ type: RcordType) -> Bool {
        self.selectedType == type
    }

    func saveNewRecord(completion: @escaping (Record?) -> Void) {
        guard let amountDouble = Double(self.amount) else { return }
        self.loading = true
        if let record {
            let recordToUpdate = Record(id: record.id,
                                        title: self.title,
                                        date: record.date,
                                        type: record.type,
                                        amount: amountDouble)
            Task {
                let saved = await self.databaseService.updateRecord(recordToUpdate)
                if saved {
                    await MainActor.run {
                        self.loading = false
                        completion(recordToUpdate)
                    }
                } else {
                    // TODO: Mostrar un error
                    print("Error al guardar")
                }
            }
        } else {
            let recordToSave = Record(id: UUID().uuidString,
                                      title: self.title,
                                      date: Date(),
                                      type: self.selectedType,
                                      amount: amountDouble)
            Task {
                let saved = await self.databaseService.saveNewRecord(recordToSave)
                if saved {
                    await MainActor.run {
                        self.loading = false
                        completion(nil)
                    }
                } else {
                    // TODO: Mostrar un error
                    print("Error al guardar")
                }
            }
        }
    }

    private func setUpInfoIfNeeded() {
        if let record {
            selectedType = record.type
            title = record.title
            amount = String(record.amount)
        }
    }
}
