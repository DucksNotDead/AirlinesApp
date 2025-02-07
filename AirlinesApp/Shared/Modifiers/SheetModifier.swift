import SwiftUI

struct SheetModifier<C: View>: ViewModifier {
	@Binding var isPresented: Bool
	let title: String
	let buttonLabel: String
	let buttonDisabled: Bool
	let view: () -> C
	let onDone: VoidClosure
	let onDismiss: VoidClosure

	init(
		isPresented: Binding<Bool>,
		title: String,
		buttonLabel: String = "сохранить",
		buttonDisabled: Bool = false,
		@ViewBuilder content: @escaping () -> C,
		onDone: @escaping VoidClosure,
		onDismiss: @escaping VoidClosure
	) {
		self._isPresented = isPresented
		self.title = title
		self.buttonLabel = buttonLabel
		self.buttonDisabled = buttonDisabled
		self.view = content
		self.onDone = onDone
		self.onDismiss = onDismiss
	}

	func body(content: Content) -> some View {
		content
			.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
				VStack(spacing: 0) {
					HStack {
						Text(title)
							.font(.headline)
						Spacer()
						PrimaryButton(buttonLabel, disabled: buttonDisabled) {
							onDone()
							isPresented = false
						}
					}
					.padding()
					.background(Color(UIColor.secondarySystemBackground))

					view()

					Spacer(minLength: 0)
				}
			}
	}
}
