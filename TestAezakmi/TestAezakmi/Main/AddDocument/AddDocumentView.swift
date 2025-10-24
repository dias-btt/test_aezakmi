//
//  AddDocumentView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct AddDocumentView: View {
    @StateObject private var viewModel = AddDocumentViewModel()
    @State private var showImagePicker = false
    @State private var showFileImporter = false
    @State private var navigateToViewer = false

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                SelectedImagesScrollView(images: $viewModel.images) {
                    showImagePicker = true
                }

                ActionButtonsView(
                    onImportFile: { showFileImporter = true },
                    onCreatePDF: { viewModel.createPDF() },
                    isCreateDisabled: viewModel.images.isEmpty
                )

                Spacer()
            }
            .navigationTitle("Создание PDF")
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.image, .pdf]
            ) { result in
                viewModel.handleFileImport(result: result)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(images: $viewModel.images)
            }
            .background(
                NavigationLink(
                    destination: PDFPreviewView(pdf: viewModel.generatedPDF),
                    isActive: $navigateToViewer
                ) { EmptyView() }
                    .hidden()
            )

            if viewModel.isLoading {
                LoadingOverlayView()
            }
        }
        .onChange(of: viewModel.generatedPDF) { newValue in
            if newValue != nil {
                navigateToViewer = true
            }
        }
    }
}
