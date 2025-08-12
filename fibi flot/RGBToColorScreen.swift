import SwiftUI
import AVFoundation
@available(iOS 15.0,*)
struct RGBToColorScreen: View {
    @State private var red = "255"
    @State private var green = "87"
    @State private var blue = "51"
    @State private var color = Color.orange
    @State private var colorName = "Orange"
    @State private var isSpeaking = false
    @State private var showAlert = false
    @State private var isPulsing = false
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            AnimatedGradientView()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Color Preview with Pulsing Animation
                colorPreview
                
                // Color Name with Speaker Button
                colorNameSection
                
                // RGB Input Fields
                rgbInputSection
                
                // Action Buttons
                actionButtons
                
                Spacer()
            }
            .padding()
            .navigationTitle("RGB to Color")
            .alert("Invalid RGB", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter values between 0-255 for R, G, and B")
            }
        }
    }
    
    // MARK: - Components
    
    private var colorPreview: some View {
        Circle()
            .fill(color)
            .frame(width: 200, height: 200)
            .shadow(color: color.opacity(0.5), radius: 16, x: 0, y: 8)
            .overlay(
                Text("R:\(red) G:\(green) B:\(blue)")
                    .font(.system(.title3, design: .monospaced).bold())
                    .foregroundColor(color.isDark ? .white : .black)
                    .padding(12)
                    .background(Color(.systemBackground).opacity(0.7))
                    .cornerRadius(12)
            )
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(), value: isPulsing)
            .onAppear { isPulsing = true }
    }
    
    private var colorNameSection: some View {
        HStack(spacing: 12) {
            Text(colorName)
                .font(.title2)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Button(action: speakColorName) {
                Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .font(.title2)
                    .padding(8)
                    .background(Color(.systemFill))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private var rgbInputSection: some View {
        VStack(spacing: 12) {
            Text("RGB Values (0-255)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                rgbInputField(value: $red, label: "R")
                rgbInputField(value: $green, label: "G")
                rgbInputField(value: $blue, label: "B")
            }
            
            Button(action: updateColor) {
                Label("Convert", systemImage: "arrow.clockwise.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    private func rgbInputField(value: Binding<String>, label: String) -> some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("", text: value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
                .onChange(of: value.wrappedValue) { _ in
                    validateInput(value: value)
                }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            actionButton(icon: "doc.on.doc", label: "Copy", action: copyRGB)
            actionButton(icon: "square.and.arrow.up", label: "Share", action: shareColor)
            actionButton(icon: "camera.fill", label: "Capture", action: takeScreenshot)
        }
    }
    
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption)
            }
            .frame(width: 72, height: 60)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Functions
    
    private func validateInput(value: Binding<String>) {
        // Remove non-numeric characters
        let filtered = value.wrappedValue.filter { $0.isNumber }
        if filtered != value.wrappedValue {
            value.wrappedValue = filtered
        }
        
        // Limit to 3 digits
        if value.wrappedValue.count > 3 {
            value.wrappedValue = String(value.wrappedValue.prefix(3))
        }
    }
    
    private func updateColor() {
        guard let r = Int(red),
              let g = Int(green),
              let b = Int(blue),
              (0...255).contains(r),
              (0...255).contains(g),
              (0...255).contains(b) else {
            showAlert = true
            return
        }
        
        withAnimation(.spring()) {
            color = Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
            colorName = color.closestColorName()
        }
    }
    
    private func pasteRGB() {
        if let clipboard = UIPasteboard.general.string {
            let components = clipboard.components(separatedBy: CharacterSet(charactersIn: ", "))
                .filter { !$0.isEmpty }
            
            if components.count == 3,
               let r = Int(components[0]),
               let g = Int(components[1]),
               let b = Int(components[2]),
               (0...255).contains(r),
               (0...255).contains(g),
               (0...255).contains(b) {
                red = String(r)
                green = String(g)
                blue = String(b)
                updateColor()
            }
        }
    }
    
    private func copyRGB() {
        UIPasteboard.general.string = "\(red), \(green), \(blue)"
        
        // Visual feedback
        withAnimation { isPulsing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { isPulsing = false }
        }
    }
    
    private func shareColor() {
        let rgbString = "R:\(red) G:\(green) B:\(blue)\nColor: \(colorName)"
        let image = color.snapshot()
        
        let activityVC = UIActivityViewController(activityItems: [rgbString, image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func takeScreenshot() {
        let image = color.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // Visual feedback
        withAnimation { isPulsing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { isPulsing = false }
        }
    }
    
    private func speakColorName() {
        if isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: "The color is \(colorName)")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            
            speechSynthesizer.speak(utterance)
            isSpeaking = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(utterance.speechString.count) * 0.1) {
                isSpeaking = false
            }
        }
    }
}
@available(iOS 15.0,*)
#Preview{
    RGBToColorScreen()
}
// MARK: - Extensions

extension Color {
    var sDark: Bool {
        let uiColor = UIColor(self)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white < 0.5
    }
    
    func closestColorName() -> String {
        let uiColor = UIColor(self)
        return uiColor.closestColorName()
    }
    
    
    
    
    // MARK: - Preview
    @available(iOS 15.0,*)
    struct RGBToColorScreen_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                RGBToColorScreen()
            }
        }
    }

        func closestColorName1() -> String {
            let colorMap: [String: UIColor] = [
                "Red": .red,
                "Green": .green,
                "Blue": .blue,
                "Yellow": .yellow,
                "Orange": .orange,
                "Purple": .purple,
                "Pink": .systemPink,
                "Brown": .brown,
                "Gray": .gray,
                "Black": .black,
                "White": .white,
                "Cyan": .cyan,
                "Magenta": .magenta,
                "Teal": .systemTeal,
                "Indigo": .systemIndigo,
                "Lime": UIColor(red: 0, green: 1, blue: 0, alpha: 1),
                "Maroon": UIColor(red: 0.5, green: 0, blue: 0, alpha: 1),
                "Olive": UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1),
                "Navy": UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
            ]
            
            var closestName = "Unknown"
            var minDistance = CGFloat.greatestFiniteMagnitude
            
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            
            for (name, color) in colorMap {
                var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
                color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
                
                let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
                
                if distance < minDistance {
                    minDistance = distance
                    closestName = name
                }
            }
            
            return closestName
        }
        
    }
