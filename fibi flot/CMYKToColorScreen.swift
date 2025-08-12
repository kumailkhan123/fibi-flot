import SwiftUI
import AVFoundation
@available(iOS 15.0,*)
struct CMYKToColorScreen: View {
    @State private var cyan = "0"
    @State private var magenta = "66"
    @State private var yellow = "80"
    @State private var black = "0"
    @State private var color = Color.orange
    @State private var colorName = "Orange"
    @State private var isSpeaking = false
    @State private var showAlert = false
    @State private var isPulsing = false
    @State private var showColorDetails = false
    
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
                
                // CMYK Input Fields
                cmykInputSection
                
                // Action Buttons
                actionButtons
                
                // Color Details Section
                colorDetailsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("CMYK to Color")
            .alert("Invalid CMYK", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter values between 0-100 for C, M, Y, and K")
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
                Text("C:\(cyan) M:\(magenta) Y:\(yellow) K:\(black)")
                    .font(.system(.title3, design: .monospaced).bold())
                    .foregroundColor(color.isDark1 ? .white : .black)
                    .padding(12)
                    .background(Color(.systemBackground).opacity(0.7))
                    .cornerRadius(12)
            )
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(), value: isPulsing)
            .onTapGesture { takeScreenshot() }
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
    
    private var cmykInputSection: some View {
        VStack(spacing: 12) {
            Text("CMYK Values (0-100)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                cmykInputField(value: $cyan, label: "C")
                cmykInputField(value: $magenta, label: "M")
                cmykInputField(value: $yellow, label: "Y")
                cmykInputField(value: $black, label: "K")
            }
            
            Button(action: updateColor) {
                Label("Convert", systemImage: "arrow.clockwise.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    private func cmykInputField(value: Binding<String>, label: String) -> some View {
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
            actionButton(icon: "doc.on.doc", label: "Copy", action: copyCMYK)
            actionButton(icon: "square.and.arrow.up", label: "Share", action: shareColor)
            actionButton(icon: "camera.fill", label: "Capture", action: takeScreenshot)
        }
    }
    
    private var colorDetailsSection: some View {
        DisclosureGroup("Color Details", isExpanded: $showColorDetails) {
            VStack(spacing: 12) {
                DetailRow3(title: "RGB", value: color.rgbString3)
                DetailRow3(title: "HEX", value: color.hexString)
                DetailRow3(title: "HSV", value: color.hsvString3)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
        guard let c = Double(cyan),
              let m = Double(magenta),
              let y = Double(yellow),
              let k = Double(black),
              (0...100).contains(c),
              (0...100).contains(m),
              (0...100).contains(y),
              (0...100).contains(k) else {
            showAlert = true
            return
        }
        
        // Convert CMYK to RGB (0-1)
        let cNormalized = c / 100.0
        let mNormalized = m / 100.0
        let yNormalized = y / 100.0
        let kNormalized = k / 100.0
        
        let r = (1 - cNormalized) * (1 - kNormalized)
        let g = (1 - mNormalized) * (1 - kNormalized)
        let b = (1 - yNormalized) * (1 - kNormalized)
        
        withAnimation(.spring()) {
            color = Color(red: r, green: g, blue: b)
            colorName = color.closestColorName3()
        }
    }
    
    private func pasteCMYK() {
        if let clipboard = UIPasteboard.general.string {
            let components = clipboard.components(separatedBy: CharacterSet(charactersIn: ", "))
                .filter { !$0.isEmpty }
            
            if components.count == 4,
               let c = Int(components[0]),
               let m = Int(components[1]),
               let y = Int(components[2]),
               let k = Int(components[3]),
               (0...100).contains(c),
               (0...100).contains(m),
               (0...100).contains(y),
               (0...100).contains(k) {
                cyan = String(c)
                magenta = String(m)
                yellow = String(y)
                black = String(k)
                updateColor()
            }
        }
    }
    
    private func copyCMYK() {
        UIPasteboard.general.string = "\(cyan), \(magenta), \(yellow), \(black)"
        
        // Visual feedback
        withAnimation { isPulsing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { isPulsing = false }
        }
    }
    
    private func shareColor() {
        let cmykString = "C:\(cyan) M:\(magenta) Y:\(yellow) K:\(black)\nColor: \(colorName)"
        let image = color.snapshot()
        
        let activityVC = UIActivityViewController(activityItems: [cmykString, image], applicationActivities: nil)
        
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

// MARK: - Helper Views

struct DetailRow3: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }
}

// MARK: - Extensions

extension Color {
    var isDark1: Bool {
        let uiColor = UIColor(self)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white < 0.5
    }
    
    var rgbString3: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        return "\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255))"
    }
    
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    var hsvString3: String {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return "H: \(Int(h * 360))°, S: \(Int(s * 100))%, V: \(Int(v * 100))%"
    }
    
    func closestColorName3() -> String {
        let uiColor = UIColor(self)
        return uiColor.closestColorName()
    }
}
    
    @available(iOS 15.0,*)
    
    struct CMYKToColorScreen_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                CMYKToColorScreen()
            }
        }
    }
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func closestColorName() -> String {
        let colorNames: [String: UIColor] = [
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
            "Indigo": .systemIndigo,
            "Teal": .systemTeal,
            "Lime": .systemGreen,
            "Maroon": UIColor(red: 0.5, green: 0, blue: 0, alpha: 1),
            "Olive": UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1),
            "Navy": UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
        ]
        
        var closestName = "Unknown"
        var closestDistance = CGFloat.greatestFiniteMagnitude
        
        for (name, namedColor) in colorNames {
            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            
            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
            namedColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
            
            let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
            
            if distance < closestDistance {
                closestDistance = distance
                closestName = name
            }
        }
        
        return closestName
    }
}
