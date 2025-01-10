import Combine
import Foundation

class FormService<DataType>: ObservableObject
where DataType: Codable {
	@Published var data: DataType
	var cancellables: Set<AnyCancellable> = []
	let defaultData: DataType

	required init(_ defaultData: DataType) {
		self.defaultData = defaultData
		self.data = defaultData
	}

	func setDefault() {
		data = defaultData
	}

	func setData(_ data: DataType) {
		self.data = data
	}
}
