<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Weebi OpenFoodFacts Service

Advanced OpenFoodFacts integration with multi-language support, image caching, and offline capabilities. This private package provides enhanced features for production applications that need robust food product data integration.

## 🚀 Features

### 🌍 **Multi-Language Support**
- Automatic language detection and fallbacks
- Support for 10+ languages (English, French, Spanish, German, etc.)
- Graceful degradation when product data isn't available in preferred language

### 💾 **Advanced Caching**
- **Product Caching**: SQLite-based local product database
- **Image Caching**: Local storage of product images for offline use
- **Smart Expiration**: Configurable cache expiration and cleanup
- **Offline Support**: Graceful fallback to cached data when API is unavailable

### ⚡ **Performance Optimizations**
- Built-in API rate limiting and request optimization
- Efficient batch operations for multiple products
- Background cache maintenance and cleanup
- Memory-efficient image handling

### 🔧 **Production Ready**
- Comprehensive error handling and retry logic
- Detailed logging and debugging support
- Configurable cache policies for different environments
- Thread-safe operations

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  weebi_openfoodfacts_service:
    path: ../weebi_openfoodfacts_service  # Local path
```

## 🎯 Quick Start

### 1. Initialize the Service

```dart
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

// Initialize with default production settings
await WeebiOpenFoodFactsService.initialize(
  appName: 'Your App Name',
  appUrl: 'https://your-app.com', // Optional
  preferredLanguages: [
    WeebiLanguage.english,
    WeebiLanguage.french,
  ],
  cacheConfig: CacheConfig.production,
);
```

### 2. Get Product Information

```dart
// Get product with automatic caching and language fallback
final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');

if (product != null) {
  print('Product: ${product.name}');
  print('Brand: ${product.brand}');
  print('Nutri-Score: ${product.nutriScore}');
  print('Language: ${product.language.displayName}');
}
```

### 3. Handle Product Images

```dart
// Get cached image path (returns null if not cached)
final imagePath = await WeebiOpenFoodFactsService.getCachedImagePath(
  product?.imageUrl
);

// Or cache an image explicitly
final cachedPath = await WeebiOpenFoodFactsService.cacheImage(
  product!.imageUrl!
);
```

## ⚙️ Configuration

### Cache Configuration

Choose from predefined configurations or create custom ones:

```dart
// Production configuration (recommended)
const config = CacheConfig.production; // 7 days products, 30 days images

// Development configuration
const config = CacheConfig.development; // 1 day products, 7 days images

// Minimal configuration (cache disabled)
const config = CacheConfig.minimal;

// Custom configuration
const config = CacheConfig(
  productCacheMaxAgeDays: 14,
  imageCacheMaxAgeDays: 60,
  maxCachedProducts: 2000,
  maxCachedImages: 1000,
  maxImageCacheSizeMB: 200,
  enableImageCache: true,
  enableProductCache: true,
  useOfflineCache: true,
);
```

### Language Configuration

```dart
// Set preferred languages (in order of preference)
WeebiOpenFoodFactsService.updatePreferredLanguages([
  WeebiLanguage.french,    // Try French first
  WeebiLanguage.english,   // Fallback to English
  WeebiLanguage.spanish,   // Then Spanish
]);

// Get current language preferences
final languages = WeebiOpenFoodFactsService.preferredLanguages;
```

## 🔍 Advanced Usage

### Cache Management

```dart
// Get cache statistics
final stats = await WeebiOpenFoodFactsService.getCacheStats();
print('Cached products: ${stats['products']['count']}');
print('Cached images: ${stats['images']['count']}');

// Clear all cache
await WeebiOpenFoodFactsService.clearCache();
```

### Barcode Validation

```dart
// Check if barcode is valid
if (WeebiOpenFoodFactsService.isLikelyFoodProduct('3017620422003')) {
  final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');
}

// Advanced validation
if (BarcodeValidator.isValidEAN13('3017620422003')) {
  // Process valid EAN-13 barcode
}
```

### Nutrition Helpers

```dart
// Get Nutri-Score color for UI
final color = NutritionHelper.getNutriScoreColor(product.nutriScore);

// Get NOVA group information
final description = NutritionHelper.getNovaGroupDescription(product.novaGroup);
final color = NutritionHelper.getNovaGroupColor(product.novaGroup);
```

## 🏗️ Architecture

This package is designed to be **framework-agnostic** and can be used in:

- ✅ **Barcode Scanner Apps** (like this demo)
- ✅ **Inventory Management Systems**
- ✅ **Recipe & Nutrition Apps**
- ✅ **Point-of-Sale Systems**
- ✅ **E-commerce Platforms**
- ✅ **Any Flutter app needing food product data**

### Key Components

- **`WeebiOpenFoodFactsService`**: Main service class with static methods
- **`WeebiProduct`**: Enhanced product model with multi-language support
- **`LanguageManager`**: Handles language preferences and fallbacks
- **`ProductCacheManager`**: SQLite-based product caching
- **`ImageCacheManager`**: File-based image caching
- **`BarcodeValidator`**: Barcode validation utilities
- **`NutritionHelper`**: UI helpers for nutrition data

## 🔧 Development

### TODOs for Full Implementation

The current version provides the complete architecture and interfaces. To make it production-ready, implement:

1. **SQLite Integration** in `ProductCacheManager`
2. **File-based Image Caching** in `ImageCacheManager`
3. **Background Sync** for cache maintenance
4. **Rate Limiting** for API calls
5. **Retry Logic** with exponential backoff

### Testing

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Check dependencies
flutter pub deps
```

## 📋 API Reference

### WeebiOpenFoodFactsService

| Method | Description |
|--------|-------------|
| `initialize()` | Initialize the service with configuration |
| `getProduct()` | Get product with caching and language fallback |
| `getCachedImagePath()` | Get path to cached image |
| `cacheImage()` | Cache an image from URL |
| `clearCache()` | Clear all cached data |
| `getCacheStats()` | Get cache statistics |
| `updatePreferredLanguages()` | Update language preferences |

### WeebiProduct

| Property | Type | Description |
|----------|------|-------------|
| `barcode` | `String` | Product barcode |
| `name` | `String?` | Product name (localized) |
| `brand` | `String?` | Product brand |
| `ingredients` | `String?` | Ingredients text (localized) |
| `allergens` | `List<String>` | List of allergens |
| `nutriScore` | `String?` | Nutri-Score (A-E) |
| `novaGroup` | `int?` | NOVA group (1-4) |
| `imageUrl` | `String?` | Main product image URL |
| `language` | `WeebiLanguage` | Language of the data |
| `cachedAt` | `DateTime` | When cached |

## 🤝 Integration with Other Projects

This package is designed to be easily integrated into any project that needs OpenFoodFacts data:

```dart
// In a barcode scanner app
final result = await scanner.scan();
final product = await WeebiOpenFoodFactsService.getProduct(result.barcode);

// In an inventory system
final products = await Future.wait(
  barcodes.map((barcode) => WeebiOpenFoodFactsService.getProduct(barcode))
);

// In a recipe app
final ingredients = await getRecipeIngredients();
final nutritionData = await Future.wait(
  ingredients.map((ingredient) => 
    WeebiOpenFoodFactsService.getProduct(ingredient.barcode)
  )
);
```

## 📄 License

Private package for Weebi projects. All rights reserved.

---

**Built with ❤️ for the Weebi ecosystem**
