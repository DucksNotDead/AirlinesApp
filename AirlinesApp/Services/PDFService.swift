import Foundation
import PDFKit
import QuickLook
import SwiftUI

class PDFService {
	struct PDFDocument: FileDocument {
		static var readableContentTypes: [UTType] = [.pdf]
		var data: Data

		init(data: Data) {
			self.data = data
		}

		init(configuration: ReadConfiguration) throws {
			guard let data = configuration.file.regularFileContents else {
				throw CocoaError(.fileReadCorruptFile)
			}
			self.data = data
		}

		func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
			return FileWrapper(regularFileWithContents: data)
		}
	}
	
	struct PreviewController: UIViewControllerRepresentable {
		let data: Data
		let fileName: String
		var onDismiss: (() -> Void)?
		
		func makeCoordinator() -> Coordinator {
			return Coordinator(data: data, fileName: fileName, onDismiss: onDismiss)
		}
		
		func makeUIViewController(context: Context) -> QLPreviewController {
			let controller = QLPreviewController()
			controller.dataSource = context.coordinator
			controller.delegate = context.coordinator
			return controller
		}
		
		func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
		
		class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
			let fileURL: URL
			var onDismiss: (() -> Void)?
			
			init(data: Data, fileName: String, onDismiss: (() -> Void)?) {
				// Сохраняем Data во временный файл
				let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
				try? data.write(to: tempURL)
				self.fileURL = tempURL
				self.onDismiss = onDismiss
			}
			
			func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
				return fileURL as QLPreviewItem
			}
			
			func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
				return 1
			}
			
			func previewControllerDidDismiss(_ controller: QLPreviewController) {
				onDismiss?()
			}
		}
	}

	func save(_ file: Data, as name: String) -> URL? {
		let fileManager = FileManager.default
		do {
			let documentsURL = try fileManager.url(
				for: .downloadsDirectory,
				in: .allDomainsMask,
				appropriateFor: nil,
				create: false)
			try file.write(to: documentsURL)
			return documentsURL
		} catch (let err) {
			print(err.localizedDescription)
			return nil
		}
	}

	func render<Content: View>(_ content: Content) -> Data? {
		let controller = UIHostingController(rootView: content)
		let view = controller.view!
		
		// Определяем размер view
		let targetSize = controller.sizeThatFits(in: CGSize(width: 612, height: CGFloat.greatestFiniteMagnitude)) // A4 по ширине
		view.frame = CGRect(origin: .zero, size: targetSize)

		let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: targetSize))
		let data = pdfRenderer.pdfData { context in
			context.beginPage()
			view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
		}

		return data
	}
}

let pdfService = PDFService()
