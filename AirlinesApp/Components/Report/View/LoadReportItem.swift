import SwiftUI

struct LoadReportItem: View {
	struct FormProps {
		var disabled: Bool
		var fieldsView: AnyView
		var onCancel: VoidClosure
	}

	@State var isFormOpened: Bool = false

	let isOpen: Bool
	let label: String
	let onLoad: VoidClosure
	let onToggle: VoidClosure
	let formProps: FormProps?

	init(
		label: String,
		isOpen: Bool,
		form: FormProps? = nil,
		onLoad: @escaping VoidClosure,
		onToggle: @escaping VoidClosure
	) {
		self.isOpen = isOpen
		self.onLoad = onLoad
		self.onToggle = onToggle
		self.label = label
		self.formProps = form
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack(spacing: 16) {
				Text(label)
					.multilineTextAlignment(.leading)
					.foregroundStyle(.gray)
				Spacer()
				Image(systemName: "chevron.right.circle")
					.font(.title)
					.foregroundStyle(.blue)
					.rotationEffect(.degrees(isOpen ? -90 : 0))
			}
			.contentShape(Rectangle())
			.onTapGesture {
				onToggle()
			}
			.padding()
			.background(Color.white)
			.zIndex(1)

			if isOpen {
				HStack {
					if formProps != nil {
						Button("заполнить поля") {
							isFormOpened = true
						}
					} else {
						Text("Полей для ввода нет").font(.callout)
						Spacer()
						PrimaryButton("Загрузить") {
							onLoad()
						}
					}
				}
				.zIndex(0)
				.frame(maxWidth: .infinity)
				.padding()
				.background(Color(uiColor: .systemGray6))
				.transition(.move(edge: .top))

			}
		}
		.clipShape(.rect(cornerRadius: 12))
		.shadow(radius: isOpen ? 8 : 0)
		.zIndex(isOpen ? 1 : 0)
		.animation(.easeInOut(duration: 0.2), value: isOpen)
		.conditionalModifier(formProps != nil) { view in
			let form = formProps!
			return view.modifier(
				FormSheetModifier(
					$isFormOpened,
					title: "Данные для отчёта",
					buttonLabel: "получить",
					savable: !form.disabled,
					onCancel: form.onCancel,
					onSave: onLoad,
					formView: { form.fieldsView }
				))
		}
	}
}

private enum SelectedReport {
	case first
	case second
}

#Preview {
	@Previewable @State var selected: SelectedReport? = nil

	VStack {
		LoadReportItem(
			label:
				"Билеты, проданные за указанный месяц указанной авиакомпании",
			isOpen: selected == .first
		) {

		} onToggle: {
			if selected == .first {
				selected = nil
			} else {
				selected = .first
			}
		}
		LoadReportItem(
			label: "Общая сумма от продаж билетов каждой авиакомпании",
			isOpen: selected == .second
		) {

		} onToggle: {
			if selected == .second {
				selected = nil
			} else {
				selected = .second
			}
		}
	}
	.animation(.default, value: selected)

}
