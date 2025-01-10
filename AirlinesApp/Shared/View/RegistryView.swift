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
	let itemTitle: (_: Data.Element) -> String
	let onDelete: (_: Data.Element) -> Void
	let onItemOpen: (_: Data.Element) -> Void
	let onItemCancel: () -> Void
	let onItemCreate: () -> Void
	let onUpdateSave: (_: Data.Element) -> Void
	let label: (_: Data.Element) -> Label
	let content: (_: Data.Element) -> Detail

	var identifiableData: [IdentifableItem] {
		data.map { item in
			IdentifableItem(id: item[keyPath: idKey], value: item)
		}
	}

	@State var isDetailPageActive: Bool = false
	@State var mode: Mode = .view
	@State var isCreateDialogPresented: Bool = false
	@State var isConfirmDeleteDialogPresented: Bool = false
	@State var itemToDelete: Data.Element? = nil

	init(
		data: Data,
		isLoading: Bool,
		formFields: [FormField],
		canEdit: Bool,
		updatable: Bool = true,
		idKey: KeyPath<Data.Element, ID>,
		itemTitle: @escaping (_: Data.Element) -> String,
		onItemOpen: @escaping (_: Data.Element) -> Void,
		onItemCancel: @escaping () -> Void,
		onItemCreate: @escaping () -> Void,
		onUpdateSave: @escaping (_: Data.Element) -> Void,
		onDelete: @escaping (_: Data.Element) -> Void,
		@ViewBuilder label: @escaping (_: Data.Element) -> Label,
		@ViewBuilder detail: @escaping (_: Data.Element) -> Detail
	) {
		self.data = data
		self.canEdit = canEdit
		self.isLoading = isLoading
		self.formFields = formFields
		self.idKey = idKey
		self.itemTitle = itemTitle
		self.onItemOpen = onItemOpen
		self.onItemCancel = onItemCancel
		self.onItemCreate = onItemCreate
		self.onUpdateSave = onUpdateSave
		self.onDelete = onDelete
		self.updatable = updatable
		self.label = label
		self.content = detail
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

	func handleItemCreate() {
		onItemCancel()
		mode = .create
		isCreateDialogPresented = true
	}

	func handleItemCreateCancel() {
		onItemCancel()
		mode = .view
	}

	func handleItemCreateConfirm() {
		onItemCreate()
		isCreateDialogPresented = false
		onItemCancel()
		mode = .view
	}

	func handleItemCancel(_ item: Data.Element) {
		onItemOpen(item)
		mode = .view
	}

	func handleItemSave(_ item: Data.Element) {
		onUpdateSave(item)
		mode = .view
	}

	@ViewBuilder
	var listView: some View {
		if identifiableData.isEmpty {
			Text("Тут пусто")
		} else {
			List {
				ForEach(identifiableData, id: \.id) { item in
					NavigationLink(value: item.id.hashValue) {
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
								if (field.optional) {
									Text("пусто").tag("").foregroundStyle(.secondary)
								}
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
		VStack {
			if isLoading {
				ProgressView()
			} else {
				listView
					.onChange(
						of: isDetailPageActive,
						{ oldValue, newValue in
							print(oldValue, newValue)
						}
					)
					.navigationDestination(for: Int.self) { id in
						if let selectedItem = data.first(where: {
							$0[keyPath: idKey].hashValue == id
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
							.onAppear {
								onItemOpen(selectedItem)
							}
							.onDisappear {
								handleItemCancel(selectedItem)
							}
							.navigationTitle(itemTitle(selectedItem))
							.toolbar {
								if canEdit {
									if mode == .view {
										Button("удалить", systemImage: "trash")
										{
											handleItemDelete(selectedItem)
										}
										.tint(.red)
										if updatable {
											Button(
												"изменить",
												systemImage: "square.and.pencil"
											) {
												mode = .edit
											}
										}
									} else {
										Button(
											"отменить",
											systemImage: "arrow.uturn.backward"
										) {
											handleItemCancel(selectedItem)
										}

										Button(
											"сохранить",
											systemImage: "checkmark.circle.fill"
										) {
											handleItemSave(selectedItem)
										}
									}
								}
							}
						} else {
							Text("Элемент не найден")
						}
					}
					.sheet(
						isPresented: $isCreateDialogPresented,
						content: {
							VStack(spacing: 0) {
								HStack {
									Text("добавить")
										.font(.headline)
									Spacer()
									Button("сохранить") {
										handleItemCreateConfirm()
									}
									.padding(.vertical, 6)
									.padding(.horizontal, 12)
									.background(Color.blue)
									.foregroundStyle(.white)
									.clipShape(.rect(cornerRadius: 12))
								}.padding()

								formVeiw
							}
						}
					)
					.onChange(
						of: isCreateDialogPresented,
						{ oldValue, newValue in
							if !newValue {
								handleItemCreateCancel()
							}
						}
					)
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
		.toolbar {
			if canEdit {
				Button("создать", systemImage: "plus") {
					handleItemCreate()
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
			itemTitle: { $0.name },
			onItemOpen: { item in },
			onItemCancel: { print("Update cancel") },
			onItemCreate: {},
			onUpdateSave: { print("Update save \($0.name)") },
			onDelete: { print("Delete \( $0.name)") },
			label: { item in
				Text("\(item.name)")
			},
			detail: { item in
				Text("Detail for \(item.name)")
			}
		)
		.navigationTitle("реестр")
	}
}
