//
//  DocumentListViewModel.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import Foundation
import PDFKit
import Combine
import SwiftUI
import CoreData

final class DocumentsListViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var savedDocs: [SavedPDF] = [] {
        willSet { objectWillChange.send() }
    }

    @Published var openedPDF: SavedPDF? {
        willSet { objectWillChange.send() }
    }

    @Published var shareURL: URL? {
        willSet { objectWillChange.send() }
    }
    
    var lastTapped: SavedPDF?

    private let context = PersistenceController.shared.container.viewContext
}

// MARK: - CRUD Operations
extension DocumentsListViewModel {

    func loadDocuments() {
        let request: NSFetchRequest<SavedPDF> = SavedPDF.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            savedDocs = try context.fetch(request)
        } catch {
            print("❌ CoreData fetch error:", error)
        }
    }

    /// Convert binary CoreData data → temp local URL for viewer/sharing
    private func tempURL(from entity: SavedPDF) -> URL? {
        guard let data = entity.pdfData else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(entity.name ?? UUID().uuidString).pdf")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("❌ Temp file write error:", error)
            return nil
        }
    }

    func openPDF(entity: SavedPDF) {
        lastTapped = entity
        openedPDF = entity
    }

    func sharePDF(entity: SavedPDF) {
        shareURL = tempURL(from: entity)
    }

    func deletePDF(entity: SavedPDF) {
        context.delete(entity)
        
        do {
            try context.save()
            loadDocuments()
        } catch {
            print("❌ CoreData delete save error:", error)
        }
    }
}

extension DocumentsListViewModel {
    func mergeMultiplePDFs(_ docs: [SavedPDF]) {
        guard docs.count >= 2 else { return }

        let merged = PDFDocument()
        var index = 0

        for entity in docs {
            guard let data = entity.pdfData,
                  let doc = PDFDocument(data: data) else { continue }

            for pageIndex in 0..<doc.pageCount {
                if let page = doc.page(at: pageIndex) {
                    merged.insert(page, at: index)
                    index += 1
                }
            }
        }

        guard let mergedData = merged.dataRepresentation() else { return }

        let newEntity = SavedPDF(context: context)
        newEntity.id = UUID()
        newEntity.name = "Merged_\(Int(Date().timeIntervalSince1970))"
        newEntity.createdAt = Date()
        newEntity.pdfData = mergedData

        do {
            try context.save()
            loadDocuments()
            print("✅ Merged PDF saved to CoreData")
        } catch {
            print("❌ Failed to save merged PDF:", error)
        }
    }
}
