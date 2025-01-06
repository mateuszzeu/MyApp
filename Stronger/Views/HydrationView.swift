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
        VStack(spacing: 0) {
            Spacer()
            
            ZStack(alignment: .center) {
                GeometryReader { proxy in
                    let size = proxy.size
                    ZStack {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            //.foregroundColor(.black.opacity(0.2))
                            .foregroundColor(Color.theme.text.opacity(0.2))
                            .offset(y: -1)
                        
                        WaterWave(
                            progress: waveProgress,
                            waveHeight: 0.1,
                            offset: startAnimation
                        )
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .mask {
                            if waveProgress > 0 {
                                    Image(systemName: "drop.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding()
                                }
                        }
                        
                        if waveProgress == 0 {
                            Text("Tap to Add")
                                .font(.headline.weight(.bold))
                                //.foregroundColor(.gray.opacity(0.7))
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
                                //.foregroundColor(.white)
                                .foregroundColor(Color.theme.text)
                                .opacity(0.8)
                            
                            if viewModel.hydrationData.drinks.count < 2 {
                                Text("Long press for more")
                                    .font(.subheadline)
                                    //.foregroundColor(.gray.opacity(0.5))
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
            .frame(width: 330, height: 500)
            
            Spacer()
            
            VStack(spacing: 12) {
                HStack {
                    Text("Glass Volume:")
                        //.foregroundColor(.gray)
                        .foregroundColor(Color.theme.text.opacity(0.7))
                    Spacer()
                    Picker("Volume", selection: $viewModel.hydrationData.glassVolume) {
                        ForEach([0.1, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5], id: \.self) { volume in
                            Text("\(Int(volume * 1000)) ml")
                                .font(.footnote)
                                .bold()
                                .tag(volume)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    .pickerStyle(.wheel)
                    //.tint(.black)
                    .tint(Color.theme.text)
                    .onChange(of: viewModel.hydrationData.glassVolume) {
                        viewModel.saveHydrationData()
                    }
                }
                
                HStack {
                    Text("Daily Limit:")
                        .foregroundColor(Color.theme.text.opacity(0.7))
                    Spacer()
                    Picker("Limit", selection: $viewModel.hydrationData.dailyLimit) {
                        ForEach([1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], id: \.self) { limit in
                            Text("\(Int(limit * 1000)) ml")
                                .font(.footnote)
                                .tag(limit)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                    .pickerStyle(.wheel)
                    .tint(Color.theme.text)
                    .onChange(of: viewModel.hydrationData.dailyLimit) {
                        viewModel.saveHydrationData()
                    }
                }
            }
            .padding()
            .applyTransparentBackground()
            .padding(.horizontal)
        }
        .applyGradientBackground()
        .onAppear {
            viewModel.loadHydrationData()
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
