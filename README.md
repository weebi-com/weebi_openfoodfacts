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

A comprehensive, reusable Flutter package for integrating with OpenFoodFacts API with advanced features like multi-language support, intelligent caching, and **Open Prices integration** for real-world pricing data.

## 🌟 Features

### **Current Capabilities**
- **OpenFoodFacts Integration**: Full access to 2.9M+ food products
- **🆕 Open Prices Integration**: Real-world pricing data from crowdsourced receipts
- **Multi-Language Support**: 10+ languages with automatic fallbacks
- **Advanced Caching**: Product and image caching for offline support
- **Framework-Agnostic**: Can be used in any Flutter project
- **Production Ready**: Comprehensive error handling and validation

### **🧾 Open Prices Features**
- **Real-time Pricing**: Current prices from actual stores
- **Price History**: Track price changes over time
- **Store Locations**: Find products at specific stores
- **Price Statistics**: Average, min/max prices with trends
- **Crowdsourced Data**: Community-driven price validation
- **Receipt Integration**: Submit prices from receipts (with auth)

### **Architecture Foundation for Future Expansion**
- **Multi-Database Ready**: Built with extensibility for OpenBeautyFacts and OpenProductsFacts
- **Product Type System**: Supports food, beauty, and general product types
- **Flexible Caching**: Database-aware caching system
- **Scalable Design**: Easy to extend for new databases and features

## 🚀 Current Database Support

| Database | Products | Pricing | Status | Description |
|----------|----------|---------|---------|-------------|
| **OpenFoodFacts** | 2.9M+ | ✅ **Yes** | ✅ **Active** | Food products with nutrition + pricing data |
| **OpenBeautyFacts** | 19K+ | 🔧 **Planned** | 🔧 **Planned** | Cosmetic and beauty products |
| **OpenProductsFacts** | 11K+ | 🔧 **Planned** | 📋 **Planned** | General consumer products |

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
  enablePricing: true, // 🆕 Enable Open Prices integration
  // openPricesAuthToken: 'your_token_here', // For submitting prices
);
```

### 2. Get Product with Pricing Information

```dart
// Get a food product with pricing data
final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');

if (product != null) {
  print('Product: ${product.name}');
  print('Brand: ${product.brand}');
  print('Nutri-Score: ${product.nutriScore}');
  print('NOVA Group: ${product.novaGroup}');
  
  // 🆕 Pricing information
  if (product.hasPriceData) {
    print('Current Price: ${product.currentPrice}');
    print('Price Stats: ${product.priceStats?.averagePrice} EUR avg');
    print('Recent Prices: ${product.recentPrices.length} records');
  }
}
```

### 3. Advanced Pricing Queries

```dart
// Get latest price for a product
final latestPrice = await WeebiOpenFoodFactsService.getLatestPrice('3017620422003');
print('Latest: ${latestPrice?.price} ${latestPrice?.currency} at ${latestPrice?.storeName}');

// Get price history
final priceHistory = await WeebiOpenFoodFactsService.getPriceHistory(
  '3017620422003',
  limit: 30,
  since: DateTime.now().subtract(Duration(days: 30)),
);

// Get price statistics
final stats = await WeebiOpenFoodFactsService.getPriceStats('3017620422003');
print('Average: ${stats?.averagePrice} EUR');
print('Range: ${stats?.minPrice} - ${stats?.maxPrice} EUR');

// Search products with prices in a location
final productsWithPrices = await WeebiOpenFoodFactsService.searchProductsWithPrices(
  location: 'Paris',
  limit: 20,
);
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
// Current: Food products (OpenFoodFacts) with pricing
final foodProduct = await WeebiOpenFoodFactsService.getFoodProduct('3017620422003');
print('Type: ${foodProduct.productType}'); // WeebiProductType.food
print('Price: ${foodProduct.currentPrice}'); // 🆕 Real pricing data

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
- ✅ **🆕 Pricing**: Current prices, price history, statistics

