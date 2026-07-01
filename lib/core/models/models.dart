import 'package:shreshtlibrary/core/network/token_store.dart';
import 'package:shreshtlibrary/core/config/app_config.dart';

typedef JsonMap = Map<String, dynamic>;

String text(Object? value, [String fallback = '']) =>
    value?.toString() ?? fallback;
String? optionalText(Object? value) => value?.toString();

String? imageUrl(Object? value) {
  final path = value?.toString();
  if (path == null || path.isEmpty) return null;
  if (path.startsWith('http')) return path;
  final uri = Uri.parse(AppConfig.apiBaseUrl);
  final origin = '${uri.scheme}://${uri.host}${uri.port == 80 || uri.port == 443 ? '' : ':${uri.port}'}';
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  return '$origin$normalizedPath';
}
int integer(Object? value, [int fallback = 0]) =>
    int.tryParse(value?.toString() ?? '') ?? fallback;
double decimal(Object? value, [double fallback = 0]) =>
    double.tryParse(value?.toString() ?? '') ?? fallback;
bool boolean(Object? value, [bool fallback = false]) {
  if (value is bool) {
    return value;
  }
  if (value == null) {
    return fallback;
  }
  return {'true', '1', 'yes', 'on'}.contains(value.toString().toLowerCase());
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.mobile,
    required this.role,
    required this.isActive,
  });

  final int id;
  final String username;
  final String email;
  final String mobile;
  final String role;
  final bool isActive;

  factory AuthUser.fromJson(JsonMap json) {
    return AuthUser(
      id: integer(json['id']),
      username: text(json['username']),
      email: text(json['email']),
      mobile: text(json['mobile']),
      role: text(json['role'], 'student'),
      isActive: boolean(json['is_active'], true),
    );
  }
}

class LoginResult {
  const LoginResult({required this.tokens, required this.user});

  final StoredTokens tokens;
  final AuthUser user;

  factory LoginResult.fromJson(Object? data) {
    final json = data as JsonMap? ?? const {};
    final tokens = json['tokens'] as JsonMap? ?? const {};
    return LoginResult(
      tokens: StoredTokens(
        access: text(tokens['access']),
        refresh: text(tokens['refresh']),
      ),
      user: AuthUser.fromJson(json['user'] as JsonMap? ?? const {}),
    );
  }
}

class StudentProfile {
  const StudentProfile({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.goal,
    this.dob,
    this.caste,
    this.address,
    this.profilePhoto,
    this.parentMobile,
  });

  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String goal;
  final String? dob;
  final String? caste;
  final String? address;
  final String? profilePhoto;
  final String? parentMobile;

  String get fullName =>
      [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ');

  factory StudentProfile.fromJson(JsonMap json) {
    return StudentProfile(
      username: text(json['username']),
      firstName: text(json['first_name']),
      lastName: text(json['last_name']),
      email: text(json['email']),
      mobile: text(json['mobile']),
      goal: text(json['goal'], 'Other'),
      dob: optionalText(json['dob'] ?? json['date_of_birth']),
      caste: optionalText(json['caste']),
      address: optionalText(json['address']),
      profilePhoto: imageUrl(
        json['profile_photo'] ?? json['profile_image'],
      ),
      parentMobile: optionalText(json['parent_mobile']),
    );
  }

  JsonMap toUpdateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'goal': goal,
    'dob': dob,
    'caste': caste,
    'address': address,
    'parent_mobile': parentMobile,
  }..removeWhere((_, value) => value == null);
}

class StudentDashboard {
  const StudentDashboard({
    required this.studentId,
    required this.fullName,
    required this.membershipPlan,
    required this.membershipDaysLeft,
    required this.isPremium,
    required this.membershipStatus,
    required this.restrictedFeatures,
    this.expiryDialogTitle,
    this.expiryDialogMessage,
    required this.assignedSeat,
    required this.assignedSeatFloor,
    required this.markedAttendanceToday,
    required this.isHoliday,
    this.holidayTitle,
    this.holidayDescription,
    this.razorpayKey,
    this.attendanceStatus,
    this.attendanceTime,
    this.allowQrScan = false,
  });

  final int studentId;
  final String fullName;
  final String membershipPlan;
  final int membershipDaysLeft;
  final bool isPremium;
  final String membershipStatus;
  final List<String> restrictedFeatures;
  final String? expiryDialogTitle;
  final String? expiryDialogMessage;
  final String assignedSeat;
  final String assignedSeatFloor;
  final bool markedAttendanceToday;
  final bool isHoliday;
  final String? holidayTitle;
  final String? holidayDescription;
  final String? razorpayKey;
  final String? attendanceStatus;
  final String? attendanceTime;
  final bool allowQrScan;

