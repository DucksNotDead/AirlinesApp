import SwiftUI

struct RegistryView<Data, ID, Label, Detail>: View
where
	Data: RandomAccessCollection,
	Data.Element: Hashable,
	ID: Hashable,
	Label: View,
	Detail: View
{
	enum Mode {
		case view
		case edit
		case create
	}

	@Binding var data: Data
	@Binding var formFields: [FormField]
	let canEdit: Bool
	let updatable: Bool
	let idKey: KeyPath<Data.Element, ID>
	let itemTitle: (_: Data.Element) -> String
	let onDelete: (_: Data.Element) -> Void
	let onUpdateCancel: () -> Void
	let onUpdateSave: (_: Data.Element) -> Void
	let label: (_: Data.Element) -> Label
	let content: (_: Data.Element) -> Detail

	@State var isDetailPageActive: Bool = false
	@State var mode: Mode = .view
	@State var isConfirmDeleteDialogPresented: Bool = false
	@State var itemToDelete: Data.Element? = nil

	init(
		data: Binding<Data>,
		formFields: Binding<[FormField]>,
		canEdit: Bool,
		updatable: Bool = true,
		idKey: KeyPath<Data.Element, ID>,
		itemTitle: @escaping (_: Data.Element) -> String,
		onUpdateCancel: @escaping () -> Void,
		onUpdateSave: @escaping (_: Data.Element) -> Void,
		onDelete: @escaping (_: Data.Element) -> Void,
		@ViewBuilder label: @escaping (_: Data.Element) -> Label,
		@ViewBuilder detail: @escaping (_: Data.Element) -> Detail
	) {
		self._data = data
		self.canEdit = canEdit
		self._formFields = formFields
		self.idKey = idKey
		self.itemTitle = itemTitle
		self.onUpdateCancel = onUpdateCancel
		self.onUpdateSave = onUpdateSave
		self.onDelete = onDelete
		self.updatable = updatable
		self.label = label
		self.content = detail
	}

	struct IdentifableItem: Identifiable, Hashable {
		var id: ID
		var value: Data.Element
	}

	func handleItemDelete(_ item: Data.Element) {
		itemToDelete = item
		isConfirmDeleteDialogPresented = true
	}

	func handleItemDeleteCancel() {
		isConfirmDeleteDialogPresented = false
		itemToDelete = nil
	}

	func handeItemDeleteConfirm() {
		if let item = itemToDelete {
			onDelete(item)
		}
		handleItemDeleteCancel()
	}

	func handleItemCancel() {
		onUpdateCancel()
		mode = .view
	}

	func handleItemSave(_ item: Data.Element) {
		onUpdateSave(item)
		mode = .view
	}

	var listView: some View {
		List {
			ForEach(
				data.map { item in
					IdentifableItem(id: item[keyPath: idKey], value: item)
				}, id: \.id
			) { item in
				NavigationLink(value: item.id) {
					label(item.value)
						.swipeActions {
							if canEdit {
								Button("удалить", systemImage: "trash") {
									handleItemDelete(item.value)
								}
								.tint(.red)
							}
						}
				}
			}
		}
	}

	var formVeiw: some View {
		Form {
			ForEach(
				Array(formFields.enumerated()),
				id: \.0
			) { index, field in
				if mode != .edit || (updatable && field.updatable) {
					Section(field.label) {
						switch field.value {
						case .string(let binding):
							TextField("Введите текст", text: binding)
						case .integer(let binding):
							TextField(
								"Введите число", value: binding, format: .number
							)
							.keyboardType(.numberPad)
						case .boolean(let binding):
							Toggle(field.label, isOn: binding)
								.toggleStyle(.switch)
						case .choose(let binding, let options):
							Picker(field.label, selection: binding) {
								ForEach(options, id: \.value) { option in
									Text(option.label).tag(option.value)
								}
							}
							.pickerStyle(.wheel)
							.frame(maxHeight: 140)
						case .date(let binding):
							DatePicker(
								"Выберете дату",
								selection: binding,
								displayedComponents: [.date]
							)
						}
					}
				}
			}
		}
	}

	var body: some View {
		listView
			.onChange(
				of: isDetailPageActive,
				{ oldValue, newValue in
					print(oldValue, newValue)
				}
			)
			.navigationDestination(for: ID.self) { id in
				if let selectedItem = data.first(where: {
					$0[keyPath: idKey] == id
				}) {
					VStack {
						if mode == .view {
							content(selectedItem)
						} else {
							if formFields.isEmpty {
								Text("Нет доступных полей")
							} else {
								formVeiw
							}
						}
					}
					.onDisappear {
						handleItemCancel()
					}
					.navigationTitle(itemTitle(selectedItem))
					.toolbar {
						if canEdit {
							if mode == .view {
								Button("удалить", systemImage: "trash") {
									handleItemDelete(selectedItem)
								}
								.tint(.red)
								Button("изменить", systemImage: "pencil") {
									mode = .edit
								}
							} else {
								HStack {
									Button("отменить") {
										handleItemCancel()
									}
									Button("сохранить") {
										handleItemSave(selectedItem)
									}
								}
							}
						}
					}
				} else {
					Text("Элемент не найден")
				}
			}
			.confirmationDialog(
				"Удалить?",
				isPresented: $isConfirmDeleteDialogPresented
			) {
				Button("Подтвердить удаление", role: .destructive) {
					handeItemDeleteConfirm()
				}
				Button("Отмена", role: .cancel) {
					handleItemDeleteCancel()
				}
			}
	}
}

private struct TestData: Hashable {
	var key: Int
	var name: String
}

private class TestModel: ObservableObject {
	@Published var value: [TestData] = [
		TestData(key: 1, name: "first"),
		TestData(key: 2, name: "second"),
	]

	@Published var canEdit: Bool = true
}

#Preview {
	@Previewable @StateObject var model = TestModel()
	@Previewable @State var formFields: [FormField] = []

	RegistryView(
		data: $model.value,
		formFields: $formFields,
		canEdit: false,
		updatable: true,
		idKey: \.self,
		itemTitle: { $0.name },
		onUpdateCancel: { print("Update cancel") },
		onUpdateSave: { print("Update save \($0.name)") },
		onDelete: { print("Delete \( $0.name)") },
		label: { item in
			Text("\(item.name)")
		},
		detail: { item in
			Text("Detail for \(item.name)")
		}
	)
	.navigationTitle("Title")
}
