import Foundation
import SwiftUI

struct TotalAmountOfEachCompanyReport: View {
	let name: String
	let data: [TotalAmountOfEachCompanyResponse.Company]
	
	var body: some View {
		ReportBuilder.Layout(title: name) {
			ForEach(data, id: \.code) { company in
				ReportBuilder.Section {
					KeyValueView("Код авиакомпании", company.code)
					KeyValueView("Название авиакомпании", company.name)
					KeyValueView("Адрес авиакомпании", company.address)
					KeyValueView("Общая сумма от продаж билетов", "\(company.total) ₽")
				}
			}
		}
	}
}