  factory StudentDashboard.fromJson(JsonMap json) {
    final expiryDialog = json['expiry_dialog'] as JsonMap?;
    return StudentDashboard(
      studentId: integer(json['student_id']),
      fullName: text(json['full_name']),
      membershipPlan: text(json['membership_plan']),
      membershipDaysLeft: integer(json['membership_days_left']),
      isPremium: boolean(json['is_premium']),
      membershipStatus: text(json['membership_status'], 'NEW'),
      restrictedFeatures: (json['restricted_features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      expiryDialogTitle: expiryDialog != null ? text(expiryDialog['title']) : null,
      expiryDialogMessage: expiryDialog != null ? text(expiryDialog['message']) : null,
      assignedSeat: text(json['assigned_seat']),
      assignedSeatFloor: text(json['assigned_seat_floor']),
      markedAttendanceToday: boolean(json['marked_attendance_today']),
      isHoliday: boolean(json['is_holiday']),
      holidayTitle: optionalText(json['holiday_title']),
      holidayDescription: optionalText(json['holiday_description']),
      razorpayKey: optionalText(json['razorpay_key']),
      attendanceStatus: optionalText(json['attendance_status']),
      attendanceTime: optionalText(json['attendance_time']),
      allowQrScan: boolean(json['allow_qr_scan']),
    );
  }

  DashboardFeatures get features => DashboardFeatures(restrictedFeatures);
}

class DashboardFeatures {
  const DashboardFeatures(this._restrictedFeatures);
  final List<String> _restrictedFeatures;

  bool get allowNotifications => !_restrictedFeatures.contains('notifications');
  bool get allowSliders => !_restrictedFeatures.contains('sliders');
  bool get allowLibraryInfo => !_restrictedFeatures.contains('library_info');
}

class StudentIdCard {
  const StudentIdCard({
    required this.studentId,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.goal,
    required this.qrData,
    this.dob,
    this.photoUrl,
  });

  final int studentId;
  final String fullName;
  final String mobile;
  final String email;
  final String goal;
  final String qrData;
  final String? dob;
  final String? photoUrl;

  factory StudentIdCard.fromJson(JsonMap json) {
    return StudentIdCard(
      studentId: integer(json['student_id']),
      fullName: text(json['full_name']),
      mobile: text(json['mobile']),
      email: text(json['email']),
      goal: text(json['goal']),
      dob: optionalText(json['dob']),
      photoUrl: imageUrl(json['photo_url']),
      qrData: text(json['qr_data']),
    );
  }
}

class ReferralCode {
  const ReferralCode({
    required this.id,
    required this.studentName,
    required this.code,
    required this.usedByCount,
    this.benefitGiven,
  });

  final int id;
  final String studentName;
  final String code;
  final int usedByCount;
  final String? benefitGiven;

  factory ReferralCode.fromJson(JsonMap json) => ReferralCode(
    id: integer(json['id']),
    studentName: text(json['student_name']),
    code: text(json['code']),
    usedByCount: integer(json['used_by_count']),
    benefitGiven: optionalText(json['benefit_given']),
  );
}

class ReferralHistory {
  const ReferralHistory({
    required this.id,
    required this.referredStudentName,
    required this.appliedAt,
  });

  final int id;
  final String referredStudentName;
  final String appliedAt;

  factory ReferralHistory.fromJson(JsonMap json) => ReferralHistory(
    id: integer(json['id']),
    referredStudentName: text(json['referred_student_name']),
    appliedAt: text(json['applied_at']),
  );
}

class QRCodeRecord {
  const QRCodeRecord({
    required this.id,
    required this.code,
    required this.validDate,
    required this.isExpired,
    this.qrHash,
    this.expiresAt,
  });

  final int id;
  final String code;
  final String? qrHash;
  final String validDate;
  final bool isExpired;
  final String? expiresAt;

  String get scanValue => (qrHash?.isNotEmpty ?? false) ? qrHash! : code;

  factory QRCodeRecord.fromJson(JsonMap json) => QRCodeRecord(
    id: integer(json['id']),
    code: text(json['code']),
    qrHash: optionalText(json['qr_hash']),
    validDate: text(json['valid_date']),
    isExpired: boolean(json['is_expired']),
    expiresAt: optionalText(json['expires_at'] ?? json['expiry_timestamp']),
  );
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.studentName,
    required this.date,
    required this.isManual,
    required this.isPresent,
    this.timeIn,
    this.timeOut,
    this.lateMark = false,
    this.underTime = false,
    this.totalHours,
    this.method,
  });

  final int id;
  final String studentName;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final bool lateMark;
  final bool underTime;
  final String? totalHours;
  final bool isManual;
  final bool isPresent;
  final String? method;

