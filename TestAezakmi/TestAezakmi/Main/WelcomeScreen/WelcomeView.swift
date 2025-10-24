//
//  WelcomeView.swift
//  TestAezakmi
//
//  Created by Диас Сайынов on 22.10.2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Image("app_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, 20)

                Text("PDF Builder")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Импортируй фотографии, конвертируй в PDF, редактируй страницы, сохраняй и делись документами.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    NavigationLink {
                        DocumentsListView()
                    } label: {
                        Text("Мои документы")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder()
                            )
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 24)

                    NavigationLink {
                        AddDocumentView()
                    } label: {
                        Text("Создать новый документ")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                Text("Версия 1.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}

