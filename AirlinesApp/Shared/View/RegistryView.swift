import SwiftUI

struct RegistryView<Data, ID, Label>: View
where
	Data: RandomAccessCollection,
	Data.Element: Hashable,
	ID: Hashable,
	Label: View
{
	struct IdentifableItem: Identifiable, Hashable {
		var id: ID
		var value: Data.Element
	}

	typealias ItemClosure = (_: Data.Element) -> Void

	let data: Data
	let formFields: [FormField]
	let canEdit: Bool
	let isLoading: Bool
	let idKey: KeyPath<Data.Element, ID>
	let onDelete: ItemClosure
	let onItemOpen: ItemClosure
	let onItemCancel: VoidClosure
	let onItemCreate: VoidClosure
	let onUpdateSave: ItemClosure
	let onRefresh: VoidClosure
	let label: (_: Data.Element) -> Label

	var identifiableData: [IdentifableItem] {
		data.map { item in
			IdentifableItem(id: item[keyPath: idKey], value: item)
		}
	}

	@State var isFormDialogPresented: Bool = false
	@State var isConfirmDeleteDialogPresented: Bool = false
	@State var itemToDelete: Data.Element? = nil
	@State var itemToUpdate: Data.Element? = nil

	init(
		data: Data,
		isLoading: Bool,
		formFields: [FormField],
		canEdit: Bool,
		updatable: Bool = true,
		idKey: KeyPath<Data.Element, ID>,
		onItemOpen: @escaping ItemClosure,
		onItemCancel: @escaping VoidClosure,
		onItemCreate: @escaping VoidClosure,
		onUpdateSave: @escaping ItemClosure,
		onDelete: @escaping ItemClosure,
		onRefresh: @escaping VoidClosure,
		@ViewBuilder label: @escaping (_: Data.Element) -> Label
	) {
		self.data = data
		self.canEdit = canEdit
		self.isLoading = isLoading
		self.formFields = formFields
		self.idKey = idKey
		self.onItemOpen = onItemOpen
		self.onItemCancel = onItemCancel
		self.onItemCreate = onItemCreate
		self.onUpdateSave = onUpdateSave
		self.onDelete = onDelete
		self.onRefresh = onRefresh
		self.label = label
	}

	func handleItemDelete(_ item: Data.Element) {
		itemToDelete = item
		isConfirmDeleteDialogPresented = true
	}

	func handeItemDeleteConfirm() {
		if let item = itemToDelete {
			onDelete(item)
		}
		handleItemDeleteCancel()
	}

	func handleItemDeleteCancel() {
		itemToDelete = nil
	}

	func setItemToUpdate(_ item: Data.Element? = nil) {
		itemToUpdate = item
	}

	func handleFormOpen(_ item: Data.Element? = nil) {
		isFormDialogPresented = true

		if let item {
			setItemToUpdate(item)
			onItemOpen(item)
		} else {
			setItemToUpdate()
			onItemCancel()
		}
	}

	func handleFormCancel() {
		isFormDialogPresented = false
		setItemToUpdate()
		onItemCancel()
	}

	func handleFormSave() {
		if let item = itemToUpdate {
			onUpdateSave(item)
		} else {
			onItemCreate()
		}

		handleFormCancel()
	}

	@ViewBuilder
	var formView: some View {
		Form {
			ForEach(
				Array(
					formFields.sorted(by: { a, b in
						!a.updatable && b.updatable
					}).enumerated()),
				id: \.0
			) { index, field in
				if itemToUpdate == nil || field.updatable {
					Section(field.label) {
						switch field.value {
						case .string(let binding):
							TextField("Введите текст", text: binding)

						case .price(let binding):
							TextField(
								"Введите число", value: binding,
								format: .currency(code: "RUB")
							)
							.keyboardType(.numberPad)

						case .boolean(let binding):
							Toggle(field.label, isOn: binding)
								.toggleStyle(.switch)

						case .choose(let binding, let options):
							Picker(field.label, selection: binding) {
								if field.optional {
									Text("Отсутствует").tag("").foregroundStyle(
										.secondary)
								}
								ForEach(options, id: \.value) { option in
									Text(option.label).tag(option.value)
								}
							}
							.pickerStyle(.wheel)
							.frame(maxHeight: 140)
						}
					}
				}
			}
		}
	}

	@ViewBuilder
	var listView: some View {
		if identifiableData.isEmpty {
			Text("Тут пусто")
		} else {
			List {
				ForEach(identifiableData, id: \.id) { item in
					VStack(alignment: .leading) {
						label(item.value)
					}
					.contextMenu {
						if canEdit {
							Button(
								"Изменить", systemImage: "square.and.pencil"
							) {
								handleFormOpen(item.value)
							}
							Button(
								"Удалить", systemImage: "trash",
								role: .destructive
							) {
								handleItemDelete(item.value)
							}

						}
					}
					.swipeActions {
						if canEdit {
							Button("Удалить", systemImage: "trash") {
								handleItemDelete(item.value)
							}
							.tint(.red)
						}
					}
					.swipeActions(edge: .leading) {
						if canEdit {
							Button(
								"Изменить", systemImage: "square.and.pencil"
							) {
								handleFormOpen(item.value)
							}
							.tint(.blue)
						}
					}
				}
			}
		}
	}

	var body: some View {
		VStack {
			listView
				.refreshable { onRefresh() }
				.modifier(
					FormSheetModifier(
						$isFormDialogPresented,
						isEdit: itemToUpdate != nil,
						onCancel: handleFormCancel,
						onSave: handleFormSave,
						formView: { formView }
					)
				)
				.modifier(
					ConfirmDialogModifier(
						$isConfirmDeleteDialogPresented,
						onCancel: handleItemDeleteCancel,
						onConfirm: handeItemDeleteConfirm))
		}
		.toolbar {
			if canEdit {
				Button("создать", systemImage: "plus") {
					handleFormOpen()
				}
				.disabled(isLoading)
			}
		}
		.animation(.easeInOut, value: data.count)
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
	@Previewable @State var stringField: String = ""
	var formFields: [FormField] {
		return [
			.init(label: "Text", value: .string($stringField))
		]
	}

	NavigationStack {
		RegistryView(
			data: model.value,
			isLoading: false,
			formFields: formFields,
			canEdit: true,
			idKey: \.key,
			onItemOpen: { print($0) },
			onItemCancel: { print("Update cancel") },
			onItemCreate: {},
			onUpdateSave: { print("Update save \($0.name)") },
			onDelete: { print("Delete \( $0.name)") },
			onRefresh: {},
			label: { item in
				Text("\(item.name)")
			}
		)
		.navigationTitle("реестр")
	}
}
