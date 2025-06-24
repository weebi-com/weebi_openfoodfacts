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

A comprehensive, reusable Flutter package for integrating with OpenFoodFacts API with advanced features like multi-language support, intelligent caching, and a foundation for multi-database support.

## 🌟 Features

### **Current Capabilities**
- **OpenFoodFacts Integration**: Full access to 2.9M+ food products
- **Multi-Language Support**: 10+ languages with automatic fallbacks
- **Advanced Caching**: Product and image caching for offline support
- **Framework-Agnostic**: Can be used in any Flutter project
- **Production Ready**: Comprehensive error handling and validation

### **Architecture Foundation for Future Expansion**
- **Multi-Database Ready**: Built with extensibility for OpenBeautyFacts and OpenProductsFacts
- **Product Type System**: Supports food, beauty, and general product types
- **Flexible Caching**: Database-aware caching system
- **Scalable Design**: Easy to extend for new databases and features

## 🚀 Current Database Support

| Database | Products | Status | Description |
|----------|----------|---------|-------------|
| **OpenFoodFacts** | 2.9M+ | ✅ **Active** | Food products with nutrition data |
| **OpenBeautyFacts** | 19K+ | 🔧 **Planned** | Cosmetic and beauty products |
| **OpenProductsFacts** | 11K+ | 🔧 **Planned** | General consumer products |

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  weebi_openfoodfacts_service:
    git:
      url: https://github.com/weebi-com/weebi_openfoodfacts.git
      ref: main
```

## 🛠️ Quick Start

### 1. Initialize the Service

```dart
import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

await WeebiOpenFoodFactsService.initialize(
  appName: 'MyAwesomeApp',
  appUrl: 'https://myapp.com', // Optional
  preferredLanguages: [
    WeebiLanguage.english,
    WeebiLanguage.french,
    WeebiLanguage.spanish,
  ],
  cacheConfig: CacheConfig.production,
);
```

### 2. Get Product Information

```dart
// Get a food product
final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');

if (product != null) {
  print('Product: ${product.name}');
  print('Brand: ${product.brand}');
  print('Nutri-Score: ${product.nutriScore}');
  print('NOVA Group: ${product.novaGroup}');
  print('Allergens: ${product.allergens.join(', ')}');
}
```

## 🌍 Multi-Language Support

The service automatically tries your preferred languages in order:

```dart
await WeebiOpenFoodFactsService.initialize(
  appName: 'MyApp',
  preferredLanguages: [
    WeebiLanguage.french,    // Try French first
    WeebiLanguage.english,   // Fallback to English
    WeebiLanguage.spanish,   // Then Spanish
  ],
);
```

**Supported Languages:**
- 🇺🇸 English
- 🇫🇷 French  
- 🇪🇸 Spanish
- 🇩🇪 German
- 🇮🇹 Italian
- 🇵🇹 Portuguese
- 🇳🇱 Dutch
- 🇨🇳 Chinese
- 🇯🇵 Japanese
- 🇸🇦 Arabic

## 💾 Caching System

### Cache Configurations

```dart
// Production: Aggressive caching for performance
CacheConfig.production

// Development: Minimal caching for testing
CacheConfig.development

// Custom configuration
CacheConfig(
  enableProductCache: true,
  enableImageCache: true,
  productCacheMaxAge: Duration(days: 7),
  imageCacheMaxAge: Duration(days: 30),
  maxCacheSize: 100 * 1024 * 1024, // 100MB
)
```

### Cache Management

```dart
// Clear all caches
await WeebiOpenFoodFactsService.clearCache();

// Get cache statistics
final stats = await WeebiOpenFoodFactsService.getCacheStats();
print('Cached products: ${stats['products']['count']}');
print('Cache size: ${stats['images']['size']} bytes');
```

## 🏗️ Product Types & Future Database Support

The service is architected to support multiple product databases:

```dart
// Current: Food products (OpenFoodFacts)
final foodProduct = await WeebiOpenFoodFactsService.getFoodProduct('3017620422003');
print('Type: ${foodProduct.productType}'); // WeebiProductType.food

