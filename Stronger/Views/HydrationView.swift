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
                            .foregroundColor(.black.opacity(0.2))
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
                            Image(systemName: "drop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                        }

                        Text("\(Int(waveProgress * 100))%")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    .frame(width: size.width, height: size.height)
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            startAnimation = 360
                        }
                    }
                    .onTapGesture {
                        viewModel.hydrationData.drinks.append(viewModel.hydrationData.glassVolume)
                        viewModel.saveHydrationData()
                    }
                }
            }
            .frame(width: 330, height: 500)

            Text("\(viewModel.hydrationData.drinks.count) szklanek")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.vertical, 8)

            Spacer()

            VStack(spacing: 12) {
                HStack {
                    Text("Pojemność szklanki:")
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Pojemność", selection: $viewModel.hydrationData.glassVolume) {
                        ForEach(Array(stride(from: 0.1, through: 0.5, by: 0.05)), id: \.self) { volume in
                            Text("\(Int(volume * 1000)) ml")
                                .tag(volume)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .onChange(of: viewModel.hydrationData.glassVolume) {
                        viewModel.saveHydrationData()
                    }
                }

                HStack {
                    Text("Limit dzienny:")
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Limit", selection: $viewModel.hydrationData.dailyLimit) {
                        ForEach([1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0], id: \.self) { limit in
                            Text("\(Int(limit * 1000)) ml")
                                .tag(limit)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .onChange(of: viewModel.hydrationData.dailyLimit) {
                        viewModel.saveHydrationData()
                    }
                }

                HStack(spacing: 0) {
                    Button {
                        if !viewModel.hydrationData.drinks.isEmpty {
                            viewModel.hydrationData.drinks.removeLast()
                            viewModel.saveHydrationData()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "minus.circle")
                            Text("Odejmij")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }

                    Divider()
                        .frame(width: 1, height: 44)
                        .background(Color.white.opacity(0.5))

                    Button {
                        viewModel.hydrationData.drinks.removeAll()
                        viewModel.saveHydrationData()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Reset")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .tint(.red)
                }
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
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
