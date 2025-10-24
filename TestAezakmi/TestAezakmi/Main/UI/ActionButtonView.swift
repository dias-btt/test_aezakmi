//
//  ActionButtonView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 24.10.2025.
//

import SwiftUI

struct ActionButtonsView: View {
    var onImportFile: () -> Void
    var onCreatePDF: () -> Void
    var isCreateDisabled: Bool

    var body: some View {
        HStack {
            Button("Импортировать файл", action: onImportFile)
                .buttonStyle(.borderedProminent)
                .tint(.red)

            Spacer()

            Button("Создать PDF", action: onCreatePDF)
                .buttonStyle(.bordered)
                .tint(.green)
                .disabled(isCreateDisabled)
        }
        .padding(.horizontal)
    }
}
