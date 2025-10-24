//
//  SelectedScrollView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 24.10.2025.
//

import SwiftUI

struct SelectedImagesScrollView: View {
    @Binding var images: [UIImage]
    var onAddTapped: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 160)
                        .clipped()
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(radius: 2)
                }

                Button(action: onAddTapped) {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                        Text("Добавить")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .frame(width: 120, height: 160)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}