  factory AttendanceRecord.fromJson(JsonMap json) => AttendanceRecord(
    id: integer(json['id']),
    studentName: text(json['student_name']),
    date: text(json['date']),
    timeIn: optionalText(json['time_in']),
    timeOut: optionalText(json['time_out']),
    lateMark: boolean(json['late_mark']),
    underTime: boolean(json['under_time']),
    totalHours: optionalText(json['total_hours']),
    isManual: boolean(json['is_manual']),
    isPresent: boolean(json['is_present'], true),
    method: optionalText(json['method']),
  );
}

class HolidayRecord {
  const HolidayRecord({
    required this.id,
    required this.date,
    required this.title,
    this.description,
  });

  final int id;
  final String date;
  final String title;
  final String? description;

  factory HolidayRecord.fromJson(JsonMap json) => HolidayRecord(
    id: integer(json['id']),
    date: text(json['date']),
    title: text(json['title']),
    description: optionalText(json['description']),
  );
}

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.price,
    this.description,
  });

  final int id;
  final String name;
  final int durationMonths;
  final double price;
  final String? description;

  factory MembershipPlan.fromJson(JsonMap json) => MembershipPlan(
    id: integer(json['id']),
    name: text(json['name']),
    durationMonths: integer(json['duration_months']),
    price: decimal(json['price']),
    description: optionalText(json['description']),
  );
}

class MembershipRecord {
  const MembershipRecord({
    required this.id,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  final int id;
  final String planName;
  final String startDate;
  final String endDate;
  final String status;

  factory MembershipRecord.fromJson(JsonMap json) => MembershipRecord(
    id: integer(json['id']),
    planName: text(json['plan_name']),
    startDate: text(json['start_date']),
    endDate: text(json['end_date']),
    status: text(json['status']),
  );
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.planName,
    required this.amount,
    required this.status,
    required this.paymentMode,
    required this.paymentDate,
    this.transactionId,
  });

  final int id;
  final String planName;
  final double amount;
  final String status;
  final String paymentMode;
  final String paymentDate;
  final String? transactionId;

  factory PaymentRecord.fromJson(JsonMap json) => PaymentRecord(
    id: integer(json['id']),
    planName: text(json['plan_name']),
    amount: decimal(json['amount']),
    status: text(json['status']),
    paymentMode: text(json['payment_mode']),
    paymentDate: text(json['payment_date']),
    transactionId: optionalText(
      json['transaction_id'] ?? json['transaction_ref'],
    ),
  );
}

class Seat {
  const Seat({
    required this.id,
    required this.floor,
    required this.row,
    required this.seatNumber,
    required this.status,
  });

  final int id;
  final String floor;
  final String row;
  final String seatNumber;
  final String status;

  factory Seat.fromJson(JsonMap json) => Seat(
    id: integer(json['id']),
    floor: text(json['floor']),
    row: text(json['row']),
    seatNumber: text(json['seat_number']),
    status: text(json['status']),
  );
}

class SeatAssignment {
  const SeatAssignment({
    required this.id,
    required this.seatDetails,
    required this.assignedDate,
    this.releasedDate,
  });

  final int id;
  final String seatDetails;
  final String assignedDate;
  final String? releasedDate;

  factory SeatAssignment.fromJson(JsonMap json) => SeatAssignment(
    id: integer(json['id']),
    seatDetails: text(json['seat_details']),
    assignedDate: text(json['assigned_date']),
    releasedDate: optionalText(json['released_date']),
  );
}


class StudySession {
  const StudySession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.durationMinutes,
    required this.pausedMinutes,
  });

  final int id;
  final String startTime;
  final String? endTime;
  final String status;
  final int durationMinutes;
  final int pausedMinutes;

  factory StudySession.fromJson(JsonMap json) => StudySession(
    id: integer(json['id']),
    startTime: text(json['start_time']),
    endTime: optionalText(json['end_time']),
    status: text(json['status'], 'starting'),
    durationMinutes: integer(json['duration_minutes']),
    pausedMinutes: integer(json['paused_minutes']),
  );
}

class StudentNotification {
  const StudentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.sentAt,
    this.subtitle,
    this.description,
    this.linkUrl,
    this.linkButtonText,
    this.eventDate,
    required this.layout,
    this.backgroundImage,
    this.images = const [],
    this.displayMode,
  });

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? sentAt;
  final String? subtitle;
  final String? description;
  final String? linkUrl;
  final String? linkButtonText;
  final String? eventDate;
  final String layout;
  final String? backgroundImage;
  final List<String> images;
  final String? displayMode;

  factory StudentNotification.fromJson(JsonMap json) => StudentNotification(
    id: integer(json['id']),
    title: text(json['title']),
    body: text(json['body']),
    isRead: boolean(json['is_read']),
    sentAt: optionalText(json['sent_at']),
    subtitle: optionalText(json['subtitle']),
    description: optionalText(json['description']),
    linkUrl: optionalText(json['link_url']),
    linkButtonText: optionalText(json['link_button_text']),
    eventDate: optionalText(json['event_date']),
    layout: text(json['layout'], 'text_only'),
    backgroundImage: imageUrl(json['background_image']),
    images: (json['images'] as List<dynamic>?)?.map((e) => imageUrl(e) ?? '').where((e) => e.isNotEmpty).toList() ?? [],
    displayMode: optionalText(json['display_mode']),
  );
}

