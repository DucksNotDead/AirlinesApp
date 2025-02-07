import Foundation

struct ClientsOfEachCompanyByDateDto: Codable {
	var date: String
}

struct ClientsOfEachCompanyByDateResponse: Codable {
	struct CompanyWithClients: Codable {
		struct Client: Codable, Hashable {
			var id: Int
			var passport: Int
			var fio: String
			var user_id: Int?
		}
		
		var code: String
		var name: String
		var address: String
		var clients: [Self.Client]
	}
	
	var companies: [CompanyWithClients]
}
