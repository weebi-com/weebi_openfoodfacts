/// Advanced OpenFoodFacts integration with multi-language support,
/// image caching, and offline capabilities.
/// 
/// This package provides a comprehensive wrapper around the OpenFoodFacts API
/// with enhanced features for production applications:
/// 
/// - **Multi-language support**: Automatic language detection and fallbacks
/// - **Image caching**: Local caching of product images for offline use
/// - **Product caching**: SQLite-based local product database
/// - **Smart fallbacks**: Graceful degradation when API is unavailable
/// - **Rate limiting**: Built-in API rate limiting and request optimization
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';
/// 
/// // Initialize the service
/// await WeebiOpenFoodFactsService.initialize(
///   appName: 'Your App Name',
///   preferredLanguages: [WeebiLanguage.english, WeebiLanguage.french],
///   cacheConfig: CacheConfig.production,
/// );
/// 
/// // Get product information
/// final product = await WeebiOpenFoodFactsService.getProduct('3017620422003');
/// 
/// // Get cached image
/// final imagePath = await WeebiOpenFoodFactsService.getCachedImagePath(product?.imageUrl);
/// ```
library weebi_openfoodfacts_service;

export 'src/weebi_openfoodfacts_client.dart';
export 'src/product_cache_manager.dart';
export 'src/image_cache_manager.dart';
export 'src/language_manager.dart';
export 'src/models/weebi_product.dart';
export 'src/models/cache_config.dart';
export 'src/models/weebi_language.dart';
export 'src/utils/barcode_validator.dart';
export 'src/utils/nutrition_helper.dart';
