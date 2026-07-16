import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final cacheService = ref.watch(localCacheServiceProvider);
    final cachedLang = cacheService.getLanguageCode();
    if (cachedLang != null) {
      return Locale(cachedLang);
    }
    return const Locale('en');
  }

  Future<void> setLocale(String languageCode) async {
    final cacheService = ref.read(localCacheServiceProvider);
    await cacheService.setLanguageCode(languageCode);
    state = Locale(languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