class LibraryInfo {
  const LibraryInfo({
    required this.name,
    this.tagline,
    this.description,
    this.featureImage,
    this.address,
    this.phonePrimary,
    this.email,
    this.rules,
    this.facilities,
    this.about,
  });

  final String name;
  final String? tagline;
  final String? description;
  final String? featureImage;
  final String? address;
  final String? phonePrimary;
  final String? email;
  final String? rules;
  final String? facilities;
  final String? about;

  factory LibraryInfo.fromJson(JsonMap json) => LibraryInfo(
    name: text(json['name'], 'Shresht Library'),
    tagline: optionalText(json['tagline']),
    description: optionalText(json['description']),
    featureImage: imageUrl(json['feature_image']),
    address: optionalText(json['address']),
    phonePrimary: optionalText(json['phone_primary']),
    email: optionalText(json['email']),
    rules: optionalText(json['rules']),
    facilities: optionalText(json['facilities']),
    about: optionalText(json['about']),
  );
}

class Facility {
  const Facility({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.iconKey,
  });

  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? iconKey;

  factory Facility.fromJson(JsonMap json) => Facility(
    id: integer(json['id']),
    name: text(json['name']),
    description: optionalText(json['description']),
    image: imageUrl(json['image']),
    iconKey: optionalText(json['icon_key']),
  );
}

class Achiever {
  const Achiever({
    required this.id,
    required this.name,
    required this.achievement,
    required this.year,
    this.goal,
    this.photo,
  });

  final int id;
  final String name;
  final String achievement;
  final int year;
  final String? goal;
  final String? photo;

  factory Achiever.fromJson(JsonMap json) => Achiever(
    id: integer(json['id']),
    name: text(json['name']),
    achievement: text(json['achievement']),
    year: integer(json['year']),
    goal: optionalText(json['goal']),
    photo: imageUrl(json['photo']),
  );
}

class ReviewRecord {
  const ReviewRecord({
    required this.id,
    required this.studentName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  final int id;
  final String studentName;
  final int rating;
  final String comment;
  final String? createdAt;

  factory ReviewRecord.fromJson(JsonMap json) => ReviewRecord(
    id: integer(json['id']),
    studentName: text(json['student_name']),
    rating: integer(json['rating']),
    comment: text(json['comment'] ?? json['text']),
    createdAt: optionalText(json['created_at']),
  );
}

class ReviewSummary {
  const ReviewSummary({required this.averageRating, required this.count});

  final double averageRating;
  final int count;

  factory ReviewSummary.fromJson(JsonMap json) => ReviewSummary(
    averageRating: decimal(json['average_rating']),
    count: integer(json['count']),
  );
}

class HomeSlider {
  const HomeSlider({
    required this.id,
    required this.title,
    required this.subtitle,
    this.image,
    required this.linkUrl,
  });

  final int id;
  final String title;
  final String subtitle;
  final String? image;
  final String linkUrl;

  factory HomeSlider.fromJson(JsonMap json) => HomeSlider(
    id: integer(json['id']),
    title: text(json['title']),
    subtitle: text(json['subtitle']),
    image: imageUrl(json['image']),
    linkUrl: text(json['link_url']),
  );
}

class LevelInfo {
  const LevelInfo({
    required this.level,
    required this.title,
    required this.badgeColor,
  });

  final int level;
  final String title;
  final String badgeColor;

  factory LevelInfo.fromJson(JsonMap json) => LevelInfo(
    level: integer(json['level']),
    title: text(json['title']),
    badgeColor: text(json['badge_color']),
  );
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.student,
    required this.totalMinutes,
    required this.hoursFormatted,
    required this.levelInfo,
  });

  final int rank;
  final StudentProfile student;
  final int totalMinutes;
  final String hoursFormatted;
  final LevelInfo levelInfo;

  factory LeaderboardEntry.fromJson(JsonMap json) => LeaderboardEntry(
    rank: integer(json['rank']),
    student: StudentProfile.fromJson(json['student'] as JsonMap? ?? const {}),
    totalMinutes: integer(json['total_minutes']),
    hoursFormatted: text(json['hours_formatted']),
    levelInfo: LevelInfo.fromJson(json['level_info'] as JsonMap? ?? const {}),
  );
}


