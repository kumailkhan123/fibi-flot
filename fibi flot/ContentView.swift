import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct CalculatorItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    
    
    var destinationView: some View {
        Group {
            switch name {
            case "Home Screen":
                HomeScreen()
            case "RGB To Color Screen":
                RGBToColorScreen()
            case "HSV To Color Screen":
                HSVToColorScreen()
            case "CMYK To Color Screen":
                CMYKToColorScreen()
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Main Content View
@available(iOS 15.0, *)
struct ContentView: View {
    let calculators: [CalculatorItem] = [
        CalculatorItem(name: "Home Screen", icon: "ruler"),
        CalculatorItem(name: "RGB To Color Screen", icon: "thermometer"),
        CalculatorItem(name: "HSV To Color Screen", icon: "moon"),
        CalculatorItem(name: "CMYK To Color Screen", icon: "hamer"),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                LinearGradient(colors: [.orange.opacity(0.3), .green.opacity(0.5), .yellow.opacity(0.5)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 32) {
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 70) {
                            ForEach(calculators) { item in
                                NavigationLink {
                                    if item.name == "Home Screen" {
                                        HomeScreen()
                                            .navigationBarHidden(true)
                                    } else {
                                        item.destinationView
                                            .navigationTitle(item.name)
                                            .navigationBarTitleDisplayMode(.inline)
                                    }
                                } label: {
                                    CalculatorButtonView(item: item)
                                }
                            }
                        }
                        .padding(.top, 70)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 70)
                    }
                }
                .foregroundColor(.white)
            }
        }
        .navigationBarColor(backgroundColor: .brown, textColor: .systemPink)
    }
    
    private var headerView: some View {
        VStack(spacing: 6) {
            LinearGradient(colors: [.teal.opacity(0.8), .indigo.opacity(0.8), .red.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .mask(
                Text("Fibi Flot")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
            )
            .frame(height: 50)
            
            Text("")
                .font(.footnote)
                .foregroundColor(.indigo.opacity(0.85))
        }
        .padding(.top)
    }
}

// MARK: - Calculator Button View
@available(iOS 15.0, *)
struct CalculatorButtonView: View {
    let item: CalculatorItem
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.custom("times", size: 15).bold())
                    .foregroundColor(.black)
                    .padding(.leading,140)
                
            }
            .padding(.leading,-40)
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.black.opacity(0.9))
                .padding()
        }
        .frame(height:70)
        
        .padding(16)
        .background(
            ZStack {
                Image("qa")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(0.9)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
                .shadow(color: .black.opacity(8.9), radius: 8, x: 3, y: 2)
        )
    }
}

@available(iOS 15.0,*)
struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            
            LinearGradient(colors: [.teal.opacity(0.8), .indigo.opacity(0.8), .red.opacity(0.9)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            
            Image("")
                .resizable()
                .ignoresSafeArea()
                .opacity(0.2)
            
            content
        }
    }
}
@available(iOS 15.0,*)
extension View {
    func withAppBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
    
    func navigationBarColor(backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
}

// MARK: - Navigation Bar Modifier
struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: textColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        
        let backImage = UIImage(systemName: "chevron.left")?
            .withTintColor(textColor, renderingMode: .alwaysOriginal)
        
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = textColor
    }
    
    func body(content: Content) -> some View {
        content
    }
}

// MARK: - Previews
@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
