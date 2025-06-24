import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'models/weebi_product.dart';
import 'models/weebi_language.dart';

/// Client for Open Prices API integration
/// Based on: https://github.com/openfoodfacts/open-prices
class OpenPricesClient {
  static const String _baseUrl = 'https://prices.openfoodfacts.org/api/v1';
  static const String _userAgent = 'WeebiOpenFoodFactsService/1.1.0';
  
  /// Authentication token (to be provided later)
  String? _authToken;
  
  /// HTTP client instance
  final http.Client _httpClient;
  
  OpenPricesClient({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();
  
  /// Set authentication token for API access
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Get common headers for API requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'User-Agent': _userAgent,
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Get prices for a specific product by barcode
  Future<List<WeebiPrice>> getProductPrices(
    String barcode, {
    int limit = 20,
    String? location,
    DateTime? since,
  }) async {
    try {
      final queryParams = <String, String>{
        'product_code': barcode,
        'size': limit.toString(),
      };
      
      if (location != null) {
        queryParams['location_osm_name'] = location;
      }
      
      if (since != null) {
        queryParams['date__gte'] = since.toIso8601String().split('T')[0];
      }
      
      final uri = Uri.parse('$_baseUrl/prices').replace(queryParameters: queryParams);
      
      debugPrint('Fetching prices for $barcode from Open Prices API');
      
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List<dynamic>? ?? [];
        
        final prices = results
            .map((json) => WeebiPrice.fromOpenPrices(json as Map<String, dynamic>))
            .toList();
        
        debugPrint('Found ${prices.length} prices for $barcode');
        return prices;
      } else if (response.statusCode == 404) {
        debugPrint('No prices found for $barcode');
        return [];
      } else {
        debugPrint('Open Prices API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching prices for $barcode: $e');
      return [];
    }
  }
  
  /// Get the latest price for a product
  Future<WeebiPrice?> getLatestPrice(String barcode, {String? location}) async {
    try {
      final prices = await getProductPrices(
        barcode, 
        limit: 1, 
        location: location,
      );
      
      if (prices.isNotEmpty) {
        // Sort by date descending and return the most recent
        prices.sort((a, b) => b.date.compareTo(a.date));
        return prices.first;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching latest price for $barcode: $e');
      return null;
    }
  }
  
  /// Get price statistics for a product
  Future<WeebiPriceStats?> getPriceStats(String barcode, {String? location}) async {
    try {
      // Get recent prices (last 30 days)
      final since = DateTime.now().subtract(const Duration(days: 30));
      final prices = await getProductPrices(
        barcode,
        limit: 100,
        location: location,
        since: since,
      );
      
      if (prices.isEmpty) {
        return null;
      }
      
      return WeebiPriceStats.fromPrices(prices);
    } catch (e) {
      debugPrint('Error fetching price stats for $barcode: $e');
      return null;
    }
  }
  
  /// Search for products with prices in a specific location
  Future<List<Map<String, dynamic>>> searchProductsWithPrices({
    String? location,
    String? storeBrand,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'size': limit.toString(),
      };
      
      if (location != null) {
        queryParams['location_osm_name'] = location;
      }
      
      if (storeBrand != null) {
        queryParams['location_osm_display_name'] = storeBrand;
      }
      
      final uri = Uri.parse('$_baseUrl/prices').replace(queryParameters: queryParams);
      
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List<dynamic>).cast<Map<String, dynamic>>();
      } else {
        debugPrint('Open Prices search error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error searching products with prices: $e');
      return [];
    }
  }
  
  /// Get available locations (stores/cities) with price data
  Future<List<Map<String, dynamic>>> getLocations({int limit = 50}) async {
    try {
      final queryParams = {'size': limit.toString()};
      final uri = Uri.parse('$_baseUrl/locations').replace(queryParameters: queryParams);
      
      final response = await _httpClient.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List<dynamic>).cast<Map<String, dynamic>>();
      } else {
        debugPrint('Open Prices locations error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      return [];
    }
  }
  
  /// Submit a new price (requires authentication)
  Future<bool> submitPrice({
    required String barcode,
    required double price,
    required String currency,
    required String locationId,
    String? proofUrl,
    DateTime? date,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_authToken == null) {
      debugPrint('Authentication required to submit prices');
      return false;
    }
    
    try {
      final body = {
        'product_code': barcode,
        'price': price,
        'currency': currency,
        'location_osm_id': locationId,
        'date': (date ?? DateTime.now()).toIso8601String().split('T')[0],
        if (proofUrl != null) 'proof': proofUrl,
        ...?additionalData,
      };
      
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/prices'),
        headers: _headers,
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        debugPrint('Price submitted successfully for $barcode');
        return true;
      } else {
        debugPrint('Failed to submit price: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting price: $e');
      return false;
    }
  }
  
  /// Get API status and statistics
  Future<Map<String, dynamic>?> getApiStatus() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/status'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching API status: $e');
      return null;
    }
  }
  
  /// Close the HTTP client
  void dispose() {
    _httpClient.close();
  }
} 