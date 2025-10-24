//
//  DocumentRowView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import SwiftUI
import PDFKit

struct DocumentRowView: View {
    let doc: SavedPDF
    let isSelected: Bool
    let selectionMode: Bool

    var body: some View {
        HStack(spacing: 16) {
            if let thumb = thumbnail(from: doc.pdfData) {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 60)
                    .cornerRadius(6)
            } else {
                Image(systemName: "doc.text")
                    .resizable()
                    .frame(width: 40, height: 50)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(doc.name ?? "Без названия")
                    .font(.headline)
                    .lineLimit(1)
                Text("PDF")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if selectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding(.vertical, 6)
    }

    private func thumbnail(from data: Data?) -> UIImage? {
        guard let data = data, let pdf = PDFDocument(data: data),
              let page = pdf.page(at: 0) else { return nil }

        let pageRect = page.bounds(for: .mediaBox)
        let scale: CGFloat = 0.2
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)
        return page.thumbnail(of: scaledSize, for: .mediaBox)
    }

    private func formattedDate(from url: URL) -> String {
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
           let date = attr[.creationDate] as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return "Unknown date"
    }
}
