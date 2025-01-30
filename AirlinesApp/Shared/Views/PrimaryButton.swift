import SwiftUI

struct PrimaryButton: View {
	let label: String
	let disabled: Bool
	let action: VoidClosure
	@State var isTapped: Bool = false

	@MainActor
	init(_ label: String, disabled: Bool = false, action: @escaping VoidClosure)
	{
		self.label = label
		self.disabled = disabled
		self.action = action
	}

	var body: some View {
		Text(label)
			.padding(.vertical, 6)
			.padding(.horizontal, 12)
			.background(disabled ? Color(UIColor.systemGray5) : Color.blue)
			.foregroundStyle(disabled ? .gray : .white)
			.clipShape(.rect(cornerRadius: 12))
			.opacity(isTapped ? 0.6 : 1)
			.gesture(
				disabled
					? nil
					: DragGesture(minimumDistance: 0)
						.onChanged { _ in
							isTapped = true
						}
						.onEnded({ value in
							isTapped = false
							if abs(value.translation.height) < 30
								&& abs(value.translation.width) < 50
							{
								action()
							}
						})
			)
			.animation(.linear(duration: 0.095), value: isTapped)
	}
}

#Preview {
	PrimaryButton("Сделать что-то", disabled: true) {
		print("anything")
	}
}
