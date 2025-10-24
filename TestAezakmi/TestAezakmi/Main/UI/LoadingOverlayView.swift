//
//  LoadingOverlayView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 24.10.2025.
//

import SwiftUI

struct LoadingOverlayView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView("Создаем PDF…")
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .font(.headline)
        }
    }
}
