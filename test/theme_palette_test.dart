// The app still shipped the old red/teal palette after the website moved to
// its "Papyrus" theme, so the two no longer looked like the same shop
// (ClickUp 14zb93nxwwa). The colours now come from one place --
// lib/common/theme/colors.dart -- plus the runtime config JSON that supplies
// the main colour. These pin both ends, so a stray hex cannot quietly drift
// the app away from the site again.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magentoegypt/common/theme/colors.dart';
import 'package:magentoegypt/common/theme/light_theme.dart';

void main() {
  group('the Papyrus palette matches the website', () {
    test('it carries the values the site renders', () {
      // Read off https://locafy.magento2.click: the first three are its
      // --accent-color, --primary-color and --bg-light custom properties.
      expect(kPapyrusOlive, const Color(0xFF4F5D2F));
      expect(kPapyrusBrown, const Color(0xFF2F2216));
      expect(kPapyrusBeige, const Color(0xFFE6D3A3));
      expect(kPapyrusTerracotta, const Color(0xFFA4502E));
      expect(kPapyrusCream, const Color(0xFFFBF5E6));
      expect(kPapyrusSand, const Color(0xFFF3E7C9));
    });

    test('the light theme is built from it', () {
      final theme = buildLightTheme('en');

      expect(theme.colorScheme.primary, kPapyrusOlive);
      expect(theme.colorScheme.onPrimary, kPapyrusCream);
      expect(theme.colorScheme.secondary, kPapyrusTerracotta);
      expect(theme.scaffoldBackgroundColor, kPapyrusSand);
      expect(theme.cardColor, kPapyrusCream);
    });

    test('both runtime configs name the same main colour', () {
      for (final name in ['config_en.json', 'config_ar.json']) {
        final config =
            jsonDecode(File('lib/config/$name').readAsStringSync()) as Map;
        expect((config['Setting'] as Map)['MainColor'], '#4F5D2F',
            reason: name);
      }
    });
  });
}
