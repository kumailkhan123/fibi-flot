import SwiftUI
@available(iOS 15.0,*)
struct SavedColorsScreen: View {
    @State private var savedColors: [SavedColor] = []
    @State private var selectedColor: Color?
    
    @State private var showDeleteAlert = false
    @State private var colorToDelete: SavedColor?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            
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
                            
                        
                Text("Saved Colors")
                    .padding(.leading,70)
                    
                Spacer()
                        }
                        .frame(maxWidth: .infinity)
            
            Spacer()
            ZStack{
                AnimatedGradientView()
                    .ignoresSafeArea()
                NavigationView {
                    Group {
                        if savedColors.isEmpty {
                            emptyStateView
                        } else {
                            colorGrid
                        }
                    }
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
                }
                .alert("Delete Color", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        if let color = colorToDelete {
                            deleteColor(color)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete this color?")
                }
                .onAppear {
                    loadColors()
                }
                .sheet(item: $selectedColor) { color in
                    ColorDetailScreen(color: color)
                }
            }
        }
       // ... rest of your implementation remains the same ...
   }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Saved Colors")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Save colors from the Color Picker to see them here")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var colorGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100)), GridItem(.adaptive(minimum: 100))], spacing: 16) {
                ForEach(savedColors) { savedColor in
                    ColorGridItem(color: savedColor.color, hex: savedColor.hexCode)
                        .contextMenu {
                            Button {
                                selectedColor = savedColor.color
                            } label: {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button {
                                UIPasteboard.general.string = savedColor.hexCode
                            } label: {
                                Label("Copy HEX", systemImage: "doc.on.doc")
                            }
                            
                            if #available(iOS 15.0, *) {
                                Button(role: .destructive) {
                                    colorToDelete = savedColor
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        .onTapGesture {
                            selectedColor = savedColor.color
                        }
                }
            }
            .padding()
        }
    }
    
     func loadColors() {
        // Load from UserDefaults or CoreData
        // Sample data for demonstration
        if #available(iOS 15.0, *) {
            savedColors = [
                SavedColor(color: .mint, hexCode: "#3EB489"),
                SavedColor(color: .indigo, hexCode: "#4B0082"),
                SavedColor(color: .teal, hexCode: "#008080"),
                SavedColor(color: .brown, hexCode: "#A52A2A"),
                SavedColor(color: .gray, hexCode: "#808080"),
               
                SavedColor(color: .white, hexCode: "#FFFFFF"),
                SavedColor(color: .primary, hexCode: "#000000"),    
                SavedColor(color: .secondary, hexCode: "#6C757D"),
                SavedColor(color: .accentColor, hexCode: "#007AFF"),
            
                SavedColor(color: .red.opacity(0.5), hexCode: "#FF000080"),
                SavedColor(color: .blue.opacity(0.7), hexCode: "#0000FFB3"),
                SavedColor(color: .green.opacity(0.6), hexCode: "#00FF0099"),
                SavedColor(color: .orange.opacity(0.4), hexCode: "#FFA50066"),
                SavedColor(color: .yellow.opacity(0.8), hexCode: "#FFFF00CC"),
                SavedColor(color: .purple.opacity(0.3), hexCode: "#8000804D"),
                SavedColor(color: .pink.opacity(0.9), hexCode: "#FFC0CBE6"),
                SavedColor(color: .cyan.opacity(0.2), hexCode: "#00FFFF33"),
                SavedColor(color: .gray.opacity(0.1), hexCode: "#8080801A")
            ]
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func deleteColor(_ color: SavedColor) {
        withAnimation {
            savedColors.removeAll { $0.id == color.id }
        }
    }
}

struct ColorGridItem: View {
    let color: Color
    let hex: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
            
            Text(hex)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
}

@available(iOS 15.0, *)
struct ColorDetailScreen: View {
    let color: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 20) {
                    // Color Preview
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color)
                        .frame(height: 200)
                        .shadow(radius: 10)
                    
                    // Color Details
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(title: "HEX", value: color.toHex())
                        DetailRow(title: "RGB", value: color.toRGB())
                        DetailRow(title: "HSV", value: color.toHSV())
                        DetailRow(title: "CMYK", value: color.toCMYK())
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack(spacing: 15) {
                        ActionButton1(icon: "doc.on.doc", label: "Copy", action: {
                            UIPasteboard.general.string = color.toHex()
                        })
                        
                        ActionButton1(icon: "square.and.arrow.up", label: "Share", action: {
                            shareColor()
                        })
                    }
                }
                .padding()
                .navigationTitle("Color Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func shareColor() {
        let image = color.snapshot()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            if #available(iOS 15.0, *) {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
            } else {
                // Fallback on earlier versions
            }
            
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

struct SavedColor: Identifiable {
    let id = UUID()
    let color: Color
    let hexCode: String
}

struct ActionButton1: View {
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
            .frame(width: 100, height: 60)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(.plain)
    }
}

extension Color: Identifiable {
    public var id: String {
        self.toHex()
    }
}
@available(iOS 15.0,*)
#Preview{
    SavedColorsScreen()
}
