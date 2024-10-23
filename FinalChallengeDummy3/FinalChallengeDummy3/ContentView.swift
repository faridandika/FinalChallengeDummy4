//
//  ContentView.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 21/10/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @StateObject private var viewModel = FrameViewModel()
    @State private var arView = ARView(frame: .zero)

    var body: some View {
        ZStack {
            ARViewContainer(arView: $arView)
                .edgesIgnoringSafeArea(.all)

            if viewModel.model.anchor != nil {
                GreenOverlay(overlayColor: viewModel.model.overlayColor)
                    .transition(.scale)
                    .animation(.easeInOut)

                Text(viewModel.model.alignmentStatus)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 0)
            }

            VStack {
                Spacer()
                HStack {
                    // Gallery button
                    Button(action: {
                        // Action to open gallery
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 30)

                    Spacer()

                    // Frame toggle button
                    Button(action: {
                        viewModel.toggleFrame(at: arView)
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 70, height: 70)
                            )
                    }

                    Spacer()

                    // Flip camera button
                    Button(action: {
                        
                        
                        // Action to flip camera
                        
                        
                    }) {
                        Image(systemName: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .onChange(of: viewModel.model.anchor) { _ in
        }
    }
}

