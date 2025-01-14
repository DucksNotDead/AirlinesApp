import Foundation
import SwiftUI

struct DeleteResponse: Codable {
	var id: Int
}

struct MessageResponse: Codable {
	var message: String
}

struct ChooseOption: Codable, Hashable {
	var label: String
	var value: String
}

enum FormFieldValueType {
	case string(Binding<String>)
	case price(Binding<Int>)
	case boolean(Binding<Bool>)
	case choose(Binding<String>, [ChooseOption])
}

struct FormField {
	var label: String
	var optional: Bool = false
	var value: FormFieldValueType
	var updatable: Bool = true
}

protocol FormConfiguration {
	var createFields: [FormField] { get }
	var updateFields: [FormField] { get }
}

typealias VoidClosure = () -> Void
