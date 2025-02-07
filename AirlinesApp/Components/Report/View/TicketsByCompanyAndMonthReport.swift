import SwiftUI

struct TicketsByCompanyAndMonthReport: View {
	let name: String
	let data: [TicketsByCompanyAndMonthResponse.Ticket]

	let couponsTableHeader: [String] = [
		"№", "ID", "Откуда\nКуда", "Стоимость",
	]

	@ViewBuilder
	func cell(
		_ value: String,
		header: Bool = false,
		width: CGFloat? = nil
	) -> some View {
		Text(value)
			.font(.system(size: 13, weight: header ? .medium : .light))
			.frame(maxWidth: width ?? .infinity, alignment: .leading)
			.padding(.horizontal, 4)
	}

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
					VStack(spacing: ReportBuilder.innerPadding) {
						Text("Купоны")
							.font(.subheadline)
						HStack {
							ForEach(couponsTableHeader, id: \.self) { column in
								cell(column, header: true, width: (column == "№" || column == "ID") ? 30 : nil)
							}
						}
						ForEach(item.coupons, id: \.id) { coupon in
							HStack {
								cell(String(coupon.index), width: 30)
								cell(String(coupon.id ?? 0), width: 30)
								cell("\(coupon.from)\n\(coupon.to)")
								cell(String(coupon.rate) + "₽")
							}
						}
					}
					.padding(.top, ReportBuilder.padding)
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
				client: .init(id: 1, passport: 1234567890, fio: "Иванов Иван Васильевич"),
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
				client: .init(id: 1, passport: 1234567890, fio: "Иванов Иван Васильевич"),
				coupons: [
					.init(
						id: 1, index: 1, from: "Новосибирск", to: "Москва",
						rate: 44000
					),
					.init(
						id: 2, index: 2, from: "Москва", to: "Харьков",
						rate: 27500),
				]
			)
		])
}
