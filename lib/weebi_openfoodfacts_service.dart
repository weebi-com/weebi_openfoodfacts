/// Weebi OpenFoodFacts Service
/// 
/// A comprehensive, reusable Flutter package for integrating with OpenFoodFacts API 
/// with advanced features like multi-language support, intelligent caching, 
/// and Open Prices integration for real-world pricing data.
/// 
/// Features:
/// - OpenFoodFacts API integration (2.9M+ food products)
/// - Open Prices API integration (crowdsourced pricing data)
/// - Multi-language support (10+ languages with automatic fallbacks)
/// - Advanced caching (product & image caching for offline support)
/// - Framework-agnostic design for maximum reusability
/// - Production-ready error handling and validation
/// 
/// Future expansion ready for:
/// - OpenBeautyFacts (cosmetic products)
/// - OpenProductsFacts (general products)
library weebi_openfoodfacts_service;

// Core service
export 'src/weebi_openfoodfacts_client.dart';

// Open Prices integration
export 'src/open_prices_client.dart';

// Models
export 'src/models/weebi_product.dart';
export 'src/models/weebi_language.dart';
export 'src/models/cache_config.dart';

// Utilities
export 'src/utils/barcode_validator.dart';
export 'src/utils/nutrition_helper.dart';

// Cache managers (for advanced usage)
export 'src/product_cache_manager.dart';
export 'src/image_cache_manager.dart';
export 'src/language_manager.dart';
