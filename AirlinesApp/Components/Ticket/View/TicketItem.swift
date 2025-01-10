import SwiftUI

struct TicketItem: View {
	let ticket: Ticket

	init(_ ticket: Ticket) {
		self.ticket = ticket
	}

	var body: some View {
		VStack(spacing: 8) {
			HStack {
				Text(ticket.company.code)
					.font(.system(size: 18, weight: .bold))
					.foregroundStyle(.orange)
				Spacer()
				Text(ticket.coupons.first?.route ?? "")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			HStack {
				if let rate = ticket.coupons.first?.rate {
					Text("\(rate) ₽")
						
				}
				Spacer()
				Text(ticket.type.localized)
			}
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.white)
		.clipShape(.rect(cornerRadius: 14))
		.shadow(radius: 10)
		.padding(.horizontal)
	}
}

#Preview {
	TicketItem(
		.init(
			id: 1, buy_date: nil,
			type: .init(id: 2, code: "Business", localized: "Бизнес-класс"),
			status: .init(id: 1, code: "for_sale", localized: "На продаже"),
			company: .init(
				code: "SVO", name: "Шереметьево", address: "Шереметьевское ш."),
			coupons: [
				.init(id: 1, route: "Самара - Новосибирск", rate: 44000)
			], cashier: .init(id: 1, fio: "Иванов Иван Васильевич", user_id: 2),
			cash_desk: .init(id: 1, address: "ул. Хлебная, дом 5"), client: .init())
	)
}
