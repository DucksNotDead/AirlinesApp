import SwiftUI

struct TicketItem: View {
	struct SubHeadlineModifier: ViewModifier {
		func body(content: Content) -> some View {
			content
				.font(.subheadline)
				.foregroundStyle(.secondary)
		}
	}

	let ticket: Ticket
	let isOpen: Bool
	let userRole: UserRole
	let onOpen: VoidClosure
	let onClose: VoidClosure
	let onUpdate: VoidClosure
	let onBuy: VoidClosure
	let onConfirm: VoidClosure

	let routeSeparator: String = " – "
	let diffRoutesSeparator: String = ", "
	let editRoles: [UserRole] = [.admin, .employee]
	let confirmRoles: [UserRole] = [.cashier]

	@EnvironmentObject var ticketsModel: TicketsViewModel
	@State var isConfirmDeletePresented: Bool = false
	@State var isConfirmConfirmPresented: Bool = false
	@State var isConfirmDenyPresented: Bool = false

	var openable: Bool { ticket.coupons.count > 1 }
	var canEdit: Bool { editRoles.contains(userRole) }
	var canConfirm: Bool { confirmRoles.contains(userRole) }
	var buyButtonDisabled: Bool { ticket.status.id != 1 || userRole != .client }

	init(
		_ ticket: Ticket,
		isOpen: Bool,
		userRole: UserRole,
		onOpen: @escaping VoidClosure,
		onClose: @escaping VoidClosure,
		onUpdate: @escaping VoidClosure,
		onBuy: @escaping VoidClosure,
		onConfirm: @escaping VoidClosure
	) {
		self.isOpen = isOpen
		self.ticket = ticket
		self.userRole = userRole
		self.onOpen = onOpen
		self.onClose = onClose
		self.onUpdate = onUpdate
		self.onBuy = onBuy
		self.onConfirm = onConfirm
	}

	var sumRoute: String {
		var routes: [[String]] = []

		for coupon in ticket.coupons.sorted(by: { $0.index < $1.index }) {
			if let lastRoutesIndex = routes.lastIndex(where: {
				$0.last == coupon.from
			}) {
				routes[lastRoutesIndex].append(coupon.to)
			} else {
				routes.append([coupon.from, coupon.to])
			}
		}

		return ticket.coupons.reduce("") { partialResult, coupon in
			if let lastRoute =
				partialResult
				.components(separatedBy: routeSeparator)
				.last?
				.trimmingCharacters(in: .whitespaces)
				.trimmingCharacters(
					in: .init(charactersIn: diffRoutesSeparator)),
				lastRoute == coupon.from
			{
				return partialResult + routeSeparator + coupon.to
			} else {
				let route = coupon.from + routeSeparator + coupon.to
				return partialResult
					+ (partialResult.isEmpty ? "" : diffRoutesSeparator) + route
			}
		}
	}

	var sumPrice: Int {
		ticket.coupons.reduce(0) { partialResult, coupon in
			partialResult + coupon.rate
		}
	}

	@ViewBuilder
	func priceItem(_ price: Int) -> some View {
		HStack(spacing: 4) {
			Text(price, format: .number)
			Text("₽")
		}
	}

	@ViewBuilder
	func routeItem(_ coupon: Coupon) -> some View {
		Text(coupon.from + routeSeparator + coupon.to)
			.modifier(SubHeadlineModifier())
	}

	@ViewBuilder
	var ticketStatus: some View {
		Text(ticket.status.localized)
			.modifier(SubHeadlineModifier())
	}

