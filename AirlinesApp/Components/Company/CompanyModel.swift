import Foundation

struct Company: Codable, Hashable {
	var code: String
	var name: String
	var address: String
}

struct CompanyCreateUpdateDto: Codable {
	var code: String?
	var name: String
	var address: String
}
