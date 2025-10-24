//
//  AddDocumentViewModel.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import Foundation
import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import Combine
import CoreData

final class AddDocumentViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var images: [UIImage] = [] {
        willSet { objectWillChange.send() }
    }
    
    @Published var generatedPDF: PDFDocument? {
        willSet { objectWillChange.send() }
    }
    
    @Published var isLoading = false {
        willSet { objectWillChange.send() }
    }

    func createPDF() {
        isLoading = true
        ///  Создаем PDF
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfDocument = PDFDocument()
            for (index, image) in self.images.enumerated() {
                if let pdfPage = PDFPage(image: image) {
                    pdfDocument.insert(pdfPage, at: index)
                }
            }
            
            /// Сохраняем в CoreData
            self.savePDF(pdfDocument)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.generatedPDF = pdfDocument
                self.isLoading = false
            }
        }
    }

    func handleFileImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessGranted = url.startAccessingSecurityScopedResource()
            defer {
                if accessGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            if url.pathExtension.lowercased() == "pdf" {
                guard let pdf = PDFDocument(url: url) else {
                    print("❌ Failed to load PDF:", url.lastPathComponent)
                    return
                }

                if let firstPage = pdf.page(at: 0) {
                    let pageBounds = firstPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
                    let previewImage = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pageBounds)

                        /// Поправляем вертикальное зеркалывание
                        ctx.cgContext.translateBy(x: 0, y: pageBounds.height)
                        ctx.cgContext.scaleBy(x: 1, y: -1)

                        firstPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }

                    DispatchQueue.main.async {
                        self.images.append(previewImage)
                    }
                }

                /// Добавляем все страницы воедино
                DispatchQueue.global(qos: .userInitiated).async {
                    var newImages: [UIImage] = []

                    for pageIndex in 0..<pdf.pageCount {
                        guard let page = pdf.page(at: pageIndex) else { continue }
                        let bounds = page.bounds(for: .mediaBox)
                        let renderer = UIGraphicsImageRenderer(size: bounds.size)
                        let img = renderer.image { ctx in
                            UIColor.white.set()
                            ctx.fill(bounds)

                            /// Поправляем вертикальное зеркалывание
                            ctx.cgContext.translateBy(x: 0, y: bounds.height)
                            ctx.cgContext.scaleBy(x: 1, y: -1)

                            page.draw(with: .mediaBox, to: ctx.cgContext)
                        }
                        newImages.append(img)
                    }

                    DispatchQueue.main.async {
                        if newImages.count > 1 {
                            self.images.append(contentsOf: newImages.dropFirst())
                        }
                    }
                }

            } else if let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.images.append(image)
                }

            } else {
                print("❌ Unsupported file:", url.lastPathComponent)
            }

        case .failure(let error):
            print("❌ File import error:", error)
        }
    }

    private func savePDF(_ pdf: PDFDocument) {
        guard let data = pdf.dataRepresentation() else {
            print("❌ Failed to convert PDF to Data")
            return
        }

        let context = PersistenceController.shared.container.viewContext

        let entity = SavedPDF(context: context)
        entity.id = UUID()
        entity.name = "Document_\(Int(Date().timeIntervalSince1970))"
        entity.createdAt = Date()
        entity.pdfData = data

        do {
            try context.save()
            print("✅ PDF saved into CoreData")
        } catch {
            print("❌ CoreData save error:", error)
        }
    }
}
