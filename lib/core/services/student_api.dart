import 'package:dio/dio.dart';

import 'package:shreshtlibrary/core/network/api_client.dart' hide JsonMap;
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';

class StudentApi {
  StudentApi(this._client, this._cache);

  final ApiClient _client;
  final LocalCacheService _cache;

  Stream<T> _streamItem<T>(
    String path,
    String cacheKey,
    T Function(JsonMap) parser, {
    Map<String, dynamic>? query,
    Duration? maxAge,
  }) async* {
    final staleCache = _cache.getCache(cacheKey);

    bool hasYielded = false;
    if (staleCache != null) {
      try {
        yield parser(staleCache as JsonMap);
        hasYielded = true;
      } catch (_) {}
    }

    // Always fetch from network to get latest data (stale-while-revalidate)
    // Only skip if maxAge is set AND cache is still fresh AND we already showed data
    final validCache = maxAge != null ? _cache.getCache(cacheKey, maxAge: maxAge) : null;
    if (hasYielded && validCache != null && maxAge != null) {
      return; // Cache is still fresh, skip network call
    }

    Response<dynamic>? response;
    int retryCount = 0;
    while (true) {
      try {
        response = await _client.get<dynamic>(path, query: query);
        break;
      } catch (_) {
        retryCount++;
        if (retryCount >= 2) {
          if (!hasYielded) rethrow;
          return;
        }
        await Future<void>.delayed(Duration(seconds: 1 * retryCount));
      }
    }

    try {
      yield _client.unwrap<T>(response, (data) {
        final json = data as JsonMap? ?? const {};
        _cache.saveCache(cacheKey, json);
        return parser(json);
      });
    } catch (_) {
      if (!hasYielded) rethrow;
    }
  }

  Stream<List<T>> _streamList<T>(
    String path,
    String cacheKey,
    T Function(JsonMap) parser, {
    Map<String, dynamic>? query,
    Duration? maxAge,
  }) async* {
    final staleCache = _cache.getCache(cacheKey);

    bool hasYielded = false;
    if (staleCache != null && staleCache is List) {
      try {
        yield staleCache.whereType<JsonMap>().map(parser).toList();
        hasYielded = true;
      } catch (_) {}
    }

    // Always fetch from network to get latest data (stale-while-revalidate)
    // Only skip if maxAge is set AND cache is still fresh AND we already showed data
    final validCache = maxAge != null ? _cache.getCache(cacheKey, maxAge: maxAge) : null;
    if (hasYielded && validCache != null && maxAge != null) {
      return; // Cache is still fresh, skip network call
    }

    Response<dynamic>? response;
    int retryCount = 0;
    while (true) {
      try {
        response = await _client.get<dynamic>(path, query: query);
        break;
      } catch (_) {
        retryCount++;
        if (retryCount >= 2) {
          if (!hasYielded) rethrow;
          return;
        }
        await Future<void>.delayed(Duration(seconds: 1 * retryCount));
      }
    }

    try {
      final payload = response.data;
      if (payload is Map<String, dynamic> && payload.containsKey('data')) {
        _cache.saveCache(cacheKey, payload['data']);
      } else if (payload is List) {
        _cache.saveCache(cacheKey, payload);
      }
      yield await _client.unwrapList<T>(response, parser);
    } catch (_) {
      if (!hasYielded) rethrow;
    }
  }

  Future<LoginResult> register(Map<String, dynamic> payload) async {
    final response = await _client.post<dynamic>(
      '/auth/register',
      data: payload,
    );
    return _client.unwrap(response, LoginResult.fromJson);
  }

  Future<bool> checkAvailability({String? email, String? mobile}) async {
    final response = await _client.post<dynamic>(
      '/auth/check-availability',
      data: {'email': email ?? '', 'mobile': mobile ?? ''},
    );
    return _client.unwrap(response, (data) {
      final json = data as JsonMap? ?? const {};
      return json['require_otp'] == true;
    });
  }

  Future<LoginResult> loginEmail(String email, String password) async {
    final response = await _client.post<dynamic>(
      '/auth/login/email',
      data: {'email': email, 'password': password},
    );
    return _client.unwrap(response, LoginResult.fromJson);
  }

