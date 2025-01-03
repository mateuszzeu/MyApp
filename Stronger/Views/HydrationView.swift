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
            // Górna część ekranu – wyśrodkowana kropla
            Spacer()

            ZStack(alignment: .center) {
                // Można dać stały rozmiar albo
                // dynamicznie: minimalna z szerokości ekranu
                GeometryReader { proxy in
                    let size = proxy.size
                    ZStack {
                        // Kropla (tło)
                        Image(systemName: "drop.fill")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black.opacity(0.2))
                            .offset(y: -1)
                        
                        // Fala w kropli
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

                        // Procent
                        Text("\(Int(waveProgress * 100))%")
                            .font(.largeTitle.weight(.bold))
                            .foregroundColor(.white)
                            .opacity(0.8)
                    }
                    .frame(width: size.width, height: size.height)
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            startAnimation = size.width
                        }
                    }
                    // Tap => dodaj szklankę
                    .onTapGesture {
                        viewModel.hydrationData.glassCount += 1
                        viewModel.saveHydrationData()
                    }
                }
            }
            // Ustal wysokość, np. 350 lub 400
            .frame(width: 330)

            // Informacja o liczbie szklanek
            Text("\(viewModel.hydrationData.glassCount) szklanek")
                .font(.title3)
                .foregroundColor(.white)
                .padding(.vertical, 8)

            Spacer()

            // Dolny panel z pickerami i przyciskami...
            VStack(spacing: 12) {
                HStack {
                    Text("Pojemność szklanki:")
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Pojemność", selection: $viewModel.hydrationData.glassVolume) {
                        ForEach(Array(stride(from: 0.1, through: 0.5, by: 0.05)), id: \.self) { volume in
                            Text("\(Int(volume * 1000)) ml").tag(volume)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .onChange(of: viewModel.hydrationData.glassVolume) { _ in
                        viewModel.saveHydrationData()
                    }
                }

                HStack {
                    Text("Limit dzienny:")
                        .foregroundColor(.gray)
                    Spacer()
                    Picker("Limit", selection: $viewModel.hydrationData.dailyLimit) {
                        ForEach([1.5, 2.0, 2.5, 3.0, 4.0], id: \.self) { limit in
                            Text("\(Int(limit * 1000)) ml").tag(limit)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black)
                    .onChange(of: viewModel.hydrationData.dailyLimit) { _ in
                        viewModel.saveHydrationData()
                    }
                }

                HStack(spacing: 0) {
                    // Odejmij
                    Button {
                        if viewModel.hydrationData.glassCount > 0 {
                            viewModel.hydrationData.glassCount -= 1
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
                    // Reset
                    Button {
                        viewModel.hydrationData.glassCount = 0
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

    // Progres w [0..1]
    private var waveProgress: CGFloat {
        let total = viewModel.hydrationData.dailyLimit
        let current = Double(viewModel.hydrationData.glassCount) * viewModel.hydrationData.glassVolume
        return total > 0 ? CGFloat(current / total) : 0
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




