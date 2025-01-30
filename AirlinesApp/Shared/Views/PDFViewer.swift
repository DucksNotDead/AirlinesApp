import PDFKit
import SwiftUI

struct PDFViewer: UIViewRepresentable {
	let url: URL

	func makeUIView(context: Context) -> PDFView {
		let pdfView = PDFView()
		if let document = PDFDocument(url: url) {
			pdfView.document = document
		}
		pdfView.autoScales = true
		return pdfView
	}

	func updateUIView(_ uiView: PDFView, context: Context) {}
}