### Beauty Products (Planned)
- 🔧 **Basic Info**: Name, brand, barcode
- 🔧 **Cosmetic Data**: Period after opening, ingredients
- 🔧 **Safety**: Allergen warnings, risk assessments
- 🔧 **Images**: Product photos, ingredient lists
- 🔧 **🆕 Pricing**: Beauty product pricing (future)

### General Products (Planned)
- 🔧 **Basic Info**: Name, brand, barcode, category
- 🔧 **Product Data**: Features, specifications
- 🔧 **Images**: Product photos, documentation
- 🔧 **🆕 Pricing**: General product pricing (future)

## 🔧 Advanced Usage

### Performance Optimization

```dart
// Get product without pricing for faster response
final product = await WeebiOpenFoodFactsService.getProductBasic('3017620422003');

// Get product with pricing specifically
final productWithPricing = await WeebiOpenFoodFactsService.getProductWithPricing(
  '3017620422003',
  location: 'Paris', // Optional location filter
);
```

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

### 🆕 Price Submission (Requires Authentication)

```dart
// Set authentication token
WeebiOpenFoodFactsService.setOpenPricesAuthToken('your_auth_token');

// Submit a new price
final success = await WeebiOpenFoodFactsService.submitPrice(
  barcode: '3017620422003',
  price: 3.45,
  currency: 'EUR',
  locationId: 'store_osm_id',
  proofUrl: 'https://example.com/receipt.jpg', // Optional
);

if (success) {
  print('Price submitted successfully!');
}
```

### Store Locations

```dart
// Get available store locations
final locations = await WeebiOpenFoodFactsService.getStoreLocations();
for (final location in locations) {
  print('${location['osm_display_name']} - ${location['osm_address_city']}');
}

// Check Open Prices API status
final status = await WeebiOpenFoodFactsService.getOpenPricesStatus();
print('API Status: ${status?['status']}');
```

## 🎯 Use Cases

This package is perfect for:

- **🛒 Point of Sale Systems**: Product lookup with real-time pricing
- **📱 Inventory Management**: Track products with cost analysis  
- **🍽️ Recipe Applications**: Nutritional information + ingredient costs
- **🏪 E-commerce Platforms**: Product data + competitive pricing
- **📊 Price Comparison Apps**: Multi-store price tracking
- **🔍 Smart Shopping Apps**: Barcode scanning with price alerts
- **💰 Budget Tracking**: Food expense analysis with nutrition data

## 🚀 Roadmap

### Phase 1: OpenFoodFacts + Open Prices (✅ Complete)
- [x] Multi-language API integration
- [x] Advanced caching system
- [x] Comprehensive error handling
- [x] **🆕 Open Prices integration**
- [x] **🆕 Real-time pricing data**
- [x] **🆕 Price history & statistics**
- [x] Production-ready package

### Phase 2: OpenBeautyFacts (🔧 In Progress)
- [ ] Beauty product API integration
- [ ] Cosmetic-specific data fields
- [ ] Period after opening support
- [ ] Ingredient safety analysis
- [ ] **🆕 Beauty product pricing**

### Phase 3: OpenProductsFacts (📋 Planned)
- [ ] General product API integration
- [ ] Product category system
- [ ] Multi-database search
- [ ] Unified product interface
- [ ] **🆕 General product pricing**

### Phase 4: Advanced Features (🎯 Future)
- [ ] **🆕 Price alerts & notifications**
- [ ] **🆕 Receipt scanning integration**
- [ ] **🆕 Store loyalty program integration**
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
- [**🆕 Open Prices**](https://prices.openfoodfacts.org) for crowdsourced pricing data
- [OpenBeautyFacts](https://openbeautyfacts.org) for cosmetic product data
- [OpenProductsFacts](https://openproductsfacts.org) for general product data
- The Dart/Flutter community for excellent tooling

---

**Built with ❤️ by [Weebi](https://github.com/weebi-com) for the Flutter community**
