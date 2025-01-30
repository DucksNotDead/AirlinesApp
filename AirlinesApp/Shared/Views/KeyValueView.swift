import SwiftUI

struct KeyValueView: View {
	let label: String
	let value: String
	
	init(_ label: String, _ value: String) {
		self.label = label
		self.value = value
	}

	var body: some View {
		HStack(spacing: 4) {
			Text("\(label):")
			Text(value)
				.foregroundStyle(.secondary)
		}
		.font(.footnote)
	}
}

#Preview {
	KeyValueView("ФИО", "Иванов Иван Иванович")
}
