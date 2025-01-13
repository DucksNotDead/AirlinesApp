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

	let data: Data
	let formFields: [FormField]
	let canEdit: Bool
	let isLoading: Bool
	let updatable: Bool
	let idKey: KeyPath<Data.Element, ID>
	let onDelete: (_: Data.Element) -> Void
	let onItemOpen: (_: Data.Element) -> Void
	let onItemCancel: () -> Void
	let onItemCreate: () -> Void
	let onUpdateSave: (_: Data.Element) -> Void
	let onRefresh: () -> Void
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
	@FocusState var focusedField: String?

	init(
		data: Data,
		isLoading: Bool,
		formFields: [FormField],
		canEdit: Bool,
		updatable: Bool = true,
		idKey: KeyPath<Data.Element, ID>,
		onItemOpen: @escaping (_: Data.Element) -> Void,
		onItemCancel: @escaping () -> Void,
		onItemCreate: @escaping () -> Void,
		onUpdateSave: @escaping (_: Data.Element) -> Void,
		onDelete: @escaping (_: Data.Element) -> Void,
		onRefresh: @escaping () -> Void,
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
		self.updatable = updatable
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
	var formVeiw: some View {
		Form {
			ForEach(
				Array(formFields.enumerated()),
				id: \.0
			) { index, field in
				if itemToUpdate == nil || (updatable && field.updatable) {
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
				.sheet(
					isPresented: $isFormDialogPresented,
					content: {
						VStack(spacing: 0) {
							HStack {
								Text(
									itemToUpdate != nil
										? "изменить" : "добавить"
								)
								.font(.headline)
								Spacer()
								PrimaryButton("сохранить") {
									handleFormSave()
								}
							}.padding()

							formVeiw
						}
					}
				)
				.onChange(
					of: isFormDialogPresented,
					{ oldValue, newValue in
						if !newValue {
							handleFormCancel()
						}
					}
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
