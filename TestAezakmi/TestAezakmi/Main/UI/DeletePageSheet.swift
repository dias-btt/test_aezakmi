//
//  DeletePageSheet.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 24.10.2025.
//

import SwiftUI
import PDFKit

struct DeletePageSheet: View {
    let pdfDocument: PDFDocument
    let onDelete: (Int) -> Void

    @State private var pageCount: Int = 0

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        if let page = pdfDocument.page(at: index) {
                            let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 130), for: .mediaBox)

                            VStack(spacing: 8) {
                                Image(uiImage: thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 130)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3))
                                    )

                                Text("Стр. \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Button(role: .destructive) {
                                    onDelete(index)
                                    withAnimation {
                                        pageCount = pdfDocument.pageCount
                                    }
                                } label: {
                                    Text("Удалить")
                                        .font(.caption)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Удалить страницу")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            pageCount = pdfDocument.pageCount
        }
    }
}
