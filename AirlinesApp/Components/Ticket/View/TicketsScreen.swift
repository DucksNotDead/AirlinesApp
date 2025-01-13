import SwiftUI

struct TicketsScreen: View {
	struct QueryFieldModifier: ViewModifier {
		func body(content: Content) -> some View {
			content
				.padding(.horizontal, 8)
				.padding(.vertical, 4)
				.background(Color(UIColor.systemGray6))
				.clipShape(.rect(cornerRadius: 10))
		}
	}

	enum QueryField {
		case from
		case to
	}

	let userRole: UserRole
	let isLoggedIn: Bool

	let editRoles: [UserRole] = [.admin, .employee]

	@StateObject var ticketsModel: TicketsViewModel = .init()
	@State var isUpdateFormPresented: Bool = false
	@State var isBuyFormPresented: Bool = false
	@State var ticketToUpdate: Ticket?
	@State var ticketToBuy: Ticket?
	@State var selectedStatus = "none"
	@State var fromQuery = ""
	@State var toQuery = ""
	@FocusState var focusedQueryField: QueryField?

	var canEdit: Bool { editRoles.contains(userRole) }

	func refreshAll() {
		selectedStatus = "none"

		ticketsModel.getStatuses()
		ticketsModel.fetch(statusCode: isLoggedIn ? "for_sale" : nil)
	}

	var filteredTickets: [Ticket] {
		return ticketsModel.tickets.filter { ticket in
			guard
				let firstCoupon = ticket.coupons.first,
				let lastCoupon = ticket.coupons.last
			else { return false }

			return
				firstCoupon.from.lowercased().contains(
					fromQuery.lowercased().trimmingCharacters(in: .whitespaces))
				&& lastCoupon.to.lowercased().contains(
					toQuery.lowercased().trimmingCharacters(in: .whitespaces))
		}
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				HStack {
					TextField("Откуда", text: $fromQuery)
						.modifier(QueryFieldModifier())
						.submitLabel(.next)
						.focused($focusedQueryField, equals: .from)
						.onSubmit {
							focusedQueryField = .to
						}

					Text("–")

					TextField("Куда", text: $toQuery)
						.modifier(QueryFieldModifier())
						.submitLabel(.done)
						.focused($focusedQueryField, equals: .to)
						.onSubmit {
							focusedQueryField = nil
						}
				}
				.padding(.horizontal)
				VStack {
					if filteredTickets.isEmpty {
						Spacer()
						Text("Тут пусто")
					} else {
						ForEach(filteredTickets, id: \.id) { ticket in
							TicketItem(
								ticket,
								userRole: userRole,
								onUpdate: { isUpdateFormPresented = true },
								onBuy: { isBuyFormPresented = true }
							)
							.environmentObject(ticketsModel)
						}
					}
				}
			}
			.navigationTitle("билеты")
			.onAppear { refreshAll() }
			.toolbar {
				if isLoggedIn {
					Picker(
						selection: $selectedStatus,
						label: Image(
							systemName: "line.3.horizontal.decrease.circle")
					) {
						Text("Все").tag("none")
						ForEach(ticketsModel.statuses, id: \.id) { status in
							Text(status.localized).tag(status.code)
						}
					}
					.pickerStyle(.menu)
				}

				if canEdit {
					Button("Добавить", systemImage: "plus") {
						isUpdateFormPresented = true
					}
				}
			}
			.refreshable { refreshAll() }
		}
	}
}
