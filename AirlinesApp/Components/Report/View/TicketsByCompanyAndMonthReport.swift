import SwiftUI

struct TicketsByCompanyAndMonthReport: View {
	let name: String
	let data: [TicketsByCompanyAndMonthResponse.Ticket]

	let couponsTableHeader: [ReportBuilder.Table.HeaderRow] = [
		.init(label: "№", width: 30),
		.init(label: "ID", width: 30),
		.init(label: "Откуда\nКуда"),
		.init(label: "Стоимость")
	]

	var body: some View {
		ReportBuilder.Layout(title: name) {
			ForEach(data, id: \.id) { item in
				ReportBuilder.Section {
					KeyValueView("ID", String(item.id))
					KeyValueView("Дата покупки", item.buy_date)
					KeyValueView("Тип билета", item.type.localized)
					KeyValueView("Кассир", item.cashier.fio)
					KeyValueView("Касса", item.cash_desk.address)
					KeyValueView("ФИО клиента", item.client.fio!)

					if item.coupons.isEmpty {
						Text("Купоны отсутствуют")
					} else {
						ReportBuilder.Table("Купоны", header: couponsTableHeader) {
							ForEach(item.coupons, id: \.id) { coupon in
								HStack {
									ReportBuilder.Table.Cell(
										String(coupon.index), width: 30)
									ReportBuilder.Table.Cell(
										String(coupon.id ?? 0), width: 30)
									ReportBuilder.Table.Cell(
										"\(coupon.from)\n\(coupon.to)")
									ReportBuilder.Table.Cell(
										String(coupon.rate) + "₽")
								}
							}
						}
					}
				}
			}
		}
	}
}

#Preview {
	TicketsByCompanyAndMonthReport(
		name: "Билеты, проданные за 01.2025, Аэрофлот",
		data: [
			.init(
				id: 1,
				buy_date: "01.01.2025",
				type: .init(id: 2, code: "Business", localized: "Бизнес-класс"),
				cashier: .init(
					id: 1, fio: "Иванов Иван Васильевич", user_id: 2),
				cash_desk: .init(id: 1, address: "ул. Хлебная, дом 5"),
				client: .init(
					id: 1, passport: 1_234_567_890,
					fio: "Иванов Иван Васильевич"),
				coupons: [
					.init(
						id: 1, index: 1, from: "Новосибирск", to: "Москва",
						rate: 44000
					),
					.init(
						id: 2, index: 2, from: "Москва", to: "Харьков",
						rate: 27500),
				]
			),
			.init(
				id: 2,
				buy_date: "01.01.2025",
				type: .init(id: 2, code: "Business", localized: "Бизнес-класс"),
				cashier: .init(
					id: 1, fio: "Иванов Иван Васильевич", user_id: 2),
				cash_desk: .init(id: 1, address: "ул. Хлебная, дом 5"),
				client: .init(
					id: 1, passport: 1_234_567_890,
					fio: "Иванов Иван Васильевич"),
				coupons: [
					.init(
						id: 1, index: 1, from: "Новосибирск", to: "Москва",
						rate: 44000
					),
					.init(
						id: 2, index: 2, from: "Москва", to: "Харьков",
						rate: 27500),
				]
			),
		])
}
