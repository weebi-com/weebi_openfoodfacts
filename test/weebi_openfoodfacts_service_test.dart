import 'package:flutter_test/flutter_test.dart';

import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

void main() {
  group('WeebiOpenFoodFactsService', () {
    test('isLikelyFoodProduct validates food barcodes correctly', () {
      // Test food product barcodes (EAN-13 starting with food prefixes)
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('3017620422003'), true);
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('4000417025005'), true);
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('8000500037560'), true);
      
      // Test non-food barcodes
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('123456789012'), false);
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('1234567890123'), false); // Starts with 1
      
      // Test invalid barcodes
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct(''), false);
      expect(WeebiOpenFoodFactsService.isLikelyFoodProduct('123'), false);
    });

    test('service initialization state', () {
      expect(WeebiOpenFoodFactsService.isInitialized, false);
      expect(WeebiOpenFoodFactsService.preferredLanguages, [WeebiLanguage.english]);
    });
  });

  group('BarcodeValidator', () {
    test('validates barcodes correctly', () {
      expect(BarcodeValidator.isValid('3017620422003'), true);
      expect(BarcodeValidator.isValid('123456789012'), true);
      expect(BarcodeValidator.isValid('12345678'), true);
      
      expect(BarcodeValidator.isValid(''), false);
      expect(BarcodeValidator.isValid('123'), false);
      expect(BarcodeValidator.isValid('abc123'), false);
    });

    test('validates EAN-13 checksum correctly', () {
      expect(BarcodeValidator.isValidEAN13('3017620422003'), true);
      expect(BarcodeValidator.isValidEAN13('4000417025005'), true);
      
      expect(BarcodeValidator.isValidEAN13('3017620422004'), false); // Wrong checksum
      expect(BarcodeValidator.isValidEAN13('123456789012'), false); // Too short
      expect(BarcodeValidator.isValidEAN13('abc123'), false); // Invalid format
    });
  });

  group('WeebiLanguage', () {
    test('converts language codes correctly', () {
      expect(WeebiLanguage.fromCode('en'), WeebiLanguage.english);
      expect(WeebiLanguage.fromCode('fr'), WeebiLanguage.french);
      expect(WeebiLanguage.fromCode('es'), WeebiLanguage.spanish);
      expect(WeebiLanguage.fromCode('invalid'), null);
    });

    test('provides correct language properties', () {
      expect(WeebiLanguage.english.code, 'en');
      expect(WeebiLanguage.french.code, 'fr');
      expect(WeebiLanguage.english.displayName, 'English');
      expect(WeebiLanguage.french.displayName, 'Français');
    });
  });

  group('NutritionHelper', () {
    test('provides correct Nutri-Score colors', () {
      expect(NutritionHelper.getNutriScoreColor('A'), isNotNull);
      expect(NutritionHelper.getNutriScoreColor('E'), isNotNull);
      expect(NutritionHelper.getNutriScoreColor(null), isNull);
      expect(NutritionHelper.getNutriScoreColor('X'), isNull);
    });

    test('provides NOVA group descriptions', () {
      expect(NutritionHelper.getNovaGroupDescription(1), contains('Unprocessed'));
      expect(NutritionHelper.getNovaGroupDescription(4), contains('Ultra-processed'));
      expect(NutritionHelper.getNovaGroupDescription(null), contains('unknown'));
    });
  });
}