	@ViewBuilder
	var editPanel: some View {
		HStack(spacing: 16) {
			switch ticket.status.id {
			case 1:
				ticketStatus
				Spacer()
				if canEdit {
					Button("изменить") {
						onUpdate()
					}
					Button("удалить", role: .destructive) {
						isConfirmDeletePresented = true
					}
				}
			case 2:
				if canConfirm {
					HStack {
						VStack(alignment: .leading) {
							ticketStatus
								.padding(.bottom, 8)
							if let passport = ticket.client.passport, let fio = ticket.client.fio {
								KeyValueView("ФИО", fio)
								KeyValueView("Пасспорт", String(passport))
							}
						}
						Spacer()
						VStack(alignment: .trailing) {
							Button("подтвердить") {
								isConfirmConfirmPresented = true
							}
							Button("отклонить", role: .destructive) {
								isConfirmDenyPresented = true
							}
						}
					}
				} else {
					ticketStatus
					Spacer()
				}
			case 3:
					Text("Куплено: \(ticket.client.fio ?? "")")
						.modifier(SubHeadlineModifier())
				Spacer()
			default:
				Text("Неизвестный статус")
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 8)
		.background(Color(UIColor.secondarySystemBackground))
		.clipShape(.rect(cornerRadius: 14))
	}

	var body: some View {
		VStack {
			if userRole != .client {
				editPanel
			}
			VStack(spacing: 16) {
				HStack(alignment: .firstTextBaseline) {
					Text(ticket.company.code)
						.font(.title3)
						.foregroundStyle(.orange)

					Text(ticket.company.name)
						.font(.headline)

					Spacer()

					Text(ticket.type.localized)
						.foregroundStyle(.secondary)

				}
				if openable {
					VStack {
						if !isOpen {
							HStack {
								Spacer()
								Button(sumRoute, systemImage: "chevron.down") {
									onOpen()
								}
								.modifier(SubHeadlineModifier())
							}
						} else {
							Button(action: { onClose() }) {
								VStack {
									HStack {
										Spacer()
										Label(
											"показать меньше",
											systemImage: "chevron.up"
										)
										.modifier(SubHeadlineModifier())
									}
									ForEach(ticket.coupons, id: \.id) {
										coupon in
										HStack {
											priceItem(coupon.rate)
											Spacer()
											routeItem(coupon)
										}
									}
								}
								.padding(.vertical, 4)
							}
							.buttonStyle(.plain)
						}
					}
				} else if let coupon = ticket.coupons.first {
					HStack {
						Spacer()
						routeItem(coupon)
					}
				}
				HStack {
					priceItem(sumPrice)
					Spacer()
					PrimaryButton("купить", disabled: buyButtonDisabled) {
						onBuy()
					}
				}
			}
			.padding(8)
			.padding(.top, 0)
		}
		.frame(maxWidth: .infinity)
		.background(Color.white)
		.clipShape(.rect(cornerRadius: 14))
		.shadow(radius: 4)
		.padding(.horizontal)
		.animation(.easeInOut(duration: 0.2), value: isOpen)
		.modifier(
			ConfirmDialogModifier(
				$isConfirmDeletePresented,
				confirmText: "Подтвердить удаление",
				onConfirm: {
					ticketsModel.delete(ticket.id)
				})
		)
		.modifier(
			ConfirmDialogModifier(
				$isConfirmConfirmPresented,
				onConfirm: onConfirm)
		)
		.modifier(
			ConfirmDialogModifier(
				$isConfirmDenyPresented,
				confirmText: "Отклонить",
				onConfirm: {
					ticketsModel.deny(ticket.id)
				})
		)
	}
}

#Preview {
	@Previewable @State var isOpen: Bool = false

	TicketItem(
		.init(
			id: 1, buy_date: nil,
			type: .init(id: 2, code: "Business", localized: "Бизнес-класс"),
			status: .init(id: 1, code: "for_sale", localized: "На продаже"),
			company: .init(
				code: "SVO", name: "Шереметьево", address: "Шереметьевское ш."),
			coupons: [
				.init(
					id: 1, index: 0, from: "Новосибирск", to: "Москва",
					rate: 44000
				),
				.init(
					id: 2, index: 1, from: "Москва", to: "Харьков", rate: 27500),
			], cashier: .init(id: 1, fio: "Иванов Иван Васильевич", user_id: 2),
			cash_desk: .init(id: 1, address: "ул. Хлебная, дом 5"),
			client: .init()),
		isOpen: isOpen,
		userRole: .admin,
		onOpen: { isOpen = true },
		onClose: { isOpen = false },
		onUpdate: {},
		onBuy: {},
		onConfirm: {}
	)
}
