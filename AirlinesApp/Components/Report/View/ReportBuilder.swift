import SwiftUI

struct ReportBuilder {
	static let padding: CGFloat = 12
	static let innerPadding: CGFloat = 8
	static let sectionPadding: CGFloat = 24

	struct Layout<C: View>: View {
		var title: String
		var content: () -> C

		init(title: String, @ViewBuilder sections: @escaping () -> C) {
			self.title = title
			self.content = sections
		}

		var body: some View {
			VStack {
				Text(title)
					.font(.headline)
					.padding(.top)

				content()

				Spacer()
			}
			.padding(.all, 8)
			.ignoresSafeArea(.all)
		}
	}

	struct Section<C: View>: View {
		let content: () -> C

		init(@ViewBuilder content: @escaping () -> C) {
			self.content = content
		}

		var body: some View {
			VStack(alignment: .leading, spacing: ReportBuilder.padding) {
				Divider()
					.padding(.vertical, ReportBuilder.sectionPadding)
				content()
			}
		}
	}

	struct Table: View {
		struct Cell: View {
			let value: String
			let isHead: Bool
			let width: CGFloat?

			init(_ value: String, isHead: Bool = false, width: CGFloat? = nil) {
				self.value = value
				self.isHead = isHead
				self.width = width
			}

			var body: some View {
				Text(value)
					.font(.system(size: 13, weight: isHead ? .medium : .light))
					.frame(maxWidth: width ?? .infinity, alignment: .leading)
					.padding(.horizontal, 4)
			}
		}
		struct HeaderRow {
			var label: String
			var width: CGFloat? = nil
		}
		let title: String
		let header: [HeaderRow]
		let content: AnyView

		init(
			_ title: String, header: [HeaderRow],
			@ViewBuilder content: @escaping () -> some View
		) {
			self.title = title
			self.header = header
			self.content = AnyView(content())
		}

		var body: some View {
			VStack(spacing: ReportBuilder.innerPadding) {
				Text(title)
					.font(.subheadline)
				HStack {
					ForEach(header, id: \.label) { row in
						Self.Cell(
							row.label, isHead: true, width: row.width)
					}
				}
				content
			}
			.padding(.top, ReportBuilder.padding)
		}
	}
}
