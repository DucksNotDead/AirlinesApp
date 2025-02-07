import Foundation

struct TotalAmountOfEachCompanyResponse: Codable {
	struct Company: Codable {
		var code: String
		var name: String
		var address: String
		var total: String
	}

	var companies: [Self.Company]
}