  Future<LoginResult> loginMobile(String mobile, String password) async {
    final response = await _client.post<dynamic>(
      '/auth/login/mobile',
      data: {'mobile': mobile, 'password': password},
    );
    return _client.unwrap(response, LoginResult.fromJson);
  }

  Future<void> sendOtp(String mobile) async {
    final response = await _client.post<dynamic>(
      '/auth/send-otp',
      data: {'mobile': mobile},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> sendRegisterOtp(String mobile) async {
    final response = await _client.post<dynamic>(
      '/auth/send-register-otp',
      data: {'mobile': mobile},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> verifyRegisterOtp(String mobile, String otp) async {
    final response = await _client.post<dynamic>(
      '/auth/verify-register-otp',
      data: {'mobile': mobile, 'otp': otp},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<LoginResult> verifyOtp(String mobile, String otp) async {
    final response = await _client.post<dynamic>(
      '/auth/verify-otp',
      data: {'mobile': mobile, 'otp': otp},
    );
    return _client.unwrap(response, LoginResult.fromJson);
  }

  Future<void> forgotPassword(String identifier) async {
    final response = await _client.post<dynamic>(
      '/auth/forgot-password',
      data: {'identifier': identifier},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> verifyForgotPasswordOtp(String identifier, String token) async {
    final response = await _client.post<dynamic>(
      '/auth/forgot-password/verify',
      data: {'identifier': identifier, 'token': token},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> resetPassword(
    String identifier,
    String token,
    String password,
  ) async {
    final response = await _client.post<dynamic>(
      '/auth/reset-password',
      data: {
        'identifier': identifier,
        'token': token,
        'new_password': password,
        'confirm_password': password,
      },
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> logout() async {
    final tokens = await _client.tokenStore.read();
    final response = await _client.post<dynamic>(
      '/auth/logout',
      data: {'refresh': tokens?.refresh ?? ''},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.post<dynamic>(
      '/auth/change-password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
    _client.unwrap(response, (_) => null);
  }

  Future<StudentDashboard> dashboard() async {
    final response = await _client.get<dynamic>('/student/dashboard');
    return _client.unwrap(response, (data) {
      final json = data as JsonMap? ?? const {};
      _cache.saveCache('dashboard', json);
      return StudentDashboard.fromJson(json);
    });
  }

  Future<StudentProfile> profile() async {
    final response = await _client.get<dynamic>('/student/profile');
    return _client.unwrap(
      response,
      (data) => StudentProfile.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<StudentProfile> updateProfile(StudentProfile profile) async {
    final response = await _client.put<dynamic>(
      '/student/profile/update',
      data: profile.toUpdateJson(),
    );
    await _cache.clearCache('profile');
    await _cache.clearCache('dashboard');
    return _client.unwrap(
      response,
      (data) => StudentProfile.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<String?> uploadProfilePhoto(String filePath) async {
    final form = FormData.fromMap({
      'profile_photo': await MultipartFile.fromFile(filePath),
    });
    final response = await _client.post<dynamic>(
      '/student/profile/photo',
      data: form,
    );
    await _cache.clearCache('profile');
    await _cache.clearCache('idCard');
    await _cache.clearCache('dashboard');
    return _client.unwrap(response, (data) {
      final json = data as JsonMap? ?? const {};
      return optionalText(json['photo_url']);
    });
  }

  Future<StudentIdCard> idCard() async {
    final response = await _client.get<dynamic>('/student/id-card');
    return _client.unwrap(
      response,
      (data) => StudentIdCard.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<ReferralCode> referralCode() async {
    final response = await _client.get<dynamic>('/student/referral');
    return _client.unwrap(
      response,
      (data) => ReferralCode.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<void> applyReferral(String code) async {
    final response = await _client.post<dynamic>(
      '/student/referral/apply',
      data: {'code': code},
    );
    await _cache.clearCache('referral');
    await _cache.clearCache('referralHistory');
    _client.unwrap(response, (_) => null);
  }

  Future<List<ReferralHistory>> referralHistory() async {
    final response = await _client.get<dynamic>('/student/referral/history');
    return _client.unwrapList(response, ReferralHistory.fromJson);
  }

  Future<QRCodeRecord> todayQr() async {
    final response = await _client.get<dynamic>('/qr/today');
    return _client.unwrap(
      response,
      (data) => QRCodeRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<AttendanceRecord> scanQr(String value) async {
    final response = await _client.post<dynamic>(
      '/attendance/scan',
      data: {'qr_hash': value},
    );
    await _cache.invalidatePattern('attendanceLogs');
    await _cache.clearCache('dashboard');
    return _client.unwrap(
      response,
      (data) => AttendanceRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<List<AttendanceRecord>> attendanceLogs({int? year, int? month}) async {
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    final response = await _client.get<dynamic>('/attendance/logs', query: query);
    return _client.unwrapList(response, AttendanceRecord.fromJson);
  }

  Future<void> checkoutAttendance() async {
    final response = await _client.post<dynamic>('/attendance/checkout');
    await _cache.invalidatePattern('attendanceLogs');
    await _cache.clearCache('dashboard');
    _client.unwrap(response, (_) => null);
  }

  Future<List<HolidayRecord>> holidays() async {
    final response = await _client.get<dynamic>('/holidays');
    return _client.unwrapList(response, HolidayRecord.fromJson);
  }

  Future<List<MembershipPlan>> plans() async {
    final response = await _client.get<dynamic>('/memberships/plans');
    return _client.unwrapList(response, MembershipPlan.fromJson);
  }

  Future<List<MembershipRecord>> memberships() async {
    final response = await _client.get<dynamic>('/memberships/history');
    return _client.unwrapList(response, MembershipRecord.fromJson);
  }

  Future<List<PaymentRecord>> paymentHistory() async {
    final response = await _client.get<dynamic>('/payments/history');
    return _client.unwrapList(response, PaymentRecord.fromJson);
  }

  Future<PaymentRecord> initiatePayment({
    required int planId,
    required String paymentMode,
    required String transactionId,
  }) async {
    final response = await _client.post<dynamic>(
      '/payments/initiate',
      data: {
        'plan_id': planId,
        'payment_mode': paymentMode,
        'transaction_id': transactionId,
      },
    );
    await _cache.clearCache('paymentHistory');
    await _cache.clearCache('dashboard');
    return _client.unwrap(
      response,
      (data) => PaymentRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<List<Seat>> seats() async {
    final response = await _client.get<dynamic>('/seats/layout');
    return _client.unwrapList(response, Seat.fromJson);
  }

  Future<List<SeatAssignment>> seatHistory() async {
    final response = await _client.get<dynamic>('/seats/history');
    return _client.unwrapList(response, SeatAssignment.fromJson);
  }

  Future<StudySession> startStudySession() async {
    final response = await _client.post<dynamic>('/study/session/start');
    await _cache.clearCache('studySessionHistory');
    return _client.unwrap(
      response,
      (data) => StudySession.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<void> stopStudySession(
    int durationMinutes, {
    int pausedMinutes = 0,
  }) async {
    final response = await _client.post<dynamic>(
      '/study/session/end',
      data: {
        'duration_minutes': durationMinutes,
        'paused_minutes': pausedMinutes,
      },
    );
    await _cache.clearCache('studySessionHistory');
    _client.unwrap(response, (_) => null);
  }

  Future<StudySession?> getCurrentSession() async {
    final response = await _client.get<dynamic>('/study/session/current');
    return _client.unwrap(response, (data) {
      if (data == null || (data is Map && data.isEmpty)) return null;
      return StudySession.fromJson(data as JsonMap);
    });
  }

  Future<List<StudySession>> studySessionHistory() async {
    final response = await _client.get<dynamic>(
      '/study/session/history',
      query: {'page_size': 1000},
    );
    return _client.unwrapList(response, StudySession.fromJson);
  }

  Future<List<LeaderboardEntry>> leaderboard({
    String duration = 'month',
  }) async {
    final response = await _client.get<dynamic>(
      '/study/leaderboard',
      query: {'duration': duration},
    );
    return _client.unwrapList(response, LeaderboardEntry.fromJson);
  }

  Stream<List<StudentNotification>> notificationsStream() async* {
    final cached = _cache.getNotifications();
    if (cached.isNotEmpty) {
      try {
        yield cached
            .whereType<Map<String, dynamic>>()
            .map(StudentNotification.fromJson)
            .toList();
      } catch (_) {}
    }

    try {
      final response = await _client.get<dynamic>('/notifications/list');
      final payload = response.data;
      if (payload is Map<String, dynamic> && payload.containsKey('data')) {
        final innerData = payload['data'];
        if (innerData is Map<String, dynamic> && innerData.containsKey('data')) {
          _cache.saveNotifications(innerData['data'] as List<dynamic>? ?? <dynamic>[]);
        } else if (innerData is List) {
          _cache.saveNotifications(innerData);
        }
      } else if (payload is List) {
        _cache.saveNotifications(payload);
      }
      yield await _client.unwrapList(response, StudentNotification.fromJson);
    } catch (_) {
      if (cached.isEmpty) rethrow;
    }
  }

  Future<List<StudentNotification>> notifications() async {
    try {
      final response = await _client.get<dynamic>('/notifications/list');
      final payload = response.data;
      if (payload is Map<String, dynamic> && payload.containsKey('data')) {
        final innerData = payload['data'];
        if (innerData is Map<String, dynamic> && innerData.containsKey('data')) {
          _cache.saveNotifications(innerData['data'] as List<dynamic>? ?? <dynamic>[]);
        } else if (innerData is List) {
          _cache.saveNotifications(innerData);
        }
      } else if (payload is List) {
        _cache.saveNotifications(payload);
      }
      return await _client.unwrapList(response, StudentNotification.fromJson);
    } catch (_) {
      // Fallback to local cache
      final cached = _cache.getNotifications();
      return cached
          .whereType<Map<String, dynamic>>()
          .map(StudentNotification.fromJson)
          .toList();
    }
  }

  Future<void> markNotificationRead(int id) async {
    final response = await _client.post<dynamic>('/notifications/read/$id');
    _client.unwrap(response, (_) => null);
  }

  Future<void> markAllNotificationsRead() async {
    final response = await _client.post<dynamic>('/notifications/read-all');
    _client.unwrap(response, (_) => null);
  }

  Future<void> deleteNotification(int id) async {
    final response = await _client.delete<dynamic>('/notifications/$id');
    _client.unwrap(response, (_) => null);
  }

  Future<void> deleteAllNotifications() async {
    final response = await _client.delete<dynamic>('/notifications/all');
    _client.unwrap(response, (_) => null);
  }

  Future<void> registerDeviceToken(String token) async {
    final response = await _client.post<dynamic>(
      '/notifications/register-device',
      data: {'token': token},
    );
    _client.unwrap(response, (_) => null);
  }

  Future<LibraryInfo> libraryInfo() async {
    final response = await _client.get<dynamic>('/library/info');
    return _client.unwrap(response, (data) {
      final json = data as JsonMap? ?? const {};
      _cache.saveCache('library_info', json);
      return LibraryInfo.fromJson(json);
    });
  }

  Stream<LibraryInfo> libraryInfoStream() {
    return _streamItem<LibraryInfo>(
      '/library/info',
      'library_info',
      (json) => LibraryInfo.fromJson(json),
      maxAge: const Duration(days: 365),
    );
  }

  Future<List<Facility>> facilities() async {
    final response = await _client.get<dynamic>('/library/facilities');
    final payload = response.data;
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      _cache.saveCache('facilities', payload['data']);
    } else if (payload is List) {
      _cache.saveCache('facilities', payload);
    }
    return await _client.unwrapList(response, Facility.fromJson);
  }

  Stream<List<Facility>> facilitiesStream() async* {
    final cached = _cache.getCache(
      'facilities',
      maxAge: const Duration(hours: 4),
    );
    bool hasValidCache = false;
    if (cached != null && cached is List) {
      try {
        yield cached.whereType<JsonMap>().map(Facility.fromJson).toList();
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await facilities();
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Future<List<Achiever>> achievers({bool featured = false}) async {
    final response = await _client.get<dynamic>(
      '/library/achievers',
      query: featured ? {'featured': 'true'} : null,
    );
    final payload = response.data;
    final cacheKey = featured ? 'achievers_featured' : 'achievers';
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      _cache.saveCache(cacheKey, payload['data']);
    } else if (payload is List) {
      _cache.saveCache(cacheKey, payload);
    }
    return await _client.unwrapList(response, Achiever.fromJson);
  }

  Stream<List<Achiever>> achieversStream({bool featured = false}) async* {
    final cacheKey = featured ? 'achievers_featured' : 'achievers';
    final cached = _cache.getCache(cacheKey, maxAge: const Duration(hours: 4));
    bool hasValidCache = false;
    if (cached != null && cached is List) {
      try {
        yield cached.whereType<JsonMap>().map(Achiever.fromJson).toList();
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await achievers(featured: featured);
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Future<List<ReviewRecord>> reviews() async {
    final response = await _client.get<dynamic>('/library/reviews');
    return _client.unwrapList(response, ReviewRecord.fromJson);
  }

  Future<ReviewSummary> reviewSummary() async {
    final response = await _client.get<dynamic>('/library/reviews/summary');
    return _client.unwrap(response, (data) {
      final json = data as JsonMap? ?? const {};
      _cache.saveCache('review_summary', json);
      return ReviewSummary.fromJson(json);
    });
  }

  Future<Map<String, dynamic>> publicPaymentSettings() async {
    final response = await _client.get<dynamic>('/licensing/public-payment-settings');
    return _client.unwrap(response, (data) {
      return data as JsonMap? ?? const {};
    });
  }

  Stream<ReviewSummary> reviewSummaryStream() async* {
    final cached = _cache.getCache(
      'review_summary',
      maxAge: const Duration(hours: 1),
    );
    bool hasValidCache = false;
    if (cached != null) {
      try {
        yield ReviewSummary.fromJson(cached);
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await reviewSummary();
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Future<List<GalleryImage>> galleryImages() async {
    final response = await _client.get<dynamic>('/library/gallery');
    final payload = response.data;
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      _cache.saveCache('gallery_images', payload['data']);
    } else if (payload is List) {
      _cache.saveCache('gallery_images', payload);
    }
    return await _client.unwrapList(response, GalleryImage.fromJson);
  }

  Stream<List<GalleryImage>> galleryImagesStream() async* {
    final cached = _cache.getCache(
      'gallery_images',
      maxAge: const Duration(hours: 4),
    );
    bool hasValidCache = false;
    if (cached != null && cached is List) {
      try {
        yield cached.whereType<JsonMap>().map(GalleryImage.fromJson).toList();
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await galleryImages();
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Future<ReviewRecord> submitReview({
    required int rating,
    required String comment,
  }) async {
    final response = await _client.post<dynamic>(
      '/library/reviews/submit',
      data: {'rating': rating, 'comment': comment},
    );
    await _cache.clearCache('my_review');
    await _cache.clearCache('review_summary');
    return _client.unwrap(
      response,
      (data) => ReviewRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<ReviewRecord?> myReview() async {
    final response = await _client.get<dynamic>('/library/reviews/my');
    return _client.unwrap(response, (data) {
      if (data == null || (data is Map && data.isEmpty)) {
        _cache.saveCache('my_review', null);
        return null;
      }
      final json = data as JsonMap;
      _cache.saveCache('my_review', json);
      return ReviewRecord.fromJson(json);
    });
  }

  Stream<ReviewRecord?> myReviewStream() async* {
    final cached = _cache.getCache(
      'my_review',
      maxAge: const Duration(minutes: 15),
    );
    bool hasValidCache = false;
    if (cached != null) {
      try {
        yield ReviewRecord.fromJson(cached);
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await myReview();
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Future<List<HomeSlider>> sliders() async {
    final response = await _client.get<dynamic>('/sliders');
    final payload = response.data;
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      _cache.saveCache('home_sliders', payload['data']);
    } else if (payload is List) {
      _cache.saveCache('home_sliders', payload);
    }
    return await _client.unwrapList(response, HomeSlider.fromJson);
  }

  Stream<List<HomeSlider>> slidersStream() async* {
    final cached = _cache.getCache(
      'home_sliders',
      maxAge: const Duration(hours: 2),
    );
    bool hasValidCache = false;
    if (cached != null && cached is List) {
      try {
        yield cached.whereType<JsonMap>().map(HomeSlider.fromJson).toList();
        hasValidCache = true;
      } catch (_) {}
    }
    if (hasValidCache) return;

    try {
      yield await sliders();
    } catch (_) {
      if (cached == null) rethrow;
    }
  }

  Stream<StudentProfile> profileStream() => _streamItem(
    '/student/profile',
    'profile',
    (json) => StudentProfile.fromJson(json),
    maxAge: const Duration(hours: 2),
  );

  Stream<StudentIdCard> idCardStream() => _streamItem(
    '/student/id-card',
    'idCard',
    (json) => StudentIdCard.fromJson(json),
    maxAge: const Duration(hours: 24),
  );

  Stream<ReferralCode> referralCodeStream() => _streamItem(
    '/student/referral',
    'referral',
    (json) => ReferralCode.fromJson(json),
    maxAge: const Duration(hours: 24),
  );

  Stream<List<ReferralHistory>> referralHistoryStream() => _streamList(
    '/student/referral/history',
    'referralHistory',
    ReferralHistory.fromJson,
    maxAge: const Duration(hours: 1),
  );

  Stream<QRCodeRecord> todayQrStream() async* {
    yield await todayQr();
  }

  Stream<List<AttendanceRecord>> attendanceLogsStream({int? year, int? month}) {
    String cacheKey = 'attendanceLogs';
    if (year != null && month != null) cacheKey = 'attendanceLogs_${year}_$month';
    
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;

    // No maxAge: always fetch fresh data from network after showing cache instantly
    // This ensures admin-updated attendance status is always reflected
    return _streamList(
      '/attendance/logs',
      cacheKey,
      AttendanceRecord.fromJson,
      query: query.isNotEmpty ? query : null,
    );
  }

  Stream<List<HolidayRecord>> holidaysStream() => _streamList(
    '/holidays',
    'holidays',
    HolidayRecord.fromJson,
    maxAge: const Duration(hours: 24),
  );

  Stream<List<MembershipPlan>> plansStream() => _streamList(
    '/memberships/plans',
    'plans',
    MembershipPlan.fromJson,
    maxAge: const Duration(hours: 24),
  );

  Stream<List<MembershipRecord>> membershipsStream() => _streamList(
    '/memberships/history',
    'memberships',
    MembershipRecord.fromJson,
    maxAge: const Duration(hours: 2),
  );

  Stream<List<PaymentRecord>> paymentHistoryStream() => _streamList(
    '/payments/history',
    'paymentHistory',
    PaymentRecord.fromJson,
    maxAge: const Duration(hours: 2),
  );

  Stream<List<Seat>> seatsStream() async* {
    yield await seats();
  }

  Stream<List<SeatAssignment>> seatHistoryStream() async* {
    yield await seatHistory();
  }

  Stream<List<StudySession>> studySessionHistoryStream() => _streamList(
    '/study/session/history',
    'studySessionHistory',
    StudySession.fromJson,
    query: {'page_size': 1000},
    maxAge: const Duration(minutes: 10),
  );

  Stream<List<LeaderboardEntry>> leaderboardStream({
    String duration = 'month',
  }) => _streamList(
    '/study/leaderboard',
    'leaderboard_$duration',
    LeaderboardEntry.fromJson,
    query: {'duration': duration},
    maxAge: const Duration(minutes: 15),
  );

  Stream<List<ReviewRecord>> reviewsStream() => _streamList(
    '/library/reviews',
    'reviews',
    ReviewRecord.fromJson,
    maxAge: const Duration(hours: 2),
  );
}
