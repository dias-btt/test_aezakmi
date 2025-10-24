//
//  DocumentListView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import SwiftUI
import PDFKit

struct DocumentsListView: View {
    @StateObject private var viewModel = DocumentsListViewModel()
    @State private var isSelecting = false
    @State private var selectedDocs: Set<SavedPDF> = []

    var body: some View {
        VStack {
            List(selection: $selectedDocs) {
                ForEach(viewModel.savedDocs, id: \.self) { doc in
                    documentRow(for: doc)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(isSelecting ? "Выберите PDF" : "Мои документы")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSelecting ? "Отмена" : "Выбрать") {
                        withAnimation {
                            isSelecting.toggle()
                            if !isSelecting { selectedDocs.removeAll() }
                        }
                    }
                }
            }

            if isSelecting {
                Button(action: {
                    viewModel.mergeMultiplePDFs(Array(selectedDocs))
                    selectedDocs.removeAll()
                    isSelecting = false
                }) {
                    Text("Объединить выбранные (\(selectedDocs.count))")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedDocs.count > 1 ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(selectedDocs.count < 2)
            }
        }
        .onAppear { viewModel.loadDocuments() }
        .sheet(item: $viewModel.openedPDF) { pdf in
            NavigationView {
                PDFReaderView(savedPDF: pdf)
            }
        }
        .sheet(item: $viewModel.shareURL) { url in
            ShareSheet(activityItems: [url])
        }
    }

    private func toggleSelection(for doc: SavedPDF) {
        if selectedDocs.contains(doc) {
            selectedDocs.remove(doc)
        } else {
            selectedDocs.insert(doc)
        }
    }
    
    @ViewBuilder
    private func documentRow(for doc: SavedPDF) -> some View {
        DocumentRowView(
            doc: doc,
            isSelected: selectedDocs.contains(doc),
            selectionMode: isSelecting
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelecting {
                toggleSelection(for: doc)
            } else {
                viewModel.openPDF(entity: doc)
            }
        }
        .contextMenu {
            if !isSelecting {
                Button {
                    viewModel.sharePDF(entity: doc)
                } label: {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    viewModel.deletePDF(entity: doc)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
    }

}

extension URL: Identifiable {
    public var id: String { absoluteString }
}
