//
//  ProgressView.swift
//  Stronger
//
//  Created by Liza on 13/11/2024.
//

import SwiftUI

struct HydrationView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var startAnimation: CGFloat = 0
    @State private var isPulsating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack(alignment: .center) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        ZStack {
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width * 0.8)
                                .foregroundColor(Color.theme.text.opacity(0.2))
                                .offset(y: -1)
                            
                            WaterWave(
                                progress: waveProgress,
                                waveHeight: 0.1,
                                offset: startAnimation
                            )
                            .fill(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .mask {
                                if waveProgress > 0 {
                                    Image(systemName: "drop.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: size.width * 0.7)
                                        .padding()
                                }
                            }
                            
                            if waveProgress == 0 {
                                Text("Tap to Add")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(Color.theme.text.opacity(0.7))
                                    .scaleEffect(isPulsating ? 1.2 : 1.0)
                                    .opacity(isPulsating ? 0.4 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 1).repeatForever(autoreverses: true),
                                        value: isPulsating
                                    )
                                    .onAppear {
                                        isPulsating = true
                                    }
                                    .offset(y: 60)
                            } else {
                                Text("\(Int(waveProgress * 100))%")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundColor(Color.theme.text)
                                    .opacity(0.8)
                                
                                if viewModel.hydrationData.drinks.count < 2 {
                                    Text("Long press for more")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.text.opacity(0.5))
                                        .offset(y: 40)
                                        .opacity(isPulsating ? 0.2 : 1.0)
                                        .animation(
                                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                            value: isPulsating
                                        )
                                        .onAppear {
                                            isPulsating = true
                                        }
                                }
                            }
                            
                            Button(action: {
                                viewModel.hydrationData.drinks.append(viewModel.hydrationData.glassVolume)
                                viewModel.saveHydrationData()
                                isPulsating = false
                            }) {
                                Color.clear
                            }
                            .frame(width: size.width, height: size.height)
                            .contentShape(Circle())
                            .contextMenu {
                                Button("Remove last glass") {
                                    if !viewModel.hydrationData.drinks.isEmpty {
                                        viewModel.hydrationData.drinks.removeLast()
                                        viewModel.saveHydrationData()
                                    }
                                }
                                Button("Reset") {
                                    viewModel.hydrationData.drinks.removeAll()
                                    viewModel.saveHydrationData()
                                }
                            }
                        }
                        .frame(width: size.width, height: size.height)
                        .onAppear {
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                startAnimation = 360
                            }
                        }
                    }
                }
                .frame(height: 470)
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("Glass Volume:")
                            .foregroundColor(Color.theme.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        //Spacer()
                        Picker("Volume", selection: $viewModel.hydrationData.glassVolume) {
                            ForEach([0.1, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5], id: \.self) { volume in
                                Text("\(Int(volume * 1000)) ml")
                                    .font(.footnote)
                                    .bold()
                                    .tag(volume)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .pickerStyle(.menu)
                        .tint(Color.theme.text)
                        .onChange(of: viewModel.hydrationData.glassVolume) {
                            viewModel.saveHydrationData()
                        }
                    }
                    
                    HStack {
                        Text("Daily Limit:")
                            .foregroundColor(Color.theme.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Picker("Limit", selection: $viewModel.hydrationData.dailyLimit) {
                            ForEach([1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], id: \.self) { limit in
                                Text("\(Int(limit * 1000)) ml")
                                    .font(.footnote)
                                    .bold()
                                    .tag(limit)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing) 
                        .tint(Color.theme.text)
                        .onChange(of: viewModel.hydrationData.dailyLimit) {
                            viewModel.saveHydrationData()
                        }
                    }
                }
                .padding()
                .applyTransparentBackground()
                .padding(.horizontal)
                .padding(.bottom, 15)
                
                Spacer()
            }
            .padding(.top, 15)
            .applyGradientBackground()
            .onAppear {
                viewModel.loadHydrationData()
            }
        }
    }
    
    private var waveProgress: CGFloat {
        let totalConsumed = viewModel.hydrationData.drinks.reduce(0, +)
        let limit = viewModel.hydrationData.dailyLimit
        return limit > 0 ? CGFloat(totalConsumed / limit) : 0
    }
}

#Preview {
    HydrationView(viewModel: WorkoutViewModel())
}
