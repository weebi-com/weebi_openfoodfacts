import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'models/weebi_language.dart';
import 'models/cache_config.dart';
import 'models/weebi_product.dart';
import 'language_manager.dart';
import 'product_cache_manager.dart';
import 'image_cache_manager.dart';
import 'open_prices_client.dart';
import 'utils/barcode_validator.dart';
import 'utils/credential_manager.dart';

/// Advanced OpenFoodFacts client with multi-language support, caching, and pricing data
/// 
/// This service currently supports OpenFoodFacts (food products) with a foundation
/// for future expansion to OpenBeautyFacts and OpenProductsFacts.
/// Now includes Open Prices integration for real-world pricing data.
class WeebiOpenFoodFactsService {
  static bool _initialized = false;
  static late LanguageManager _languageManager;
  static late ProductCacheManager _productCacheManager;
  static late ImageCacheManager _imageCacheManager;
  static late OpenPricesClient _openPricesClient;
  static late CacheConfig _cacheConfig;
  static bool _enablePricing = true;

  /// Initialize the service with configuration
  /// 
  /// The service will automatically attempt to load credentials from:
  /// - `open_prices_credentials.json` (for Open Prices API)
  /// - `credentials.json` (for general credentials)
  /// 
  /// These files should be in your package root and added to .gitignore
  static Future<void> initialize({
    required String appName,
    String? appUrl,
    List<WeebiLanguage> preferredLanguages = const [WeebiLanguage.english],
    CacheConfig cacheConfig = CacheConfig.production,
    bool enablePricing = true,
    String? openPricesAuthToken,
    bool autoLoadCredentials = true,
    String? packageRoot,
  }) async {
    if (_initialized) return;

    // Load credentials automatically if enabled
    if (autoLoadCredentials) {
      await CredentialManager.loadAllCredentials(packageRoot: packageRoot);
      
      if (CredentialManager.hasOpenPricesCredentials) {
        debugPrint('✅ Open Prices credentials loaded from file');
      } else {
        debugPrint('ℹ️  Open Prices credentials not found - template created');
      }
    }

    // Initialize OpenFoodFacts configuration
    off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
      name: appName,
      url: appUrl,
    );

    // Store configuration
    _cacheConfig = cacheConfig;
    _enablePricing = enablePricing;

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

    // Initialize Open Prices client
    if (_enablePricing) {
      _openPricesClient = OpenPricesClient();
      
      // Configure authentication from credentials
      final authConfigured = await _openPricesClient.configureAuthentication();
      
      if (authConfigured) {
        final authStatus = _openPricesClient.getAuthStatus();
        final method = authStatus['auth_method'];
        debugPrint('✅ Open Prices authentication configured ($method)');
      } else {
        // Try manual token if provided
        if (openPricesAuthToken != null && openPricesAuthToken.isNotEmpty) {
          _openPricesClient.setAuthToken(openPricesAuthToken);
          debugPrint('✅ Open Prices authentication configured (manual API token)');
        } else {
          debugPrint('ℹ️  Open Prices running in read-only mode (no authentication)');
        }
      }
    }

    // Set global OpenFoodFacts configuration
    off.OpenFoodAPIConfiguration.globalLanguages = 
        _languageManager.preferredLanguages.map((lang) => lang.openFoodFactsLanguage).toList();
    off.OpenFoodAPIConfiguration.globalCountry = off.OpenFoodFactsCountry.FRANCE;

