//
//  SwiftUIController.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import SwiftUI
import AsyncImageSDK

struct SwiftUIController: View {
    
    @StateObject private var viewModel = SwiftUIViewModel()
    
    @State private var loaded: Bool = false
    
    var body: some View {
        ZStack {
            if loaded {
                VStack(spacing: 10) {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        ForEach(viewModel.asyncImages, id: \.self) { asyncImageWrapper in
                            row(view: asyncImageWrapper.asyncImage.0, text: asyncImageWrapper.asyncImage.1)
                                .frame(height: 50)
                        }
                    })
                    
                    Button(action: {
                        viewModel.clearCache()
                    }, label: {
                        Text("CLEAR CACHE")
                            .foregroundStyle(.white)
                    })
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.blue))
                    .padding(.horizontal, 30)
                    .padding(.bottom)
                }
            } else {
                Image(systemName: "car")
            }
        }
        .onAppear {
            if !loaded {
                viewModel.fetchImages()
            }
        }
        .onReceive(viewModel.$asyncImages, perform: { _ in
            loaded = true
        })
            
    }
    
    @ViewBuilder
    private func row(view: AsyncImagerType, text: String) -> some View {
        if let view = view as? AsyncImagerSwiftUIView {
            HStack {
                Spacer()
                view
                Spacer()
                Text(text)
                Spacer()
            }
        } else {
            Image(systemName: "car")
        }
    }
    
    
}

#Preview {
    SwiftUIController()
}
