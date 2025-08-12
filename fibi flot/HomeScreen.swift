import SwiftUI
@available(iOS 15.0,*)
struct HomeScreen: View {
    @State private var selectedColor = Color.pink
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAnimating = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(.orange)
                    .padding(8)
                }
                .padding(.leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
                ZStack {
                    AnimatedGradientView()
                        .ignoresSafeArea()
                        .overlay(
                            Circle()
                                .fill(selectedColor.opacity(0.1))
                                .blur(radius: 100)
                                .offset(x: isAnimating ? -50 : 50, y: isAnimating ? -50 : 50)
                                .animation(.easeInOut(duration: 5).repeatForever(), value: isAnimating)
                        )
                        .onAppear { isAnimating = true }
                    
                    ScrollView(.vertical,showsIndicators: false){
                        VStack(spacing: 20) {
                            // Color Preview with tap to copy
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedColor)
                                .padding(.trailing,6)
                                .padding(.leading,6)
                                .frame(height: 200)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .overlay(
                                    Text("Tap to Copy HEX")
                                        .font(.caption)
                                        .padding(8)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                        .opacity(0.8)
                                )
                                .onTapGesture { copyToClipboard(text: selectedColor.toHex()) }
                            
                            // Color Details Cards
                            VStack(spacing: 12) {
                                ColorDetailCard(title: "HEX", value: selectedColor.toHex())
                                ColorDetailCard(title: "RGB", value: selectedColor.toRGB())
                                ColorDetailCard(title: "HSV", value: selectedColor.toHSV())
                                ColorDetailCard(title: "CMYK", value: selectedColor.toCMYK())
                            }
                            .padding(.horizontal)
                            
                            // Action Buttons
                            HStack(spacing: 15) {
                                ActionButton(icon: "doc.on.doc", label: "Copy", action: { copyToClipboard(text: selectedColor.toHex()) })
                                ActionButton(icon: "square.and.arrow.up", label: "Share", action: shareColor)
                                ActionButton(icon: "photo", label: "Save", action: saveToGallery)
                            }
                            .padding(.top, 10)
                            
                            Spacer()
                            
                            // Navigation Buttons
                            VStack(spacing: 12) {
                                NavigationLink {
                                    ColorPickerScreen(selectedColor: $selectedColor)
                                        .navigationBarBackButtonHidden(true)
                                }
                                
                                label: {
                                    HStack {
                                        Image(systemName: "eyedropper")
                                        Text("Color Picker")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                                NavigationLink {
                                    SavedColorsScreen()
                                        .navigationBarBackButtonHidden(true)
                                } label: {
                                    HStack {
                                        Image(systemName: "list.star")
                                        Text("Saved Colors")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedColor)
                            .padding(.horizontal)
                            
                        }
//                        .navigationBarBackButtonHidden(true)
//                        .navigationBarHidden(true)
                        .padding(.vertical)}
                }
                
                .navigationTitle("Color Explorer")
                .padding(.top,30)
                
                .alert("Copied!", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }
                
            
            
        }
    }
    
    // MARK: - Functions
    
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        alertMessage = "\(text) copied to clipboard"
        showAlert = true
    }
    
    private func shareColor() {
        let image = selectedColor.snapshot()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap { $0 as? UIWindowScene }?
            .windows
            .first?
            .rootViewController?
            .present(activityVC, animated: true)
    }
    
    private func saveToGallery() {
        let image = selectedColor.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Color saved to Photos"
        showAlert = true
    }
}

// MARK: - Subviews
@available(iOS 15.0,*)
struct ColorDetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
            
            Spacer()
            
            Button {
                UIPasteboard.general.string = value
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption)
            }
            .frame(width: 70, height: 60)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Extensions

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    func toRGB() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "R: \(Int(r * 255)), G: \(Int(g * 255)), B: \(Int(b * 255))"
    }
    
    func toHSV() -> String {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        return "H: \(Int(h * 360))°, S: \(Int(s * 100))%, V: \(Int(v * 100))%"
    }
    
    func toCMYK() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let k = 1 - max(r, g, b)
        let c = (1 - r - k) / (1 - k)
        let m = (1 - g - k) / (1 - k)
        let y = (1 - b - k) / (1 - k)
        
        return "C: \(Int(c * 100))%, M: \(Int(m * 100))%, Y: \(Int(y * 100))%, K: \(Int(k * 100))%"
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = CGSize(width: 300, height: 300)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Preview
@available(iOS 15.0,*)
#Preview {
    HomeScreen()
}
