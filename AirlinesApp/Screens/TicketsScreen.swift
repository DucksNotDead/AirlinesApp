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

	enum BuyTicketField {
		case email
		case passport
		case fio
	}

	enum FormModeSetter {
		case create
		case update(Ticket)
		case buy(Ticket)
		case buyConfirm(Ticket)
	}

	enum FormMode {
		case create
		case update
		case buy
		case buyConfirm
	}

	let userRole: UserRole
	let isLoggedIn: Bool

	let editRoles: [UserRole] = [.admin, .employee]

	@StateObject var ticketsModel: TicketsViewModel = .init()
	@StateObject var cashDesksModel: CashDesksViewModel = .init()
	@StateObject var formService = FormService(
		TicketCreateUpdateDto(company_code: "", type_id: 1, coupons: []))
	@StateObject var buyTicketFormSevice = FormService(
		TicketBuyCreditsDto(email: "", passport: "", fio: ""))
	@StateObject var buyConfirmTicketFormService = FormService(
		TicketBuyConfirmDto(cash_desk_id: 0))
	@State var openedTicketId: Int? = nil
	@State var isFormPresented: Bool = false
	@State var formMode: FormMode = .create
	@State var ticketIdToBuy: Int?
	@State var ticketIdToConfirm: Int?
	@State var selectedStatus = "none"
	@State var fromQuery = ""
	@State var toQuery = ""
	@FocusState var focusedQueryField: QueryField?
	@FocusState var focusedBuyTicketField: BuyTicketField?

	var canEdit: Bool { editRoles.contains(userRole) }

	var items: [Ticket] {
		return ticketsModel.tickets
			.filter { ticket in
				guard
					let firstCoupon = ticket.coupons.first,
					let lastCoupon = ticket.coupons.last
				else { return false }

				let fromQuery = fromQuery.lowercased().trimmingCharacters(
					in: .whitespaces)
				let toQuery = toQuery.lowercased().trimmingCharacters(
					in: .whitespaces)

				return
					(fromQuery.isEmpty
					|| firstCoupon.from.lowercased().contains(fromQuery))
					&& (toQuery.isEmpty
						|| lastCoupon.to.lowercased().contains(toQuery))
			}
	}
	
	var formIsReady: Bool {
		switch formMode {
			case .create:
				fallthrough
			case .update:
				return formService.data.coupons.count > 0
			case .buy:
				return true
			case .buyConfirm:
				return buyConfirmTicketFormService.data.cash_desk_id != 0
		}
	}

	func refreshAll() {
		selectedStatus = "none"

		ticketsModel.getStatuses()
		ticketsModel.getTypes()
		ticketsModel.fetch()
	}

	func presentForm(_ mode: FormModeSetter) {
		isFormPresented = true

		switch mode {
		case .create:
			break
		case .update(let ticket):
			formMode = .update
			formService.setData(
				.init(
					id: ticket.id, company_code: ticket.company.code,
					type_id: ticket.type.id, coupons: ticket.coupons))
		case .buy(let ticket):
			formMode = .buy
			ticketIdToBuy = ticket.id
		case .buyConfirm(let ticket):
			formMode = .buyConfirm
			ticketIdToConfirm = ticket.id
		}
	}

	func onFormClose() {
		formService.setDefault()
		buyTicketFormSevice.setDefault()
		formMode = .create
		ticketIdToBuy = nil
	}

	func handleFormSubmit() {
		switch formMode {
		case .create:
			ticketsModel.create(formService.data)
		case .update:
			ticketsModel.update(formService.data)
		case .buy:
			ticketsModel.buy(ticketIdToBuy!, credits: buyTicketFormSevice.data)
			case .buyConfirm:
				ticketsModel.confirm(ticketIdToConfirm!, dto: buyConfirmTicketFormService.data)
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
				.padding(.bottom)
				VStack(spacing: 12) {
					if items.isEmpty {
						Spacer()
						Text("Тут пусто")
					} else {
						ForEach(items, id: \.id) { ticket in
							TicketItem(
								ticket,
								isOpen: openedTicketId == ticket.id,
								userRole: userRole,
								onOpen: { openedTicketId = ticket.id },
								onClose: { openedTicketId = nil },
								onUpdate: { presentForm(.update(ticket)) },
								onBuy: { presentForm(.buy(ticket)) },
								onConfirm: { presentForm(.buyConfirm(ticket)) }
							)
							.environmentObject(ticketsModel)
							.transition(.scale)
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
						presentForm(.create)
					}
				}
			}
			.refreshable { refreshAll() }
			.onChange(
				of: selectedStatus,
				{ oldValue, newValue in
					ticketsModel.fetch(
						statusCode: newValue == "none" ? nil : newValue)
				}
			)
			.modifier(
				FormSheetModifier(
					$isFormPresented,
					title: formMode == .buy ? "купить билет" : nil,
					isEdit: formMode == .update,
					savable: formIsReady,
					onCancel: onFormClose,
					onSave: handleFormSubmit,
					formView: {
						switch formMode {
						case .buy:
							Form {
								Section("ФИО") {
									TextField(
										"Введите текст",
										text: $buyTicketFormSevice.data.fio
									)
									.focused(
										$focusedBuyTicketField, equals: .fio
									)
									.submitLabel(.next)
									.onSubmit {
										focusedBuyTicketField = .passport
									}
								}
								Section("Паспорт") {
									TextField(
										"Введите текст",
										text: $buyTicketFormSevice.data.passport
									)
									.focused(
										$focusedBuyTicketField,
										equals: .passport
									)
									.submitLabel(.next)
									.onSubmit {
										focusedBuyTicketField = .email
									}
								}
								Section("Почта") {
									TextField(
										"Введите текст",
										text: $buyTicketFormSevice.data.email
									)
									.focused(
										$focusedBuyTicketField, equals: .email
									)
									.submitLabel(.done)
									.onSubmit {
										focusedBuyTicketField = nil
									}
								}
							}
							case .buyConfirm:
								Form {
									Section("Касса") {
										Picker("Выберите кассу", selection: $buyConfirmTicketFormService.data.cash_desk_id) {
											Text("").tag(0)
											ForEach(cashDesksModel.cashDesks, id: \.id) { cashdesk in
												Text(cashdesk.address).tag(cashdesk.id)
											}
										}
									}
								}
						default:
							TicketForm(
								isOpen: isFormPresented,
								types: ticketsModel.types,
								formData: $formService.data)
						}
					})
			)
			.animation(.easeInOut(duration: 0.2), value: items.count)
			.animation(.easeInOut(duration: 0.2), value: openedTicketId)
		}
	}
}
