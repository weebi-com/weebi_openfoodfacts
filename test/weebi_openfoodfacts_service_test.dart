import 'package:flutter_test/flutter_test.dart';

import 'package:weebi_openfoodfacts_service/weebi_openfoodfacts_service.dart';

void main() {
  group('WeebiOpenFoodFactsService', () {
    test('service provides credential status', () {
      // Test credential status functionality
      final status = WeebiOpenFoodFactsService.getCredentialStatus();
      expect(status, isA<Map<String, dynamic>>());
      expect(status.containsKey('pricing_enabled'), true);
      expect(status.containsKey('can_submit_prices'), true);
    });

    test('service pricing features are available', () {
      expect(WeebiOpenFoodFactsService.isPricingEnabled, false); // Not initialized
      expect(WeebiOpenFoodFactsService.canSubmitPrices, false); // Not initialized
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

  group('CredentialManager', () {
    test('provides credential status checking', () {
      expect(CredentialManager.hasCredentials, false); // Not loaded initially
      expect(CredentialManager.hasOpenPricesCredentials, false);
      expect(CredentialManager.hasOpenPricesAuthToken, false);
    });
  });
}