extension Color {
    var isDark: Bool {
        let uiColor = UIColor(self)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white < 0.5
    }
    
    var rgbString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) else {
            return "Invalid RGB values"
        }
        return "R: \(clampAndConvert(r)), G: \(clampAndConvert(g)), B: \(clampAndConvert(b))"
    }
    
    var hsvString: String {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0
        guard uiColor.getHue(&h, saturation: &s, brightness: &v, alpha: nil) else {
            return "Invalid HSV values"
        }
        return "H: \(clampAndConvert(h * 360))°, S: \(clampAndConvert(s * 100))%, V: \(clampAndConvert(v * 100))%"
    }
    
    var cmykString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: nil) else {
            return "Invalid CMYK values"
        }
        
        // Handle potential division by zero
        let k = 1 - max(r, g, b)
        guard k != 1 else { // Avoid division by zero
            return "C: 0%, M: 0%, Y: 0%, K: 100%"
        }
        
        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)
        
        return "C: \(clampAndConvert(c * 100))%, M: \(clampAndConvert(m * 100))%, Y: \(clampAndConvert(y * 100))%, K: \(clampAndConvert(k * 100))%"
    }
    
    private func clampAndConvert(_ value: CGFloat) -> Int {
        let clamped = min(max(value, 0), 1) // Clamp between 0 and 1
        return Int(round(clamped * 255))
    }
    
    private func clampAndConvertPercent(_ value: CGFloat) -> Int {
        let clamped = min(max(value, 0), 100) // Clamp between 0% and 100%
        return Int(round(clamped))
    }
}
