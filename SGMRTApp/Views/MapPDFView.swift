import PDFKit
import SwiftUI

struct MapPDFView: UIViewRepresentable {
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = .systemBackground
        if let url = Bundle.main.url(forResource: "SingaporeMRTMap", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: url)
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