// Future: Beauty products (OpenBeautyFacts) - Coming Soon
// final beautyProduct = await WeebiOpenFoodFactsService.getBeautyProduct('3560070791460');

// Future: General products (OpenProductsFacts) - Coming Soon  
// final generalProduct = await WeebiOpenFoodFactsService.getGeneralProduct('1234567890123');
```

## 📊 Product Information Available

### Food Products (Current)
- ✅ **Basic Info**: Name, brand, barcode
- ✅ **Nutrition**: Nutri-Score (A-E), NOVA group (1-4)
- ✅ **Safety**: Allergens, ingredients analysis
- ✅ **Images**: Front, ingredients, nutrition facts
- ✅ **Multi-language**: All data in preferred languages

### Beauty Products (Planned)
- 🔧 **Basic Info**: Name, brand, barcode
- 🔧 **Cosmetic Data**: Period after opening, ingredients
- 🔧 **Safety**: Allergen warnings, risk assessments
- 🔧 **Images**: Product photos, ingredient lists

### General Products (Planned)
- 🔧 **Basic Info**: Name, brand, barcode, category
- 🔧 **Product Data**: Features, specifications
- 🔧 **Images**: Product photos, documentation

## 🔧 Advanced Usage

### Error Handling

```dart
try {
  final product = await WeebiOpenFoodFactsService.getProduct('invalid-barcode');
} catch (e) {
  if (e is StateError) {
    // Service not initialized
    print('Please initialize the service first');
  } else {
    // Network or other errors
    print('Error fetching product: $e');
  }
}
```

### Barcode Validation

```dart
// Check if barcode is valid
if (WeebiOpenFoodFactsService.isLikelyFoodProduct('3017620422003')) {
  final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');
}
```

### Image Caching

```dart
// Get cached image path
final imagePath = await WeebiOpenFoodFactsService.getCachedImagePath(
  product.imageUrl
);

// Cache an image manually
final cachedPath = await WeebiOpenFoodFactsService.cacheImage(
  'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.3.400.jpg'
);
```

## 🎯 Use Cases

This package is perfect for:

- **🛒 Point of Sale Systems**: Quick product lookup with offline support
- **📱 Inventory Management**: Track products across multiple categories  
- **🍽️ Recipe Applications**: Access nutritional information
- **🏪 E-commerce Platforms**: Product data enrichment
- **📊 Analytics Dashboards**: Consumer product insights
- **🔍 Barcode Scanners**: Multi-database product identification

## 🚀 Roadmap

### Phase 1: OpenFoodFacts (✅ Complete)
- [x] Multi-language API integration
- [x] Advanced caching system
- [x] Comprehensive error handling
- [x] Production-ready package

### Phase 2: OpenBeautyFacts (🔧 In Progress)
- [ ] Beauty product API integration
- [ ] Cosmetic-specific data fields
- [ ] Period after opening support
- [ ] Ingredient safety analysis

### Phase 3: OpenProductsFacts (📋 Planned)
- [ ] General product API integration
- [ ] Product category system
- [ ] Multi-database search
- [ ] Unified product interface

### Phase 4: Advanced Features (🎯 Future)
- [ ] Real-time synchronization
- [ ] Machine learning recommendations
- [ ] Custom taxonomy support
- [ ] Enterprise features

## 🤝 Contributing

We welcome contributions! This package is designed to be:

- **Extensible**: Easy to add new databases
- **Maintainable**: Clean architecture and documentation
- **Testable**: Comprehensive test coverage
- **Reusable**: Framework-agnostic design

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenFoodFacts](https://openfoodfacts.org) for the amazing open data
- [OpenBeautyFacts](https://openbeautyfacts.org) for cosmetic product data
- [OpenProductsFacts](https://openproductsfacts.org) for general product data
- The Dart/Flutter community for excellent tooling

---

**Built with ❤️ by [Weebi](https://github.com/weebi-com) for the Flutter community**
