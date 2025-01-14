import Foundation

struct Coupon: Codable, Hashable, Identifiable {
	var id: Int?
	var index: Int
	var from: String
	var to: String
	var rate: Int
}

let testCoupons: [Coupon] = [
	.init(id: 1, index: 1, from: "Moscow", to: "Perm", rate: 12000),
	.init(id: 2, index: 2, from: "Perm", to: "Moscow", rate: 15000),
	.init(
		id: 3, index: 3, from: "Moscow", to: "Vladimir", rate: 18000
	),
]

let testCoupon: Coupon = testCoupons[0]
