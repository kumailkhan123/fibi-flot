import SwiftUI
@available(iOS 15.0,*)
struct ColorPickerScreen: View {
    @Binding var selectedColor: Color
    @State private var red: Double = 0.5
    @State private var green: Double = 0.5
    @State private var blue: Double = 0.5
    @State private var hue: Double = 0.5
    @State private var saturation: Double = 1.0
    @State private var brightness: Double = 1.0
    @State private var selectedTab = 0
    @State private var isDragging = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                               Button(action: { dismiss() }) {
                                   HStack(spacing: 4) {
                                       Image(systemName: "chevron.left")
                                           .font(.system(size: 17, weight: .semibold))
                                       Text("Back")
                                   }
                                   .foregroundColor(selectedColor.isLight ? .black : .orange)
                                   .padding(8)
                                   .background(selectedColor.isLight ? Color.black.opacity(0.1) : Color.white.opacity(0.2))
                                   .clipShape(Capsule())
                               }
                               .padding(.leading)
                               
                               Spacer()
                           }
                           .frame(maxWidth: .infinity)
                           
                           Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedColor)
                    .frame(height: 200)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                VStack {
                    
                    Text(selectedColor.toHex())
                        .font(.system(.title, design: .monospaced).bold())
                        .foregroundColor(selectedColor.isLight ? .black : .white)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                
                    
                    Text("Tap to Copy")
                        .font(.caption)
                        .foregroundColor(selectedColor.isLight ? .black.opacity(0.7) : .white.opacity(0.7))
                }
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            
            .padding()
            .onTapGesture {
                UIPasteboard.general.string = selectedColor.toHex()
            }
            
            // Tab Selector
            Picker("Mode", selection: $selectedTab) {
                Text("RGB").tag(0)
                Text("HSB").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Color Controls
            ScrollView {
                if selectedTab == 0 {
                    RGBControls(red: $red, green: $green, blue: $blue)
                } else {
                    HSBControls(hue: $hue, saturation: $saturation, brightness: $brightness)
                }
            }
            
            // Action Buttons
            HStack(spacing: 15) {
                Button(action: randomizeColor) {
                    if #available(iOS 15.0, *) {
                        Image(systemName: "dice")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                
                if #available(iOS 15.0, *) {
                    Button(action: saveColor) {
                        Text("Save Color")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    // Fallback on earlier versions
                }
            }
            .padding()
        }
        .onChange(of: red) { _ in updateColor() }
        .onChange(of: green) { _ in updateColor() }
        .onChange(of: blue) { _ in updateColor() }
        .onChange(of: hue) { _ in updateColor() }
        .onChange(of: saturation) { _ in updateColor() }
        .onChange(of: brightness) { _ in updateColor() }
        .onAppear {
            setInitialValues()
        }
        .navigationTitle("Color Picker")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setInitialValues() {
        let uiColor = UIColor(selectedColor)
        
        // Set RGB values
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        red = Double(r)
        green = Double(g)
        blue = Double(b)
        
        // Set HSB values
        var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &br, alpha: nil)
        hue = Double(h)
        saturation = Double(s)
        brightness = Double(br)
    }
    
    private func updateColor() {
        if selectedTab == 0 {
            selectedColor = Color(red: red, green: green, blue: blue)
            
            // Update HSB values to match
            let uiColor = UIColor(selectedColor)
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
            uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: nil)
            hue = Double(h)
            saturation = Double(s)
            brightness = Double(b)
        } else {
            selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
            
            // Update RGB values to match
            let uiColor = UIColor(selectedColor)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
            red = Double(r)
            green = Double(g)
            blue = Double(b)
        }
    }
    
    private func randomizeColor() {
        withAnimation(.spring()) {
            if selectedTab == 0 {
                red = Double.random(in: 0...1)
                green = Double.random(in: 0...1)
                blue = Double.random(in: 0...1)
            } else {
                hue = Double.random(in: 0...1)
                saturation = Double.random(in: 0.7...1)
                brightness = Double.random(in: 0.7...1)
            }
        }
    }
    
    private func saveColor() {
        // Save to UserDefaults or CoreData
        // You'll need to implement your storage mechanism
        print("Color saved: \(selectedColor.toHex())")
    }
}

struct RGBControls: View {
    @Binding var red: Double
    @Binding var green: Double
    @Binding var blue: Double
    
    var body: some View {
        VStack(spacing: 20) {
            ColorSlider(value: $red, accentColor: .red, label: "Red")
            ColorSlider(value: $green, accentColor: .green, label: "Green")
            ColorSlider(value: $blue, accentColor: .blue, label: "Blue")
        }
        .padding()
    }
}

struct HSBControls: View {
    @Binding var hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double
    
    var body: some View {
        VStack(spacing: 20) {
            HueSlider(value: $hue)
            ColorSlider(value: $saturation, accentColor: .white, label: "Saturation")
            ColorSlider(value: $brightness, accentColor: .gray, label: "Brightness")
        }
        .padding()
    }
}

struct ColorSlider: View {
    @Binding var value: Double
    var accentColor: Color
    var label: String
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .font(.headline)
                    .frame(width: 80, alignment: .leading)
                
                Text("\(Int(value * 255))")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 40)
                
                Slider(value: $value, in: 0...1) { editing in
                    isEditing = editing
                }
                .foregroundColor(accentColor)
            }
        }
    }
}

struct HueSlider: View {
    @Binding var value: Double
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Hue")
                    .font(.headline)
                    .frame(width: 80, alignment: .leading)
                
                Text("\(Int(value * 360))°")
                    .font(.system(.body, design: .monospaced))
                    .frame(width: 40)
                
                GradientSlider(value: $value, range: 0...1) { editing in
                    isEditing = editing
                }
            }
        }
    }
}

struct GradientSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var onEditingChanged: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if #available(iOS 15.0, *) {
                    AnimatedGradientView()
                        .ignoresSafeArea()
                } else {
                    // Fallback on earlier versions
                }
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .red, .orange, .yellow, .green,
                                .blue, .purple, .pink, .red
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Thumb
                Circle()
                    .fill(Color(hue: value, saturation: 1, brightness: 1))
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: CGFloat(value) * geometry.size.width - 12)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                let newValue = min(max(0, Double(gesture.location.x / geometry.size.width)), 1)
                                value = newValue
                                onEditingChanged(true)
                            }
                            .onEnded { _ in
                                onEditingChanged(false)
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}

extension Color {
    var isLight: Bool {
        guard let components = UIColor(self).cgColor.components else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return brightness > 0.5
    }
}
