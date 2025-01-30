import Foundation
import SwiftUI

extension View {
	@ViewBuilder
	func conditionalModifier<Content: View>(
		_ condition: Bool,
		modifier: (Self) -> Content
	) -> some View {
		if condition {
			modifier(self)
		} else {
			self
		}
	}
}
