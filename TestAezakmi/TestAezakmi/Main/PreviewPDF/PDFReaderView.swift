//
//  PDFReaderView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import SwiftUI
import PDFKit
import PhotosUI
import CoreData

struct PDFReaderView: View {
    @ObservedObject var savedPDF: SavedPDF
    @State private var pdfDocument: PDFDocument?
    @State private var showShareSheet = false
    @State private var showDeleteSheet = false
    @State private var showAddOptions = false
    @State private var showDocumentPicker = false
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        VStack(spacing: 0) {
            if let pdfDocument = pdfDocument {
                PDFKitView(pdfDocument: pdfDocument)
                    .edgesIgnoringSafeArea(.bottom)
                
                Divider().padding(.vertical, 6)
                
                HStack(spacing: 40) {
                    Button {
                        showDeleteSheet = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.red)
                    .disabled(pdfDocument.pageCount == 0)
                    
                    Button {
                        showAddOptions = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .foregroundColor(.blue)
                    .confirmationDialog(
                        "Добавить страницу",
                        isPresented: $showAddOptions,
                        titleVisibility: .visible
                    ) {
                        Button("Из файла") {
                            showDocumentPicker = true
                        }
                        Button("Из галереи") {
                            showImagePicker = true
                        }
                        Button("Отмена", role: .cancel) { }
                    }
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.green)
                }
                .padding(.vertical, 12)
            } else {
                ProgressView("Загрузка PDF…")
                    .task { loadPDF() }
            }
        }
        .navigationTitle("Читалка PDF")
        .sheet(isPresented: $showDeleteSheet) {
            if let pdfDocument = pdfDocument {
                if #available(iOS 16.0, *) {
                    DeletePageSheet(pdfDocument: pdfDocument) { pageIndex in
                        deletePage(at: pageIndex)
                    }
                    .presentationDetents([.medium, .large])
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = saveTemporaryPDF() {
                ShareSheet(activityItems: [url])
            }
        }
        .fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [.pdf]) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $selectedImages)
                .onDisappear {
                    appendSelectedImagesToPDF()
                }
        }
    }

    // MARK: - PDF Logic

    private func loadPDF() {
        guard let data = savedPDF.pdfData else { return }
        pdfDocument = PDFDocument(data: data)
    }
    
    private func updateCoreDataPDF() {
        guard let pdf = pdfDocument,
              let data = pdf.dataRepresentation(),
              let context = savedPDF.managedObjectContext
        else { return }
        
        savedPDF.pdfData = data
        savedPDF.createdAt = Date()

        do {
            try context.save()
            print("✅ PDF updated in CoreData")
        } catch {
            print("❌ CoreData update failed:", error)
        }
    }

    private func deletePage(at index: Int) {
        guard let pdfDocument = pdfDocument else { return }
        pdfDocument.removePage(at: index)
        updateCoreDataPDF()
    }

    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let newURL):
            guard let currentPDF = pdfDocument,
                  let newPDF = PDFDocument(url: newURL) else { return }

            for i in 0..<newPDF.pageCount {
                if let page = newPDF.page(at: i) {
                    currentPDF.insert(page, at: currentPDF.pageCount)
                }
            }
            updateCoreDataPDF()

        case .failure:
            break
        }
    }

    private func appendSelectedImagesToPDF() {
        guard !selectedImages.isEmpty,
              let pdfDocument = pdfDocument else { return }

        for img in selectedImages {
            if let page = PDFPage(image: img) {
                pdfDocument.insert(page, at: pdfDocument.pageCount)
            }
        }

        updateCoreDataPDF()
        selectedImages.removeAll()
    }

    private func saveTemporaryPDF() -> URL? {
        guard let pdf = pdfDocument else { return nil }
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Shared_\(UUID().uuidString).pdf")
        pdf.write(to: tempURL)
        return tempURL
    }
}
