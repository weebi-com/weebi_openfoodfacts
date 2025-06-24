import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'models/weebi_language.dart';
import 'models/cache_config.dart';
import 'models/weebi_product.dart';
import 'language_manager.dart';
import 'product_cache_manager.dart';
import 'image_cache_manager.dart';
import 'utils/barcode_validator.dart';

/// Advanced OpenFoodFacts client with multi-language support and caching
class WeebiOpenFoodFactsService {
  static bool _initialized = false;
  static late LanguageManager _languageManager;
  static late ProductCacheManager _productCacheManager;
  static late ImageCacheManager _imageCacheManager;
  static late CacheConfig _cacheConfig;

  /// Initialize the service with configuration
  static Future<void> initialize({
    required String appName,
    String? appUrl,
    List<WeebiLanguage> preferredLanguages = const [WeebiLanguage.english],
    CacheConfig cacheConfig = CacheConfig.production,
  }) async {
    if (_initialized) return;

    // Initialize OpenFoodFacts configuration
    off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
      name: appName,
      url: appUrl,
    );

    // Store configuration
    _cacheConfig = cacheConfig;

    // Initialize managers
    _languageManager = LanguageManager(preferredLanguages);
    
    if (cacheConfig.enableProductCache) {
      _productCacheManager = ProductCacheManager(cacheConfig);
      await _productCacheManager.initialize();
    }
    
    if (cacheConfig.enableImageCache) {
      _imageCacheManager = ImageCacheManager(cacheConfig);
      await _imageCacheManager.initialize();
    }

    // Set global OpenFoodFacts configuration
    off.OpenFoodAPIConfiguration.globalLanguages = 
        _languageManager.preferredLanguages.map((lang) => lang.openFoodFactsLanguage).toList();
    off.OpenFoodAPIConfiguration.globalCountry = off.OpenFoodFactsCountry.FRANCE;

    _initialized = true;
    debugPrint('WeebiOpenFoodFactsService initialized with ${preferredLanguages.length} languages');
  }

  /// Get product information with multi-language support and caching
  static Future<WeebiProduct?> getProduct(String barcode) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }

    // Validate barcode
    if (!BarcodeValidator.isValid(barcode)) {
      debugPrint('Invalid barcode: $barcode');
      return null;
    }

    // Check cache first
    if (_cacheConfig.enableProductCache) {
      final cachedProduct = await _productCacheManager.getProduct(barcode);
      if (cachedProduct != null) {
        debugPrint('Product found in cache: $barcode');
        return cachedProduct;
      }
    }

    // Fetch from API with language fallback
    for (final language in _languageManager.preferredLanguages) {
      try {
        debugPrint('Fetching product $barcode in ${language.displayName}');
        
        final configuration = off.ProductQueryConfiguration(
          barcode,
          language: language.openFoodFactsLanguage,
          fields: [
            off.ProductField.BARCODE,
            off.ProductField.NAME,
            off.ProductField.BRANDS,
            off.ProductField.INGREDIENTS_TEXT,
            off.ProductField.ALLERGENS,
            off.ProductField.NUTRISCORE,
            off.ProductField.NOVA_GROUP,
            off.ProductField.NUTRIMENTS,
            off.ProductField.IMAGES,
            off.ProductField.IMAGE_FRONT_URL,
            off.ProductField.IMAGE_INGREDIENTS_URL,
            off.ProductField.IMAGE_NUTRITION_URL,
          ],
          version: off.ProductQueryVersion.v3,
        );

        final result = await off.OpenFoodAPIClient.getProductV3(configuration);
        
        if (result.status == off.ProductResultV3.statusSuccess && result.product != null) {
          final weebiProduct = WeebiProduct.fromOpenFoodFacts(result.product!, language);
          
          // Cache the result
          if (_cacheConfig.enableProductCache) {
            await _productCacheManager.cacheProduct(weebiProduct);
          }
          
          debugPrint('Product found: ${weebiProduct.name ?? 'Unknown'} (${language.displayName})');
          return weebiProduct;
        }
      } catch (e) {
        debugPrint('Error fetching product in ${language.displayName}: $e');
        continue; // Try next language
      }
    }

    // If we reach here, product was not found in any language
    debugPrint('Product not found: $barcode');
    return null;
  }

  /// Get cached image file for a product image URL
  static Future<String?> getCachedImagePath(String? imageUrl) async {
    if (!_initialized || imageUrl == null || !_cacheConfig.enableImageCache) {
      return null;
    }
    
    return await _imageCacheManager.getCachedImagePath(imageUrl);
  }

  /// Cache an image from URL
  static Future<String?> cacheImage(String imageUrl) async {
    if (!_initialized || !_cacheConfig.enableImageCache) {
      return null;
    }
    
    return await _imageCacheManager.cacheImage(imageUrl);
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    if (!_initialized) return;
    
    if (_cacheConfig.enableProductCache) {
      await _productCacheManager.clearCache();
    }
    
    if (_cacheConfig.enableImageCache) {
      await _imageCacheManager.clearCache();
    }
    
    debugPrint('Cache cleared');
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_initialized) return {};
    
    final stats = <String, dynamic>{};
    
    if (_cacheConfig.enableProductCache) {
      stats['products'] = await _productCacheManager.getCacheStats();
    }
    
    if (_cacheConfig.enableImageCache) {
      stats['images'] = await _imageCacheManager.getCacheStats();
    }
    
    return stats;
  }

  /// Check if barcode is likely a food product
  static bool isLikelyFoodProduct(String barcode) {
    return BarcodeValidator.isLikelyFoodProduct(barcode);
  }

  /// Get current language configuration
  static List<WeebiLanguage> get preferredLanguages {
    if (!_initialized) return [WeebiLanguage.english];
    return _languageManager.preferredLanguages;
  }

  /// Update preferred languages
  static void updatePreferredLanguages(List<WeebiLanguage> languages) {
    if (!_initialized) return;
    
    _languageManager.updatePreferredLanguages(languages);
    off.OpenFoodAPIConfiguration.globalLanguages = 
        languages.map((lang) => lang.openFoodFactsLanguage).toList();
    
    debugPrint('Updated preferred languages: ${languages.map((l) => l.displayName).join(', ')}');
  }

  /// Check if service is initialized
  static bool get isInitialized => _initialized;

  /// Get current cache configuration
  static CacheConfig get cacheConfig {
    if (!_initialized) return CacheConfig.minimal;
    return _cacheConfig;
  }
} 