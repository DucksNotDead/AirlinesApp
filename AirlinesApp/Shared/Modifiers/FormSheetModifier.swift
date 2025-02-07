import SwiftUI

struct FormSheetModifier<FormView: View>: ViewModifier {
	@Binding var isPresented: Bool
	let title: String
	let savable: Bool
	let formView: () -> FormView
	let onSave: VoidClosure
	let onCancel: VoidClosure
	let buttonLabel: String

	init(
		_ isPresented: Binding<Bool>,
		title: String? = nil,
		buttonLabel: String? = nil,
		isEdit: Bool = false,
		savable: Bool = true,
		onCancel: @escaping VoidClosure,
		onSave: @escaping VoidClosure,
		@ViewBuilder formView: @escaping () -> FormView
	) {
		self._isPresented = isPresented
		self.title = title ?? (isEdit ? "изменить" : "добавить")
		self.buttonLabel = buttonLabel ?? "отправить"
		self.savable = savable
		self.formView = formView
		self.onCancel = onCancel
		self.onSave = onSave
	}

	func body(content: Content) -> some View {
		content
			.modifier(SheetModifier(
				isPresented: $isPresented,
				title: title,
				buttonLabel: buttonLabel,
				buttonDisabled: !savable,
				content: formView,
				onDone: onSave,
				onDismiss: onCancel
			))
			.onChange(
				of: isPresented,
				{ oldValue, newValue in
					if !newValue {
						DispatchQueue.main.asyncAfter(
							deadline: .now() + 0.1, execute: onCancel)
					}
				}
			)
	}
}

#Preview {
	@Previewable @State var isPresented: Bool = false
	@Previewable @State var isEdit: Bool = false

	HStack {
		Button("добавить") {
			isPresented = true
			isEdit = false
		}
		Button("изменить") {
			isPresented = true
			isEdit = true
		}
	}
	.modifier(
		FormSheetModifier(
			$isPresented,
			isEdit: isEdit,
			onCancel: {
				isEdit = false
			},
			onSave: {
				print("saved \(isEdit ? "edit" : "add")")
			},
			formView: {}
		))
}
