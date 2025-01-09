import Foundation
import Combine

let PORT = 8000

class ApiService {
	// Singleton для удобства
	static let shared = ApiService()

	private init() {}

	/// Базовый URL API
	private let baseURL = URL(string: "http://192.168.0.100:\(PORT)")!

	/// Выполнение запросов с заданным методом и параметрами
	private func request<T: Decodable>(
		path: String,
		method: String,
		parameters: [String: Any]? = nil,
		body: [String: Any]? = nil,
		responseType: T.Type
	) -> AnyPublisher<T, Error> {
		// Формируем URL
		guard let url = URL(string: path, relativeTo: baseURL) else {
			return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
		}

		// Создание запроса
		var request = URLRequest(url: url)
		request.httpMethod = method
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		// Добавляем параметры в URL для методов GET и DELETE
		if let parameters = parameters, (method == "GET" || method == "DELETE") {
			var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
			components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
			request.url = components?.url
		}

		// Добавляем тело запроса для методов POST и PATCH
		if let body = body, (method == "POST" || method == "PATCH") {
			let requestBody = try? JSONSerialization.data(withJSONObject: body, options: [])
			request.httpBody = requestBody
			print(String(data: requestBody!, encoding: .utf8)!)
		}

		// Выполнение запроса через URLSession
		return URLSession.shared.dataTaskPublisher(for: request)
			.tryMap { result in
				guard let httpResponse = result.response as? HTTPURLResponse else {
					throw URLError(.badServerResponse)
				}
				print(String(data: result.data, encoding: .utf8)!)
				
				return result.data
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	// MARK: - Public Methods

	func get<T: Decodable>(path: String, parameters: [String: Any]? = nil, responseType: T.Type) -> AnyPublisher<T, Error> {
		request(path: path, method: "GET", parameters: parameters, responseType: responseType)
	}

	func post<T: Decodable>(path: String, body: [String: Any] = ["": ""], responseType: T.Type) -> AnyPublisher<T, Error> {
		request(path: path, method: "POST", body: body, responseType: responseType)
	}

	func patch<T: Decodable>(path: String, body: [String: Any], responseType: T.Type) -> AnyPublisher<T, Error> {
		request(path: path, method: "PATCH", body: body, responseType: responseType)
	}

	func delete<T: Decodable>(path: String, parameters: [String: Any]? = nil, responseType: T.Type) -> AnyPublisher<T, Error> {
		request(path: path, method: "DELETE", parameters: parameters, responseType: responseType)
	}
}

let api = ApiService.shared
