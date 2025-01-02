//
//  ProgressView.swift
//  Stronger
//
//  Created by Liza on 13/11/2024.
//
import SwiftUI

struct HydrationView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var progress: CGFloat = 0.0
    @State private var startAnimation: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black.opacity(0.2))
                        .scaleEffect(x: 1.1, y: 1)
                        .offset(y: -1)
                    
                    WaterWave(
                        progress: CGFloat(viewModel.hydrationData.glassCount) * viewModel.hydrationData.glassVolume / viewModel.hydrationData.dailyLimit,
                        waveHeight: 0.1,
                        offset: startAnimation
                    )
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                    
                    Text("\(Int((CGFloat(viewModel.hydrationData.glassCount) * viewModel.hydrationData.glassVolume / viewModel.hydrationData.dailyLimit) * 100))%")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
                .frame(width: size.width, height: size.height, alignment: .center)
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        startAnimation = size.width
                    }
                }
            }
            .frame(height: 350)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Pojemność szklanki:")
                        .foregroundColor(Color.gray.opacity(0.8))
                        .font(.headline)
                    
                    Picker("Pojemność", selection: $viewModel.hydrationData.glassVolume) {
                        ForEach(Array(stride(from: 0.1, through: 0.5, by: 0.05)), id: \.self) { volume in
                            Text("\(Int(volume * 1000)) ml")
                                .tag(volume)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: viewModel.hydrationData.glassVolume) {
                        viewModel.saveHydrationData()
                    }
                }
                
                HStack {
                    Text("Limit dzienny:")
                        .foregroundColor(Color.gray.opacity(0.8))
                        .font(.headline)
                    
                    Picker("Limit", selection: $viewModel.hydrationData.dailyLimit) {
                        ForEach([2.0, 2.5, 3.0, 3.5, 4.0], id: \.self) { limit in
                            Text("\(Int(limit * 1000)) ml")
                                .tag(limit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.hydrationData.dailyLimit) {
                        viewModel.saveHydrationData()
                    }
                    
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                Button(action: {
                    if viewModel.hydrationData.glassCount > 0 {
                        viewModel.hydrationData.glassCount -= 1
                        viewModel.saveHydrationData()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.blue.opacity(0.8), in: Circle())
                }
                
                Text("\(viewModel.hydrationData.glassCount) szklanek")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button(action: {
                    viewModel.hydrationData.glassCount += 1
                    viewModel.saveHydrationData()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.blue.opacity(0.8), in: Circle())
                }
            }
            .padding(.top, 20)
        }
        .applyGradientBackground()
        .onAppear {
            viewModel.loadHydrationData()
        }
    }
}

#Preview {
    HydrationView(viewModel: WorkoutViewModel())
}

struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}




