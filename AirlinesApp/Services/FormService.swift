import Combine
import Foundation

class FormService<DataType>: ObservableObject
where DataType: Codable {
	@Published var data: DataType? = nil
	var cancellables: Set<AnyCancellable> = []
	let defaultData: DataType

	required init(
		_ defaultData: DataType,
		_ clousure: @escaping (_ data: DataType) -> Void
	) {
		self.defaultData = defaultData
		setDefault()

		$data
			.receive(on: DispatchQueue.main)
			.sink { clousure($0!) }
			.store(in: &cancellables)

	}

	func setDefault() {
		data = defaultData
	}

	func setData(_ data: DataType) {
		self.data = data
	}
}
