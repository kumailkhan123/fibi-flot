# 🎨 Fibi Flot - Color Utility App

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.5-orange?style=for-the-badge&logo=swift" alt="Swift Version">
  <img src="https://img.shields.io/badge/iOS-15%2B-blue?style=for-the-badge&logo=apple" alt="iOS Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/github/stars/kumailkhan123/Fibi-Flot?style=for-the-badge&color=yellow" alt="GitHub Stars">
</p>

<p align="center">
  A sleek and powerful ✨ iOS application designed for developers, designers, and artists to easily identify, convert, and manage color codes on the go.
</p>

<p align="center">
  <img src="https://github.com/kumailkhan123/fibi-flot/blob/main/15/Simulator%20Screenshot%20-%2015%20-%202025-07-18%20at%2013.34.49.png" width="200" alt="App Screenshot 1">
  <img src="https://github.com/kumailkhan123/fibi-flot/blob/main/15/Simulator%20Screenshot%20-%2015%20-%202025-07-18%20at%2013.35.30.png" width="200" alt="App Screenshot 2">
  <img src="https://github.com/kumailkhan123/fibi-flot/blob/main/15/Simulator%20Screenshot%20-%2015%20-%202025-07-18%20at%2013.35.37.png " width="200" alt="App Screenshot 3">
</p>

---

## ✨ Features

### 🎯 Core Features
- 🖌️ **Real-Time Color Picker** – Capture any color on your screen instantly with pixel-perfect accuracy
- 🔄 **Multi-Format Support** – Convert colors between all major professional formats
- 📋 **One-Tap Copy** – Instantly copy color codes to your clipboard
- 💾 **Smart Color Saving** – Save and organize your favorite colors
- 🎨 **Beautiful Interface** – Modern, intuitive design with smooth animations

### 📊 Supported Color Formats
| Format | Example | Description |
| :--- | :--- | :--- |
| **HEX** | `#54FF95` | Standard web color format |
| **RGB** | `rgb(84, 255, 149)` | Red, Green, Blue values |
| **HSV/HSB** | `hsv(142°, 67%, 100%)` | Hue, Saturation, Value/Brightness |
| **CMYK** | `cmyk(67%, 0%, 42%, 0%)` | Cyan, Magenta, Yellow, Key (Black) |

---

## 🚀 Getting Started

### Prerequisites

- 🛠️ **Xcode 13.0** or newer
- 📱 **iOS 15+** compatible device or simulator
- ☕ **Basic Swift knowledge** (helpful for customization)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/kumailkhan123/Fibi-Flot.git
   cd Fibi-Flot
   ```

2. **Open in Xcode**
   ```bash
   open FibiFlot.xcodeproj
   ```

3. **Build and Run**
   - Select your target device (⌘ + R)
   - Wait for the build to complete
   - Start exploring colors! 🎉

---

## 📋 Usage Guide

### 🖱️ Basic Operations
1. **Pick a Color** – Use the color picker to select any color from your screen
2. **View Conversions** – See instant conversions across all color formats
3. **Copy Codes** – Tap any color value to copy it to clipboard
4. **Save Colors** – Star your favorite colors for quick access

### 🎨 Advanced Features
- **Color History** – automatically keeps track of recently used colors
- **Export Options** – Share colors via email, messages, or other apps
- **Custom Palettes** – Create and manage color collections
- **Accessibility** – Full VoiceOver support and high contrast mode

---

## 🛠️ Technical Architecture

```swift
// Example of color conversion function
func convertHexToRGB(hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
    // Implementation details...
    return (r: 0.33, g: 1.0, b: 0.58)
}
```

### 🏗️ Project Structure
```
Fibi-Flot/
├── Sources/
│   ├── Models/
│   │   ├── ColorModel.swift
│   │   └── ColorPalette.swift
│   ├── Views/
│   │   ├── ColorPickerView.swift
│   │   ├── ColorDetailView.swift
│   │   └── SavedColorsView.swift
│   ├── Utilities/
│   │   ├── ColorConverter.swift
│   │   └── ClipboardManager.swift
│   └── Extensions/
│       ├── Color+Extensions.swift
│       └── View+Extensions.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Preview Content/
└── Documentation/
```

---

## 👨‍💻 Developer

<div align="center">

### Kumail Abbas

[![GitHub](https://img.shields.io/badge/GitHub-@kumailkhan123-181717?style=flat&logo=github)](https://github.com/kumailkhan123)
[![Email](https://img.shields.io/badge/Email-kumailabbas3778%40gmail.com-D14836?style=flat&logo=gmail)](mailto:kumailabbas3778@gmail.com)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Kumail_Abbas-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/your-profile)

**iOS Developer & Color Enthusiast**  
*Passionate about creating tools that make developers' lives easier*

</div>

---

## 🤝 Contributing

We love contributions! Here's how you can help:

1. 🍴 **Fork** the project
2. 🌿 **Create** a feature branch (`git checkout -b amazing-feature`)
3. 💾 **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. 📤 **Push** to the branch (`git push origin amazing-feature`)
5. 🔃 **Open** a Pull Request

### 🐛 Found a Bug?
Please open an issue with:
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if possible

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```text
MIT License

Copyright (c) 2025 Kumail Abbas

Permission is hereby granted... (see LICENSE file for full text)
```

---

## ⭐ Support the Project

If you find this project helpful:

1. **Give it a Star** ⭐ - It helps others discover the project
2. **Share with Others** 📣 - Tell your friends and colleagues
3. **Contribute** 🤝 - Help us make it even better
4. **Report Issues** 🐛 - Help improve the quality

---

<div align="center">

### 🎨 Happy Coloring!

*Because every color tells a story...*

[![Download on App Store](https://img.shields.io/badge/Download-App_Store-0D96F6?style=for-the-badge&logo=app-store)](https://apps.apple.com/app/your-app-id)

</div>

---

<p align="center">
  Made with ❤️ and SwiftUI
</p>

This enhanced README includes:
- 🎨 Visual badges and shields
- 📱 Professional app screenshots (replace placeholder URLs)
- 🏗️ Clear technical architecture
- 🤝 Contribution guidelines
- ⭐ Call-to-action for engagement
- 📊 Structured feature tables
- 🎯 Beautiful section dividers and icons

Remember to replace the placeholder screenshot URLs with actual images from your project!
