//
//  PDFPreviewView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 23.10.2025.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let pdf: PDFDocument?
    @State private var showShareSheet = false
    @State private var tempPDFURL: URL?

    var body: some View {
        Group {
            if let pdf = pdf {
                PDFKitView(pdfDocument: pdf)
                    .edgesIgnoringSafeArea(.all)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                sharePDF(pdf)
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
            } else {
                Text("PDF не найден")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Просмотр PDF")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = tempPDFURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    private func sharePDF(_ pdf: PDFDocument) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("shared.pdf")
        pdf.write(to: tempURL)
        tempPDFURL = tempURL
        showShareSheet = true
    }
}
