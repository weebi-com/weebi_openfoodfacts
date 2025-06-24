import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'weebi_language.dart';

/// Product type enumeration
enum WeebiProductType {
  food('Food Product'),
  beauty('Beauty/Cosmetic Product'),
  general('General Product');
  
  const WeebiProductType(this.displayName);
  final String displayName;
}

/// Enhanced product model with multi-language support and multi-database compatibility
class WeebiProduct {
  /// Product barcode
  final String barcode;
  
  /// Product type (food, beauty, or general)
  final WeebiProductType productType;
  
  /// Product name (in the fetched language)
  final String? name;
  
  /// Product brand
  final String? brand;
  
  /// Ingredients text (in the fetched language)
  final String? ingredients;
  
  /// List of allergens (mainly for food products)
  final List<String> allergens;
  
  /// Nutri-Score (A, B, C, D, E) - Food products only
  final String? nutriScore;
  
  /// NOVA group (1-4, food processing level) - Food products only
  final int? novaGroup;
  
  /// Period after opening (cosmetics only) - e.g., "12M", "6M"
  final String? periodAfterOpening;
  
  /// Main product image URL
  final String? imageUrl;
  
  /// Ingredients image URL
  final String? ingredientsImageUrl;
  
  /// Nutrition facts image URL (food products)
  final String? nutritionImageUrl;
  
  /// Language this product data was fetched in
  final WeebiLanguage language;
  
  /// When this product was cached
  final DateTime cachedAt;
  
  /// Original OpenFoodFacts product (for advanced usage)
  final off.Product? originalProduct;

  const WeebiProduct({
    required this.barcode,
    required this.productType,
    this.name,
    this.brand,
    this.ingredients,
    this.allergens = const [],
    this.nutriScore,
    this.novaGroup,
    this.periodAfterOpening,
    this.imageUrl,
    this.ingredientsImageUrl,
    this.nutritionImageUrl,
    required this.language,
    required this.cachedAt,
    this.originalProduct,
  });

  /// Create from OpenFoodFacts product with type detection
  factory WeebiProduct.fromOpenFoodFacts(
    off.Product product, 
    WeebiLanguage language,
    WeebiProductType productType,
  ) {
    return WeebiProduct(
      barcode: product.barcode ?? '',
      productType: productType,
      name: product.productName,
      brand: product.brands,
      ingredients: product.ingredientsText,
      allergens: product.allergens?.names ?? [],
      nutriScore: productType == WeebiProductType.food ? product.nutriscore : null,
      novaGroup: productType == WeebiProductType.food ? product.novaGroup : null,
      periodAfterOpening: _extractPeriodAfterOpening(product),
      imageUrl: product.imageFrontUrl,
      ingredientsImageUrl: product.imageIngredientsUrl,
      nutritionImageUrl: productType == WeebiProductType.food ? product.imageNutritionUrl : null,
      language: language,
      cachedAt: DateTime.now(),
      originalProduct: product,
    );
  }

  /// Extract period after opening for cosmetic products
  static String? _extractPeriodAfterOpening(off.Product product) {
    // This would extract from product.misc or other fields
    // The exact field name needs to be verified from the API
    return null; // TODO: Implement based on actual API response
  }

  /// Create from JSON (for caching)
  factory WeebiProduct.fromJson(Map<String, dynamic> json) {
    return WeebiProduct(
      barcode: json['barcode'] as String,
      productType: WeebiProductType.values.firstWhere(
        (type) => type.name == json['productType'],
        orElse: () => WeebiProductType.general,
      ),
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      ingredients: json['ingredients'] as String?,
      allergens: (json['allergens'] as List<dynamic>?)?.cast<String>() ?? [],
      nutriScore: json['nutriScore'] as String?,
      novaGroup: json['novaGroup'] as int?,
      periodAfterOpening: json['periodAfterOpening'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ingredientsImageUrl: json['ingredientsImageUrl'] as String?,
      nutritionImageUrl: json['nutritionImageUrl'] as String?,
      language: WeebiLanguage.fromCode(json['language'] as String) ?? WeebiLanguage.english,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
    );
  }

  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'productType': productType.name,
      'name': name,
      'brand': brand,
      'ingredients': ingredients,
      'allergens': allergens,
      'nutriScore': nutriScore,
      'novaGroup': novaGroup,
      'periodAfterOpening': periodAfterOpening,
      'imageUrl': imageUrl,
      'ingredientsImageUrl': ingredientsImageUrl,
      'nutritionImageUrl': nutritionImageUrl,
      'language': language.code,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  /// Check if product has basic information
  bool get hasBasicInfo => name != null || brand != null;

  /// Check if product has nutrition information (food products)
  bool get hasNutritionInfo => nutriScore != null || novaGroup != null;

  /// Check if product has allergen information
  bool get hasAllergenInfo => allergens.isNotEmpty;

  /// Check if product has ingredient information
  bool get hasIngredientInfo => ingredients != null && ingredients!.isNotEmpty;

  /// Check if product has cosmetic-specific information
  bool get hasCosmeticInfo => periodAfterOpening != null;

  /// Check if cache is still valid (based on age)
  bool isCacheValid(Duration maxAge) {
    return DateTime.now().difference(cachedAt) <= maxAge;
  }

  /// Get display text for product type
  String get productTypeDisplay => productType.displayName;

  /// Check if this is a food product
  bool get isFood => productType == WeebiProductType.food;

  /// Check if this is a beauty/cosmetic product
  bool get isBeauty => productType == WeebiProductType.beauty;

  /// Check if this is a general product
  bool get isGeneral => productType == WeebiProductType.general;

  /// Copy with updated values
  WeebiProduct copyWith({
    String? barcode,
    WeebiProductType? productType,
    String? name,
    String? brand,
    String? ingredients,
    List<String>? allergens,
    String? nutriScore,
    int? novaGroup,
    String? periodAfterOpening,
    String? imageUrl,
    String? ingredientsImageUrl,
    String? nutritionImageUrl,
    WeebiLanguage? language,
    DateTime? cachedAt,
    off.Product? originalProduct,
  }) {
    return WeebiProduct(
      barcode: barcode ?? this.barcode,
      productType: productType ?? this.productType,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      nutriScore: nutriScore ?? this.nutriScore,
      novaGroup: novaGroup ?? this.novaGroup,
      periodAfterOpening: periodAfterOpening ?? this.periodAfterOpening,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredientsImageUrl: ingredientsImageUrl ?? this.ingredientsImageUrl,
      nutritionImageUrl: nutritionImageUrl ?? this.nutritionImageUrl,
      language: language ?? this.language,
      cachedAt: cachedAt ?? this.cachedAt,
      originalProduct: originalProduct ?? this.originalProduct,
    );
  }

  @override
  String toString() {
    return 'WeebiProduct(barcode: $barcode, name: $name, brand: $brand, language: ${language.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeebiProduct &&
        other.barcode == barcode &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(barcode, language);
} 