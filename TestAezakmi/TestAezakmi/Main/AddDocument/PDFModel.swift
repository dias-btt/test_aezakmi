//
//  SavedPDF.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 24.10.2025.
//

import Foundation
import PDFKit

struct PDFModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let createdAt: Date
    let pdfData: Data

    /// Convenience to get PDFDocument directly
    var pdfDocument: PDFDocument? {
        PDFDocument(data: pdfData)
    }
}
