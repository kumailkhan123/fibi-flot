import SwiftUI
import AVFoundation
@available(iOS 15.0,*)
struct HSVToColorScreen: View {
    @State private var hue = "0"
    @State private var saturation = "100"
    @State private var value = "100"
    @State private var colorName = "Red"
    @State private var displayColor = Color.red
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack{
            AnimatedGradientView()
                .ignoresSafeArea()
        VStack(spacing: 20) {
            // Color Preview with Name
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(displayColor)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 5)
                
                Text(colorName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            
            // HSV Input Fields
            VStack(spacing: 15) {
                HStack {
                    Text("H:")
                    TextField("0-360", text: $hue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("S:")
                    TextField("0-100", text: $saturation)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("V:")
                    TextField("0-100", text: $value)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }
            .onChange(of: hue) { _ in validateAndUpdate() }
            .onChange(of: saturation) { _ in validateAndUpdate() }
            .onChange(of: value) { _ in validateAndUpdate() }
            
            // Speak Button
            Button(action: speakColorName) {
                Label("Speak Color Name", systemImage: "speaker.wave.2.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            // Action Buttons
            HStack(spacing: 15) {
              
                
                Button(action: shareColor) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                
                Button(action: clearAll) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Button(action: takeScreenshot) {
                    Image(systemName: "camera.viewfinder")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle("HSV to Color")
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            updateColorFromHSV()
        }
    }
    }
    
    private func validateAndUpdate() {
        // Validate Hue (0-360)
        if let h = Int(hue), h >= 0, h <= 360 {
            // Valid
        } else {
            hue = hue.filter { $0.isNumber }
            if let num = Int(hue), num > 360 {
                hue = "360"
            } else if hue.isEmpty {
                hue = "0"
            }
        }
        
        // Validate Saturation/Value (0-100)
        [saturation, value].forEach { val in
            if let num = Int(val), num >= 0, num <= 100 {
                // Valid
            } else {
                if val.filter({ $0.isNumber }).isEmpty {
                    if val == saturation { saturation = "0" }
                    if val == value { value = "0" }
                } else if let num = Int(val), num > 100 {
                    if val == saturation { saturation = "100" }
                    if val == value { value = "100" }
                }
            }
        }
        
        updateColorFromHSV()
    }
    
    private func updateColorFromHSV() {
        guard let h = Double(hue),
              let s = Double(saturation),
              let v = Double(value) else {
            displayColor = .gray
            colorName = "Invalid HSV"
            return
        }
        
        let normalizedH = h / 360.0
        let normalizedS = s / 100.0
        let normalizedV = v / 100.0
        
        displayColor = Color(hue: normalizedH, saturation: normalizedS, brightness: normalizedV)
        colorName = getColorName(h: h, s: s, v: v)
    }
    
    private func getColorName(h: Double, s: Double, v: Double) -> String {
        // Basic color names based on HSV ranges
        if v < 0.2 { return "Black" }
        if s < 0.1 { return v > 0.9 ? "White" : "Gray" }
        
        switch h {
        case 0..<15: return "Red"
        case 15..<45: return "Orange"
        case 45..<75: return "Yellow"
        case 75..<150: return "Green"
        case 150..<195: return "Cyan"
        case 195..<255: return "Blue"
        case 255..<285: return "Purple"
        case 285..<330: return "Pink"
        case 330..<360: return "Red"
        default: return "Color"
        }
    }
    
    private func speakColorName() {
        let utterance = AVSpeechUtterance(string: colorName)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    
    private func copyHSV() {
        UIPasteboard.general.string = "H: \(hue)°, S: \(saturation)%, V: \(value)%"
        showAlert(message: "HSV values copied!")
    }
    
    private func shareColor() {
        let items = ["HSV Color\nH: \(hue)°\nS: \(saturation)%\nV: \(value)%\nColor: \(colorName)", displayColor] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func clearAll() {
        hue = "0"
        saturation = "100"
        value = "100"
        updateColorFromHSV()
    }
    
    private func takeScreenshot() {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showAlert(message: "Screenshot saved to photos!")
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}
@available(iOS 15.0,*)
#Preview {
    NavigationView {
        HSVToColorScreen()
    }
}
@available(iOS 15.0, *)
struct AnimatedGradientView: View {
    @State private var gradientStart = UnitPoint(x: 1, y: 0)
    @State private var gradientEnd = UnitPoint(x: 0, y: 1)
    
    let colors: [Color] = [.jk.opacity(0.4), .kl.opacity(0.4), .green.opacity(0.5), .orange.opacity(0.6), .purple.opacity(0.6), .cyan.opacity(0.7).opacity(0.3)]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: gradientStart,
            endPoint: gradientEnd
        )
        .animation(
            Animation.easeInOut(duration: 8)
                .repeatForever(autoreverses: true),
            value: gradientStart
        )
        .onAppear {
            gradientStart = UnitPoint(x: 2, y: 3)
            gradientEnd = UnitPoint(x: 2, y: 2)
        }
    }
}
