# 🏠 PantryPal - Smart Kitchen Inventory Management

**Desktop Application Link**==>(https://transcendent-chaja-e691df.netlify.app/)
A modern iOS app built with SwiftUI and SwiftData that helps you manage your kitchen inventory, track expiration dates, scan barcodes, and discover recipes.

![PantryPal App](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-1.0+-purple.svg)


## ✨ Features

### 🥫 Smart Inventory Management
- **Organized Storage**: Categorize items by Pantry, Fridge, or Freezer
- **Expiration Tracking**: Color-coded expiration dates with smart notifications
- **Quantity Management**: Track amounts with flexible units (grams, ml, pieces)
- **Barcode Scanning**: Scan product barcodes to auto-populate information

### 🔍 Recipe Discovery
- **Ingredient-Based Search**: Find recipes using ingredients from your inventory
- **Expiration Priority**: Items expiring soon are highlighted for recipe suggestions
- **Recipe Integration**: Powered by Spoonacular API for thousands of recipes

### 🔔 Smart Notifications
- **Expiration Alerts**: Get notified 3 days before items expire
- **Daily Reminders**: Background task checks for expiring items
- **Customizable Settings**: Manage notification preferences

### 🎨 Beautiful UI/UX
- **Modern Design**: Glassmorphism cards with gradient backgrounds
- **Smooth Animations**: Framer Motion-inspired button interactions
- **Responsive Layout**: Optimized for all iOS devices
- **Dark Mode Support**: Beautiful in any lighting condition

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+ / macOS 12.0+
- Swift 5.9+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/pantrypal-ios.git
   cd pantrypal-ios
   ```

2. **Open in Xcode**
   ```bash
   open "Kitchen pantry.xcodeproj"
   ```

3. **Build and Run**
   - Select your target device (iPhone simulator or device)
   - Press `Cmd + R` to build and run

### API Keys Setup

The app uses external APIs that require API keys:

1. **Open Food Facts API** (Free, no key required)
   - Used for barcode scanning and product information

2. **Spoonacular API** (Free tier available)
   - Get your API key from [spoonacular.com/food-api](https://spoonacular.com/food-api)
   - Add it to `RecipeAPIManager.swift`

## 🏗️ Architecture

### Tech Stack
- **Frontend**: SwiftUI 4.0
- **Data Persistence**: SwiftData
- **Networking**: Async/Await with URLSession
- **Camera**: VisionKit for barcode scanning
- **Notifications**: UserNotifications framework

### Project Structure
```
Kitchen pantry/
├── Models/
│   └── FoodItem.swift          # Core data model
├── Views/
│   ├── ContentView.swift       # Main dashboard
│   ├── InventoryView.swift     # Inventory management
│   ├── AddFoodItemView.swift   # Add new items
│   ├── RecipeView.swift        # Recipe discovery
│   ├── BarcodeScannerView.swift # Barcode scanning
│   └── NotificationSettingsView.swift # Notification settings
├── Managers/
│   ├── NotificationManager.swift # Local notifications
│   ├── ProductAPIManager.swift  # Open Food Facts API
│   └── RecipeAPIManager.swift  # Spoonacular API
└── UI Components/
    ├── BackgroundView.swift     # Reusable background
    ├── GlassmorphismCard.swift # Glass effect cards
    ├── AnimatedGradientButton.swift # Animated buttons
    └── CustomTextFieldStyle.swift # Custom input styling
```


## 🔧 Configuration

### Camera Permissions
Add to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>PantryPal needs camera access to scan product barcodes</string>
```

### Notification Permissions
The app automatically requests notification permissions on first launch.



## 📈 Future Enhancements

- [ ] Cloud sync with iCloud
- [ ] Shopping list generation
- [ ] Nutritional information tracking
- [ ] Meal planning integration
- [ ] Social sharing features
- [ ] Multiple household support
- [ ] Export/import functionality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Open Food Facts** for product database
- **Spoonacular** for recipe API
- **Apple** for SwiftUI and SwiftData
- **Community** for inspiration and feedback

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/pantrypal-ios/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/pantrypal-ios/discussions)
- **Email**: your-email@example.com

---

<div align="center">
  <p>Made with ❤️ for better kitchen management</p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>
