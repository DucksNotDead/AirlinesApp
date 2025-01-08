import Foundation

extension Encodable {
	/// Приведение тела запроса к json
	func toJSONObject() -> [String: Any]? {
		do {
			// Кодируем объект в Data
			let data = try JSONEncoder().encode(self)

			// Декодируем Data в словарь
			let jsonObject = try JSONSerialization.jsonObject(
				with: data, options: [])

			// Приводим к типу [String: Any]
			return jsonObject as? [String: Any]
		} catch {
			print("Ошибка преобразования в JSONObject: \(error)")
			return nil
		}
	}
}
