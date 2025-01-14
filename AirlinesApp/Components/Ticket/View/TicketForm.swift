import SwiftUI

struct TicketForm: View {
	enum Field {
		case from
		case to
		case rate
	}

	let isOpen: Bool
	let types: [TicketType]

	@Binding var formData: TicketCreateUpdateDto
	@StateObject var companiesModel = CompaniesViewModel()
	@State var selectedIndex: Int?
	@FocusState var focused: Field?

	var couponsCount: Int { formData.coupons.count }
	var canAdd: Bool { couponsCount < 4 }

	func removeCoupon(_ index: Int) {
		if formData.coupons.indices.contains(index) {
			formData.coupons.remove(at: index)
		}
	}

	func checkCoupon(_ index: Int) {
		guard formData.coupons.indices.contains(index) else { return }
		
		let coupon = formData.coupons[index]

		guard !coupon.from.isEmpty else {
			removeCoupon(index)
			return
		}

		guard !coupon.to.isEmpty else {
			removeCoupon(index)
			return
		}

		guard coupon.rate != 0 else {
			removeCoupon(index)
			return
		}
	}

	var body: some View {
		Form {
			Section("Авиакомпания") {
				Picker("выбрать", selection: $formData.company_code) {
					Text("выбрать").tag("")
					ForEach(companiesModel.companies, id: \.code) {
						company in
						Text(company.name).tag(company.code)
					}
				}
				.pickerStyle(.wheel)
				.frame(maxHeight: 180)
			}
			Section("Тип") {
				Picker("Тип билета", selection: $formData.type_id) {
					ForEach(types, id: \.id) { type in
						Text(type.localized).tag(type.id)
					}
				}
			}
			Section(
				"Купоны"
					+ (selectedIndex == nil ? "" : " / \(selectedIndex! + 1)")
			) {
				if
					let couponIndex = selectedIndex,
					isOpen,
					formData.coupons.indices.contains(couponIndex)
				{
					if focused != nil {
						Button("скрыть клавиатуру") {
							focused = nil
						}
					}
					HStack {
						Text("Откуда: ")
						TextField(
							"Ввести текст",
							text: $formData.coupons[couponIndex].from
						)
						.focused($focused, equals: .from)
						.submitLabel(.next)
						.onSubmit {
							focused = .to
						}
					}
					HStack {
						Text("Куда: ")
						TextField(
							"Введите текст",
							text: $formData.coupons[couponIndex].to
						)
						.focused($focused, equals: .to)
						.submitLabel(.next)
						.onSubmit {
							focused = .rate
						}
					}
					HStack {
						Text("Стоимость: ")
						TextField(
							"Введите текст",
							value: $formData.coupons[couponIndex].rate,
							format: .number
						)
						.keyboardType(.decimalPad)
						.focused($focused, equals: .rate)
						Text("₽")
					}
					Button("назад") {
						selectedIndex = nil
					}
				} else {
					ForEach(
						Array(formData.coupons.enumerated()), id: \.0
					) { index, coupon in
						Button(action: { selectedIndex = index }) {
							HStack {
								Text("\(index + 1).")
								Text("\(coupon.from) – \(coupon.to)")
								Spacer()
								Text("\(coupon.rate) ₽")
							}
						}
						.swipeActions {
							Button(
								"удалить", systemImage: "trash",
								role: .destructive
							) {
								removeCoupon(index)
							}
						}
					}
					.onMove {
						formData.coupons.move(
							fromOffsets: $0, toOffset: $1)
					}
					if canAdd {
						Button("добавить") {
							formData.coupons.append(
								.init(
									id: nil,
									index: couponsCount + 1,
									from: "",
									to: "",
									rate: 0))
							selectedIndex = couponsCount - 1
						}
					}
				}
			}
		}
		.animation(.easeInOut, value: selectedIndex)
		.animation(.easeInOut, value: focused)
		.animation(.easeInOut, value: couponsCount)
	}
}

#Preview {
	@Previewable @StateObject var formService = FormService(
		TicketCreateUpdateDto(
			id: nil, company_code: "", type_id: 1, coupons: []
		))

	TicketForm(
		isOpen: true,
		types: [
			.init(id: 1, code: "first", localized: "первый"),
			.init(id: 2, code: "second", localized: "второй"),
			.init(id: 3, code: "third", localized: "третий"),
		],
		formData: $formService.data)
}
