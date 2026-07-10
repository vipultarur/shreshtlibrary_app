import 'package:dio/dio.dart';

import 'package:shreshtlibrary/core/network/api_client.dart' hide JsonMap;
import 'package:shreshtlibrary/core/models/models.dart';
import 'package:shreshtlibrary/core/services/local_cache_service.dart';

class StudentApi {
  StudentApi(this._client, this._cache);

  final ApiClient _client;
  final LocalCacheService _cache;

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

  Future<void> resetPassword(String identifier, String token, String password) async {
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
    return _client.unwrap(
      response,
      (data) => StudentDashboard.fromJson(data as JsonMap? ?? const {}),
    );
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
    return _client.unwrap(
      response,
      (data) => AttendanceRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<List<AttendanceRecord>> attendanceLogs() async {
    final response = await _client.get<dynamic>('/attendance/logs');
    return _client.unwrapList(response, AttendanceRecord.fromJson);
  }

  Future<void> checkoutAttendance() async {
    final response = await _client.post<dynamic>('/attendance/checkout');
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
    return _client.unwrap(
      response,
      (data) => StudySession.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<void> stopStudySession(int durationMinutes, {int pausedMinutes = 0}) async {
    final response = await _client.post<dynamic>(
      '/study/session/end',
      data: {
        'duration_minutes': durationMinutes,
        'paused_minutes': pausedMinutes,
      },
    );
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

  Future<List<LeaderboardEntry>> leaderboard({String duration = 'month'}) async {
    final response = await _client.get<dynamic>(
      '/study/leaderboard',
      query: {'duration': duration},
    );
    return _client.unwrapList(response, LeaderboardEntry.fromJson);
  }

  Future<List<StudentNotification>> notifications() async {
    try {
      final response = await _client.get<dynamic>('/notifications/list');
      return _client.unwrap(response, (data) {
        // The API returns paginated data: { data: [...], count, total_pages }
        List<dynamic> rows = [];
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          rows = data['data'] as List<dynamic>? ?? <dynamic>[];
        } else if (data is List) {
          rows = data;
        }

        // Cache raw JSON
        _cache.saveNotifications(rows);

        return rows
            .whereType<Map<String, dynamic>>()
            .map(StudentNotification.fromJson)
            .toList();
      });
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
    return _client.unwrap(
      response,
      (data) => LibraryInfo.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<List<Facility>> facilities() async {
    final response = await _client.get<dynamic>('/library/facilities');
    return _client.unwrapList(response, Facility.fromJson);
  }

  Future<List<Achiever>> achievers({bool featured = false}) async {
    final response = await _client.get<dynamic>(
      '/library/achievers',
      query: featured ? {'featured': 'true'} : null,
    );
    return _client.unwrapList(response, Achiever.fromJson);
  }

  Future<List<ReviewRecord>> reviews() async {
    final response = await _client.get<dynamic>('/library/reviews');
    return _client.unwrapList(response, ReviewRecord.fromJson);
  }

  Future<ReviewSummary> reviewSummary() async {
    final response = await _client.get<dynamic>('/library/reviews/summary');
    return _client.unwrap(
      response,
      (data) => ReviewSummary.fromJson(data as JsonMap? ?? const {}),
    );
  }

  Future<List<GalleryImage>> galleryImages() async {
    final response = await _client.get<dynamic>('/library/gallery');
    return _client.unwrapList(response, GalleryImage.fromJson);
  }

  Future<ReviewRecord> submitReview({
    required int rating,
    required String comment,
  }) async {
    final response = await _client.post<dynamic>(
      '/library/reviews/submit',
      data: {'rating': rating, 'comment': comment},
    );
    return _client.unwrap(
      response,
      (data) => ReviewRecord.fromJson(data as JsonMap? ?? const {}),
    );
  }
  Future<List<HomeSlider>> sliders() async {
    final response = await _client.get<dynamic>('/sliders');
    return _client.unwrapList(response, HomeSlider.fromJson);
  }
}
