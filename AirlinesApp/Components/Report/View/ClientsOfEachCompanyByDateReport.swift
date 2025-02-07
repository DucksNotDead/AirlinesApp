import Foundation
import SwiftUI

struct ClientsOfEachCompanyByDateReport: View {
	let name: String
	let data: [ClientsOfEachCompanyByDateResponse.CompanyWithClients]
	
	let clientsTableHeader: [ReportBuilder.Table.HeaderRow] = [
		.init(label: "№"),
		.init(label: "ФИО")
	]
	
	var body: some View {
		ReportBuilder.Layout(title: name) {
			ForEach(data, id: \.code) { company in
				ReportBuilder.Section {
					KeyValueView("Код авиакомпании", company.code)
					KeyValueView("Название авиакомпании", company.name)
					KeyValueView("Адрес авиакомпании", company.address)
					if company.clients.isEmpty {
						Text("Клиенты отсутствуют")
					} else {
						ReportBuilder.Table("Клиенты", header: clientsTableHeader) {
							ForEach(Array(company.clients.enumerated()), id: \.element) { index, client in
								HStack {
									ReportBuilder.Table.Cell("\(String(index + 1)).")
									ReportBuilder.Table.Cell(client.fio)
								}
							}
						}
					}
				}
			}
		}
	}
}
