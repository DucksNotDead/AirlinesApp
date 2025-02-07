import Foundation
import SwiftUI

struct ClientsOfEachCompanyByDateForm: View {
	@Binding var formData: ClientsOfEachCompanyByDateDto
	@State var date: Date = Date()

	var body: some View {
		Form {
			DatePicker(
				"выберете дату",
				selection: $date,
				displayedComponents: [.date]
			)
		}
		.onChange(of: date) { _, newValue in
			formData.date = dateService.dateString(newValue)
		}
	}
}
