import SwiftUI

struct ConfirmDialogModifier: ViewModifier {
	@Binding var isPresented: Bool
	let confirmText: String
	let onCancel: () -> Void
	let onConfirm: () -> Void

	init(
		_ isPresented: Binding<Bool>,
		confirmText: String = "Подтвердить",
		onCancel: @escaping () -> Void = {},
		onConfirm: @escaping () -> Void
	) {
		self._isPresented = isPresented
		self.confirmText = confirmText
		self.onCancel = onCancel
		self.onConfirm = onConfirm
	}

	func body(content: Content) -> some View {
		content
			.confirmationDialog(
				"\(confirmText)?",
				isPresented: $isPresented
			) {
				Button("\(confirmText)", role: .destructive) {
					isPresented = false
					onConfirm()
				}
				Button("Отмена", role: .cancel) {
					isPresented = false
					onCancel()
				}
			}
	}
}

#Preview {
	@Previewable @State var isPresented: Bool = false

	Button("удалить") {
		isPresented = true
	}
	.modifier(
		ConfirmDialogModifier(
			$isPresented,
			onCancel: {
				print("cancel")
			},
			onConfirm: {
				print("delete")
			}))
}
