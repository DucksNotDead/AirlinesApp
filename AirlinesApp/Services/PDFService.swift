import Foundation
import PDFKit

class PDFService {
	func save(file: Data, as name: String) -> URL? {
		let fileManager = FileManager.default
		do {
			let documentsURL = try fileManager.url(
				for: .documentDirectory,
				in: .userDomainMask,
				appropriateFor: nil,
				create: false)
			let fileURL = documentsURL.appendingPathComponent("\(name).pdf")
			try file.write(to: fileURL)
			return fileURL
		} catch {
			return nil
		}
	}
}

let pdfService = PDFService()