    _initialized = true;
    final pricingStatus = _enablePricing ? 'with pricing' : 'without pricing';
    final authStatus = CredentialManager.hasOpenPricesAuthToken ? '(authenticated)' : '(read-only)';
    debugPrint('🚀 WeebiOpenFoodFactsService initialized $pricingStatus $authStatus and ${preferredLanguages.length} languages');
  }

  /// Set Open Prices authentication token
  static void setOpenPricesAuthToken(String token) {
    if (_initialized && _enablePricing) {
      _openPricesClient.setAuthToken(token);
      debugPrint('✅ Open Prices authentication token updated');
    }
  }

  /// Load credentials from files
  /// 
  /// This can be called after initialization to reload credentials
  static Future<bool> loadCredentials({String? packageRoot}) async {
    try {
      await CredentialManager.loadAllCredentials(packageRoot: packageRoot);
      
      if (_initialized && _enablePricing && CredentialManager.hasOpenPricesAuthToken) {
        final token = CredentialManager.openPricesAuthToken!;
        _openPricesClient.setAuthToken(token);
        debugPrint('✅ Credentials reloaded and applied');
        return true;
      }
      
      return CredentialManager.hasOpenPricesCredentials;
    } catch (e) {
      debugPrint('❌ Error loading credentials: $e');
      return false;
    }
  }

  /// Get credential status information
  static Map<String, dynamic> getCredentialStatus() {
    final basicStatus = <String, dynamic>{
      'credentials_loaded': CredentialManager.hasCredentials,
      'open_prices_credentials_loaded': CredentialManager.hasOpenPricesCredentials,
      'pricing_enabled': _enablePricing,
    };
    
    if (_enablePricing && _initialized) {
      final authStatus = _openPricesClient.getAuthStatus();
      basicStatus.addAll({
        'open_prices_authenticated': authStatus['authenticated'],
        'open_prices_auth_method': authStatus['auth_method'],
        'session_expired': authStatus['session_expired'],
        'can_submit_prices': authStatus['authenticated'],
      });
      
      // Add credential availability info
      basicStatus.addAll({
        'has_api_token': CredentialManager.hasOpenPricesAuthToken,
        'has_login_credentials': CredentialManager.hasOpenPricesLoginCredentials,
        'preferred_auth_method': CredentialManager.preferredAuthMethod.toString().split('.').last,
      });
    } else {
      basicStatus.addAll({
        'open_prices_authenticated': false,
        'can_submit_prices': false,
        'has_api_token': CredentialManager.hasOpenPricesAuthToken,
        'has_login_credentials': CredentialManager.hasOpenPricesLoginCredentials,
        'preferred_auth_method': CredentialManager.preferredAuthMethod.toString().split('.').last,
      });
    }
    
    return basicStatus;
  }

  /// Get product information with multi-language support, caching, and pricing data
  /// Currently supports OpenFoodFacts (food products)
  static Future<WeebiProduct?> getProduct(
    String barcode, {
    bool includePricing = true,
    String? location,
  }) async {
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
        
        // If pricing is enabled and requested, try to get fresh pricing data
        if (_enablePricing && includePricing && !cachedProduct.hasPriceData) {
          final pricingData = await _fetchPricingData(barcode, location: location);
          if (pricingData != null) {
            return cachedProduct.copyWithPrices(
              currentPrice: pricingData['currentPrice'],
              recentPrices: pricingData['recentPrices'],
              priceStats: pricingData['priceStats'],
            );
          }
        }
        
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
          // Fetch pricing data if enabled
          Map<String, dynamic>? pricingData;
          if (_enablePricing && includePricing) {
            pricingData = await _fetchPricingData(barcode, location: location);
          }
          
          final weebiProduct = WeebiProduct.fromOpenFoodFacts(
            result.product!, 
            language, 
            WeebiProductType.food, // Currently only food products
            currentPrice: pricingData?['currentPrice'],
            recentPrices: pricingData?['recentPrices'] ?? [],
            priceStats: pricingData?['priceStats'],
          );
          
          // Cache the result
          if (_cacheConfig.enableProductCache) {
            await _productCacheManager.cacheProduct(weebiProduct);
          }
          
          final priceInfo = weebiProduct.currentPrice != null 
              ? ' (${weebiProduct.currentPrice})'
              : '';
          debugPrint('Product found: ${weebiProduct.name ?? 'Unknown'} (${language.displayName})$priceInfo');
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

  /// Fetch pricing data for a product
  static Future<Map<String, dynamic>?> _fetchPricingData(
    String barcode, {
    String? location,
  }) async {
    if (!_enablePricing) return null;
    
    try {
      // Get latest price and recent prices in parallel
      final futures = await Future.wait([
        _openPricesClient.getLatestPrice(barcode, location: location),
        _openPricesClient.getProductPrices(
          barcode,
          limit: 30,
          location: location,
          since: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ]);
      
      final currentPrice = futures[0] as WeebiPrice?;
      final recentPrices = futures[1] as List<WeebiPrice>;
      
      // Calculate price statistics
      WeebiPriceStats? priceStats;
      if (recentPrices.isNotEmpty) {
        priceStats = WeebiPriceStats.fromPrices(recentPrices);
      }
      
      if (currentPrice != null || recentPrices.isNotEmpty) {
        debugPrint('Found pricing data for $barcode: ${recentPrices.length} recent prices');
        return {
          'currentPrice': currentPrice,
          'recentPrices': recentPrices,
          'priceStats': priceStats,
        };
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching pricing data for $barcode: $e');
      return null;
    }
  }

  /// Get food product (alias for getProduct - current implementation)
  static Future<WeebiProduct?> getFoodProduct(String barcode, {String? location}) {
    return getProduct(barcode, location: location);
  }

  /// Get product with pricing data specifically
  static Future<WeebiProduct?> getProductWithPricing(
    String barcode, {
    String? location,
  }) {
    return getProduct(barcode, includePricing: true, location: location);
  }

  /// Get product without pricing data (faster)
  static Future<WeebiProduct?> getProductBasic(String barcode) {
    return getProduct(barcode, includePricing: false);
  }

  /// Get latest price for a product
  static Future<WeebiPrice?> getLatestPrice(String barcode, {String? location}) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return null;
    }
    
    return await _openPricesClient.getLatestPrice(barcode, location: location);
  }

  /// Get price history for a product
  static Future<List<WeebiPrice>> getPriceHistory(
    String barcode, {
    String? location,
    int limit = 50,
    DateTime? since,
  }) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return [];
    }
    
    return await _openPricesClient.getProductPrices(
      barcode,
      limit: limit,
      location: location,
      since: since,
    );
  }

  /// Get price statistics for a product
  static Future<WeebiPriceStats?> getPriceStats(String barcode, {String? location}) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return null;
    }
    
    return await _openPricesClient.getPriceStats(barcode, location: location);
  }

  /// Search for products with prices in a location
  static Future<List<Map<String, dynamic>>> searchProductsWithPrices({
    String? location,
    String? storeBrand,
    int limit = 20,
  }) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return [];
    }
    
    return await _openPricesClient.searchProductsWithPrices(
      location: location,
      storeBrand: storeBrand,
      limit: limit,
    );
  }

  /// Get available store locations
  static Future<List<Map<String, dynamic>>> getStoreLocations({int limit = 50}) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return [];
    }
    
    return await _openPricesClient.getLocations(limit: limit);
  }

  /// Submit a new price (requires authentication)
  static Future<bool> submitPrice({
    required String barcode,
    required double price,
    required String currency,
    required String locationId,
    String? proofUrl,
    DateTime? date,
  }) async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return false;
    }
    
    if (!CredentialManager.hasOpenPricesAuthToken) {
      debugPrint('❌ Authentication required to submit prices. Please configure your Open Prices credentials.');
      return false;
    }
    
    return await _openPricesClient.submitPrice(
      barcode: barcode,
      price: price,
      currency: currency,
      locationId: locationId,
      proofUrl: proofUrl,
      date: date,
    );
  }

  /// Get Open Prices API status
  static Future<Map<String, dynamic>?> getOpenPricesStatus() async {
    if (!_initialized) {
      throw StateError('WeebiOpenFoodFactsService not initialized. Call initialize() first.');
    }
    
    if (!_enablePricing) {
      debugPrint('Pricing is disabled');
      return null;
    }
    
    return await _openPricesClient.getApiStatus();
  }

  /// Check if pricing is enabled
  static bool get isPricingEnabled => _initialized && _enablePricing;

  /// Check if price submission is available (requires authentication)
  static bool get canSubmitPrices => _initialized && _enablePricing && CredentialManager.hasOpenPricesAuthToken;

  /// Clear all caches
  static Future<void> clearCache() async {
    if (_initialized) {
      if (_cacheConfig.enableProductCache) {
        await _productCacheManager.clearCache();
      }
      if (_cacheConfig.enableImageCache) {
        await _imageCacheManager.clearCache();
      }
      debugPrint('All caches cleared');
    }
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    if (!_initialized) {
      return {
        'products': {'count': 0, 'size': 0},
        'images': {'count': 0, 'size': 0},
      };
    }

    final productStats = _cacheConfig.enableProductCache
        ? await _productCacheManager.getCacheStats()
        : {'count': 0, 'size': 0};

    final imageStats = _cacheConfig.enableImageCache
        ? await _imageCacheManager.getCacheStats()
        : {'count': 0, 'size': 0};

    return {
      'products': productStats,
      'images': imageStats,
    };
  }

  /// Dispose resources
  static void dispose() {
    if (_initialized && _enablePricing) {
      _openPricesClient.dispose();
    }
    // Clear credentials from memory for security
    CredentialManager.clearCredentials();
  }
} 