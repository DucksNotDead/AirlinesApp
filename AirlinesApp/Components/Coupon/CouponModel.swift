import Foundation

struct Coupon: Codable, Hashable {
	var id: Int
	var index: Int
	var from: String
	var to: String
	var rate: Int
}
