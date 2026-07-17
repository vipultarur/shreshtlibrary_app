import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Shresht Library'**
  String get app_title;

  /// No description provided for @leaderboard_title.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard_title;

  /// No description provided for @leaderboard_no_data.
  ///
  /// In en, this message translates to:
  /// **'No Leaderboard Data'**
  String get leaderboard_no_data;

  /// No description provided for @leaderboard_top_scholars.
  ///
  /// In en, this message translates to:
  /// **'Top Scholars'**
  String get leaderboard_top_scholars;

  /// No description provided for @leaderboard_failed_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard'**
  String get leaderboard_failed_load;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get nav_attendance;

  /// No description provided for @nav_study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get nav_study;

  /// No description provided for @nav_leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get nav_leaderboard;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @splash_tagline.
  ///
  /// In en, this message translates to:
  /// **'Your Ultimate Study Companion'**
  String get splash_tagline;

  /// No description provided for @splash_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your experience...'**
  String get splash_loading;

  /// No description provided for @lang_select_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language / भाषा चुनें'**
  String get lang_select_title;

  /// No description provided for @lang_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to continue / आगे बढ़ने के लिए अपनी पसंदीदा भाषा चुनें'**
  String get lang_select_subtitle;

  /// No description provided for @lang_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_english;

  /// No description provided for @lang_hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get lang_hindi;

  /// No description provided for @lang_gujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get lang_gujarati;

  /// No description provided for @btn_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btn_continue;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your learning journey'**
  String get login_subtitle;

  /// No description provided for @login_email_mobile_label.
  ///
  /// In en, this message translates to:
  /// **'Email / Mobile'**
  String get login_email_mobile_label;

  /// No description provided for @login_email_mobile_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter email or mobile number'**
  String get login_email_mobile_hint;

  /// No description provided for @login_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_password_hint;

  /// No description provided for @login_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get login_remember_me;

  /// No description provided for @login_forgot_pwd.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get login_forgot_pwd;

  /// No description provided for @login_btn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_btn;

  /// No description provided for @login_no_acc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get login_no_acc;

  /// No description provided for @login_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get login_sign_up;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get login_success;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_failed;

  /// No description provided for @err_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get err_required;

  /// No description provided for @err_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get err_invalid_email;

  /// No description provided for @err_invalid_mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 10 digits'**
  String get err_invalid_mobile;

  /// No description provided for @err_password_len.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get err_password_len;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us to access exclusive library features'**
  String get register_subtitle;

  /// No description provided for @register_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2: Personal Info'**
  String get register_personal_info;

  /// No description provided for @register_first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get register_first_name;

  /// No description provided for @register_first_name_hint.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get register_first_name_hint;

  /// No description provided for @register_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get register_last_name;

  /// No description provided for @register_last_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Doe'**
  String get register_last_name_hint;

  /// No description provided for @register_email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get register_email;

  /// No description provided for @register_email_hint.
  ///
  /// In en, this message translates to:
  /// **'john.doe@example.com'**
  String get register_email_hint;

  /// No description provided for @register_mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get register_mobile;

  /// No description provided for @register_mobile_hint.
  ///
  /// In en, this message translates to:
  /// **'Your mobile number'**
  String get register_mobile_hint;

  /// No description provided for @register_send_otp.
  ///
  /// In en, this message translates to:
  /// **'Send Verification OTP'**
  String get register_send_otp;

  /// No description provided for @register_verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get register_verified;

  /// No description provided for @register_otp_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'OTP (Sent to WhatsApp)'**
  String get register_otp_whatsapp;

  /// No description provided for @register_otp_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get register_otp_hint;

  /// No description provided for @register_verify_otp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get register_verify_otp;

  /// No description provided for @register_resend_otp_in.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String register_resend_otp_in(String seconds);

  /// No description provided for @register_resend_otp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get register_resend_otp;

  /// No description provided for @register_step2_header.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2: Profile Details'**
  String get register_step2_header;

  /// No description provided for @register_step2_subheader.
  ///
  /// In en, this message translates to:
  /// **'We need a little more info to get you started'**
  String get register_step2_subheader;

  /// No description provided for @register_dob.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get register_dob;

  /// No description provided for @register_dob_hint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get register_dob_hint;

  /// No description provided for @register_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get register_gender;

  /// No description provided for @register_gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get register_gender_male;

  /// No description provided for @register_gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get register_gender_female;

  /// No description provided for @register_goal.
  ///
  /// In en, this message translates to:
  /// **'Study Goal'**
  String get register_goal;

  /// No description provided for @register_pwd.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get register_pwd;

  /// No description provided for @register_confirm_pwd.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get register_confirm_pwd;

  /// No description provided for @register_confirm_pwd_hint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get register_confirm_pwd_hint;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get register_success;

  /// No description provided for @register_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get register_failed;

  /// No description provided for @register_already_have_acc.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get register_already_have_acc;

  /// No description provided for @register_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get register_sign_in;

  /// No description provided for @register_passwords_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get register_passwords_mismatch;

  /// No description provided for @home_good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get home_good_morning;

  /// No description provided for @home_holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get home_holiday;

  /// No description provided for @home_holiday_desc.
  ///
  /// In en, this message translates to:
  /// **'Attendance is closed today due to a holiday.'**
  String get home_holiday_desc;

  /// No description provided for @home_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get home_ok;

  /// No description provided for @home_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get home_scan;

  /// No description provided for @home_achievers.
  ///
  /// In en, this message translates to:
  /// **'Achievers'**
  String get home_achievers;

  /// No description provided for @home_no_achievers.
  ///
  /// In en, this message translates to:
  /// **'No achievers yet.'**
  String get home_no_achievers;

  /// No description provided for @home_facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get home_facilities;

  /// No description provided for @home_no_facilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities available.'**
  String get home_no_facilities;

  /// No description provided for @home_pending_activation.
  ///
  /// In en, this message translates to:
  /// **'Pending Activation'**
  String get home_pending_activation;

  /// No description provided for @home_pending_activation_desc.
  ///
  /// In en, this message translates to:
  /// **'Please purchase a plan or contact staff to activate.'**
  String get home_pending_activation_desc;

  /// No description provided for @home_plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get home_plans;

  /// No description provided for @home_account_suspended.
  ///
  /// In en, this message translates to:
  /// **'Account Suspended'**
  String get home_account_suspended;

  /// No description provided for @home_account_suspended_desc.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended by the staffistrator.'**
  String get home_account_suspended_desc;

  /// No description provided for @home_membership_expired.
  ///
  /// In en, this message translates to:
  /// **'Membership Expired'**
  String get home_membership_expired;

  /// No description provided for @home_membership_expired_desc.
  ///
  /// In en, this message translates to:
  /// **'Your membership has expired. Please renew to continue accessing library features.'**
  String get home_membership_expired_desc;

  /// No description provided for @home_renew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get home_renew;

  /// No description provided for @home_failed_load_user.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user info'**
  String get home_failed_load_user;

  /// No description provided for @attendance_title.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance_title;

  /// No description provided for @attendance_checkout_success.
  ///
  /// In en, this message translates to:
  /// **'Checked out successfully'**
  String get attendance_checkout_success;

  /// No description provided for @attendance_check_out.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get attendance_check_out;

  /// No description provided for @attendance_wait.
  ///
  /// In en, this message translates to:
  /// **'Wait...'**
  String get attendance_wait;

  /// No description provided for @attendance_days_present.
  ///
  /// In en, this message translates to:
  /// **'Days Present'**
  String get attendance_days_present;

  /// No description provided for @attendance_days_absent.
  ///
  /// In en, this message translates to:
  /// **'Days Absent'**
  String get attendance_days_absent;

  /// No description provided for @attendance_late_marks.
  ///
  /// In en, this message translates to:
  /// **'Late Marks'**
  String get attendance_late_marks;

  /// No description provided for @attendance_monthly_study.
  ///
  /// In en, this message translates to:
  /// **'Monthly Study Hours'**
  String get attendance_monthly_study;

  /// No description provided for @attendance_today_study.
  ///
  /// In en, this message translates to:
  /// **'Today Study'**
  String get attendance_today_study;

  /// No description provided for @attendance_check_in.
  ///
  /// In en, this message translates to:
  /// **'Check-In'**
  String get attendance_check_in;

  /// No description provided for @attendance_check_out_lbl.
  ///
  /// In en, this message translates to:
  /// **'Check-Out'**
  String get attendance_check_out_lbl;

  /// No description provided for @study_area.
  ///
  /// In en, this message translates to:
  /// **'Study Area'**
  String get study_area;

  /// No description provided for @study_tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get study_tracker;

  /// No description provided for @study_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get study_history;

  /// No description provided for @study_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get study_analytics;

  /// No description provided for @study_not_checked_in.
  ///
  /// In en, this message translates to:
  /// **'Not Checked In'**
  String get study_not_checked_in;

  /// No description provided for @study_not_checked_in_desc.
  ///
  /// In en, this message translates to:
  /// **'Please check in at the library to start an anti-distraction study session.'**
  String get study_not_checked_in_desc;

  /// No description provided for @study_ready_focus.
  ///
  /// In en, this message translates to:
  /// **'Ready to Focus?'**
  String get study_ready_focus;

  /// No description provided for @study_ready_focus_desc.
  ///
  /// In en, this message translates to:
  /// **'Start an anti-distraction study session. If you move your phone, tracking pauses.'**
  String get study_ready_focus_desc;

  /// No description provided for @study_start_btn.
  ///
  /// In en, this message translates to:
  /// **'Start New Session'**
  String get study_start_btn;

  /// No description provided for @study_paused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get study_paused;

  /// No description provided for @study_total_paused.
  ///
  /// In en, this message translates to:
  /// **'Total Paused: {time}'**
  String study_total_paused(String time);

  /// No description provided for @study_quit_btn.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get study_quit_btn;

  /// No description provided for @study_history_sessions.
  ///
  /// In en, this message translates to:
  /// **'Total sessions in memory: {count}'**
  String study_history_sessions(int count);

  /// No description provided for @study_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No Study Sessions on this date'**
  String get study_history_empty;

  /// No description provided for @study_history_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Take a break, or start a new session!'**
  String get study_history_empty_desc;

  /// No description provided for @study_history_started_at.
  ///
  /// In en, this message translates to:
  /// **'Started at {time}'**
  String study_history_started_at(String time);

  /// No description provided for @study_history_studied.
  ///
  /// In en, this message translates to:
  /// **'Studied'**
  String get study_history_studied;

  /// No description provided for @study_failed_chart.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chart'**
  String get study_failed_chart;

  /// No description provided for @study_failed_history.
  ///
  /// In en, this message translates to:
  /// **'Failed to load history'**
  String get study_failed_history;

  /// No description provided for @study_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get study_no_data;

  /// No description provided for @study_total_time.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get study_total_time;

  /// No description provided for @study_avg_daily.
  ///
  /// In en, this message translates to:
  /// **'Avg Daily'**
  String get study_avg_daily;

  /// No description provided for @study_avg_weekly.
  ///
  /// In en, this message translates to:
  /// **'Avg Weekly'**
  String get study_avg_weekly;

  /// No description provided for @study_most_productive.
  ///
  /// In en, this message translates to:
  /// **'Most Productive'**
  String get study_most_productive;

  /// No description provided for @study_unknown_date.
  ///
  /// In en, this message translates to:
  /// **'Unknown Date'**
  String get study_unknown_date;

  /// No description provided for @study_analytics_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get study_analytics_week;

  /// No description provided for @study_analytics_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get study_analytics_month;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get profile_select_language;

  /// No description provided for @forgot_pwd_title.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get forgot_pwd_title;

  /// No description provided for @forgot_pwd_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password securely'**
  String get forgot_pwd_subtitle;

  /// No description provided for @forgot_pwd_header.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_pwd_header;

  /// No description provided for @forgot_pwd_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address or mobile number. We will send you a reset link or OTP to reset your password.'**
  String get forgot_pwd_desc;

  /// No description provided for @forgot_pwd_label_input.
  ///
  /// In en, this message translates to:
  /// **'Email Address or Mobile Number'**
  String get forgot_pwd_label_input;

  /// No description provided for @forgot_pwd_hint_input.
  ///
  /// In en, this message translates to:
  /// **'john.doe@example.com or 9999999999'**
  String get forgot_pwd_hint_input;

  /// No description provided for @forgot_pwd_btn_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String forgot_pwd_btn_resend(String seconds);

  /// No description provided for @forgot_pwd_btn_send.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link or OTP'**
  String get forgot_pwd_btn_send;

  /// No description provided for @forgot_pwd_or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get forgot_pwd_or;

  /// No description provided for @forgot_pwd_token_desc.
  ///
  /// In en, this message translates to:
  /// **'Already have a token or OTP? Enter it below with your new password.'**
  String get forgot_pwd_token_desc;

  /// No description provided for @forgot_pwd_label_token.
  ///
  /// In en, this message translates to:
  /// **'Reset Token or OTP'**
  String get forgot_pwd_label_token;

  /// No description provided for @forgot_pwd_hint_token.
  ///
  /// In en, this message translates to:
  /// **'Enter the token or OTP'**
  String get forgot_pwd_hint_token;

  /// No description provided for @forgot_pwd_label_new_pwd.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get forgot_pwd_label_new_pwd;

  /// No description provided for @forgot_pwd_btn_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgot_pwd_btn_reset;

  /// No description provided for @forgot_pwd_back_to_signin.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get forgot_pwd_back_to_signin;

  /// No description provided for @forgot_pwd_snack_email.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email.'**
  String get forgot_pwd_snack_email;

  /// No description provided for @forgot_pwd_snack_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Password reset OTP sent to your WhatsApp.'**
  String get forgot_pwd_snack_whatsapp;

  /// No description provided for @forgot_pwd_snack_success.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now login.'**
  String get forgot_pwd_snack_success;

  /// No description provided for @referral_code_valid.
  ///
  /// In en, this message translates to:
  /// **'Referral code is valid.'**
  String get referral_code_valid;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profile_updated;

  /// No description provided for @profile_photo_updated.
  ///
  /// In en, this message translates to:
  /// **'Photo updated.'**
  String get profile_photo_updated;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed: {message}'**
  String payment_failed(String message);

  /// No description provided for @payment_external_wallet.
  ///
  /// In en, this message translates to:
  /// **'External Wallet Selected: {wallet}'**
  String payment_external_wallet(String wallet);

  /// No description provided for @payment_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Online payments are currently unavailable.'**
  String get payment_unavailable;

  /// No description provided for @payment_razorpay_error.
  ///
  /// In en, this message translates to:
  /// **'Error launching Razorpay.'**
  String get payment_razorpay_error;

  /// No description provided for @payment_select_plan.
  ///
  /// In en, this message translates to:
  /// **'Select a membership plan.'**
  String get payment_select_plan;

  /// No description provided for @payment_submitted.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted for staff verification.'**
  String get payment_submitted;

  /// No description provided for @noti_marked_read.
  ///
  /// In en, this message translates to:
  /// **'Marked as read.'**
  String get noti_marked_read;

  /// No description provided for @noti_all_marked_read.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read.'**
  String get noti_all_marked_read;

  /// No description provided for @noti_failed_mark.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark as read.'**
  String get noti_failed_mark;

  /// No description provided for @noti_all_cleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared.'**
  String get noti_all_cleared;

  /// No description provided for @noti_failed_clear.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear notifications.'**
  String get noti_failed_clear;

  /// No description provided for @noti_failed_delete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete notification.'**
  String get noti_failed_delete;

  /// No description provided for @review_submitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted for approval.'**
  String get review_submitted;

  /// No description provided for @register_snack_otp_success.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your WhatsApp successfully!'**
  String get register_snack_otp_success;

  /// No description provided for @register_snack_mobile_verified.
  ///
  /// In en, this message translates to:
  /// **'Mobile number verified successfully!'**
  String get register_snack_mobile_verified;

  /// No description provided for @register_snack_fix_step1.
  ///
  /// In en, this message translates to:
  /// **'Please fix errors in Step 1'**
  String get register_snack_fix_step1;

  /// No description provided for @register_snack_fill_step1.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields in Step 1'**
  String get register_snack_fill_step1;

  /// No description provided for @register_snack_verify_mobile.
  ///
  /// In en, this message translates to:
  /// **'Please verify your mobile number first.'**
  String get register_snack_verify_mobile;

  /// No description provided for @register_snack_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get register_snack_success;

  /// No description provided for @register_parent_mobile.
  ///
  /// In en, this message translates to:
  /// **'Parent Mobile'**
  String get register_parent_mobile;

  /// No description provided for @register_parent_mobile_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get register_parent_mobile_hint;

  /// No description provided for @register_full_address.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get register_full_address;

  /// No description provided for @register_full_address_hint.
  ///
  /// In en, this message translates to:
  /// **'Your Home Address'**
  String get register_full_address_hint;

  /// No description provided for @register_back_step1.
  ///
  /// In en, this message translates to:
  /// **'Back to Step 1'**
  String get register_back_step1;

  /// No description provided for @register_err_invalid_mobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get register_err_invalid_mobile;

  /// No description provided for @register_err_otp_required.
  ///
  /// In en, this message translates to:
  /// **'OTP is required.'**
  String get register_err_otp_required;

  /// No description provided for @register_err_invalid_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit OTP.'**
  String get register_err_invalid_otp;

  /// No description provided for @register_err_first_name_required.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get register_err_first_name_required;

  /// No description provided for @register_err_last_name_required.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get register_err_last_name_required;

  /// No description provided for @register_err_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get register_err_email_required;

  /// No description provided for @register_err_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get register_err_email_invalid;

  /// No description provided for @register_err_mobile_required.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get register_err_mobile_required;

  /// No description provided for @register_err_mobile_invalid.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be exactly 10 digits.'**
  String get register_err_mobile_invalid;

  /// No description provided for @register_err_dob_required.
  ///
  /// In en, this message translates to:
  /// **'Birthday is required'**
  String get register_err_dob_required;

  /// No description provided for @register_err_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get register_err_password_required;

  /// No description provided for @register_err_password_len.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get register_err_password_len;

  /// No description provided for @register_err_confirm_password_required.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get register_err_confirm_password_required;

  /// No description provided for @register_err_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get register_err_password_mismatch;

  /// No description provided for @register_err_mobile_exists.
  ///
  /// In en, this message translates to:
  /// **'Mobile number already exists.'**
  String get register_err_mobile_exists;

  /// No description provided for @register_err_email_exists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists.'**
  String get register_err_email_exists;

  /// No description provided for @referral_apply_label.
  ///
  /// In en, this message translates to:
  /// **'Apply referral code'**
  String get referral_apply_label;

  /// No description provided for @referral_btn_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get referral_btn_apply;

  /// No description provided for @profile_personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profile_personal_info;

  /// No description provided for @profile_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get profile_first_name;

  /// No description provided for @profile_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get profile_last_name;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_goal.
  ///
  /// In en, this message translates to:
  /// **'Goal (e.g. UPSC, SSC)'**
  String get profile_goal;

  /// No description provided for @profile_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (YYYY-MM-DD)'**
  String get profile_dob;

  /// No description provided for @profile_parent_mobile.
  ///
  /// In en, this message translates to:
  /// **'Parent Mobile Number'**
  String get profile_parent_mobile;

  /// No description provided for @profile_caste.
  ///
  /// In en, this message translates to:
  /// **'Caste'**
  String get profile_caste;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profile_save_changes;

  /// No description provided for @payment_label_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get payment_label_plan;

  /// No description provided for @payment_label_mode.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get payment_label_mode;

  /// No description provided for @payment_label_transaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID / UPI reference'**
  String get payment_label_transaction;

  /// No description provided for @payment_btn_manual.
  ///
  /// In en, this message translates to:
  /// **'Submit Manual'**
  String get payment_btn_manual;

  /// No description provided for @payment_btn_online.
  ///
  /// In en, this message translates to:
  /// **'Pay Online'**
  String get payment_btn_online;

  /// No description provided for @payment_noti_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Submitted'**
  String get payment_noti_title;

  /// No description provided for @payment_noti_body.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been submitted for verification.'**
  String get payment_noti_body;

  /// No description provided for @noti_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get noti_title;

  /// No description provided for @noti_btn_mark_read.
  ///
  /// In en, this message translates to:
  /// **'Mark Read'**
  String get noti_btn_mark_read;

  /// No description provided for @noti_btn_view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get noti_btn_view_details;

  /// No description provided for @noti_btn_mark_all_read.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get noti_btn_mark_all_read;

  /// No description provided for @noti_btn_clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get noti_btn_clear_all;

  /// No description provided for @noti_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noti_empty;

  /// No description provided for @review_stars.
  ///
  /// In en, this message translates to:
  /// **'{rating} stars'**
  String review_stars(int rating);

  /// No description provided for @review_label_rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get review_label_rating;

  /// No description provided for @review_label_review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review_label_review;

  /// No description provided for @review_btn_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get review_btn_submit;

  /// No description provided for @maintenance_title.
  ///
  /// In en, this message translates to:
  /// **'We\'re Under Maintenance'**
  String get maintenance_title;

  /// No description provided for @maintenance_desc.
  ///
  /// In en, this message translates to:
  /// **'Sorry for the inconvenience. We\'re performing some updates and maintenance on our servers to improve your experience. Please check back later.'**
  String get maintenance_desc;

  /// No description provided for @btn_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get btn_refresh;

  /// No description provided for @profile_section_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile_section_account;

  /// No description provided for @profile_tile_info.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get profile_tile_info;

  /// No description provided for @profile_tile_id_card.
  ///
  /// In en, this message translates to:
  /// **'Digital ID Card'**
  String get profile_tile_id_card;

  /// No description provided for @profile_section_subscription.
  ///
  /// In en, this message translates to:
  /// **'Accounts & Subscription'**
  String get profile_section_subscription;

  /// No description provided for @profile_tile_payments.
  ///
  /// In en, this message translates to:
  /// **'My Payments'**
  String get profile_tile_payments;

  /// No description provided for @profile_tile_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_tile_notifications;

  /// No description provided for @profile_tile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_tile_logout;

  /// No description provided for @profile_no_email.
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get profile_no_email;

  /// No description provided for @profile_edit_btn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profile_edit_btn;

  /// No description provided for @profile_label_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get profile_label_loading;

  /// No description provided for @profile_label_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_label_name;

  /// No description provided for @profile_label_mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get profile_label_mobile;

  /// No description provided for @profile_label_goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get profile_label_goal;

  /// No description provided for @profile_tile_referrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get profile_tile_referrals;

  /// No description provided for @profile_referral_program.
  ///
  /// In en, this message translates to:
  /// **'Referral Program'**
  String get profile_referral_program;

  /// No description provided for @profile_your_referral_code.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get profile_your_referral_code;

  /// No description provided for @profile_referral_used_by.
  ///
  /// In en, this message translates to:
  /// **'Used by {count} students'**
  String profile_referral_used_by(int count);

  /// No description provided for @profile_referral_history.
  ///
  /// In en, this message translates to:
  /// **'Referral History'**
  String get profile_referral_history;

  /// No description provided for @profile_no_referral_history.
  ///
  /// In en, this message translates to:
  /// **'No referral history yet.'**
  String get profile_no_referral_history;

  /// No description provided for @library_title.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library_title;

  /// No description provided for @library_details.
  ///
  /// In en, this message translates to:
  /// **'Library Details'**
  String get library_details;

  /// No description provided for @library_label_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get library_label_address;

  /// No description provided for @library_label_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get library_label_phone;

  /// No description provided for @library_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get library_label_email;

  /// No description provided for @library_label_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get library_label_whatsapp;

  /// No description provided for @library_label_emergency_contact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get library_label_emergency_contact;

  /// No description provided for @library_label_working_hours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get library_label_working_hours;

  /// No description provided for @library_weekly_off.
  ///
  /// In en, this message translates to:
  /// **'(Off: {day})'**
  String library_weekly_off(String day);

  /// No description provided for @library_label_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get library_label_website;

  /// No description provided for @library_capacity_stats.
  ///
  /// In en, this message translates to:
  /// **'Library Capacity & Stats'**
  String get library_capacity_stats;

  /// No description provided for @library_total_capacity.
  ///
  /// In en, this message translates to:
  /// **'Total Capacity: {count} Seats'**
  String library_total_capacity(int count);

  /// No description provided for @library_currently_available.
  ///
  /// In en, this message translates to:
  /// **'Currently Available: {count} Seats'**
  String library_currently_available(int count);

  /// No description provided for @library_about_us.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get library_about_us;

  /// No description provided for @library_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get library_history;

  /// No description provided for @library_mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get library_mission;

  /// No description provided for @library_vision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get library_vision;

  /// No description provided for @library_services_courses.
  ///
  /// In en, this message translates to:
  /// **'Services & Courses'**
  String get library_services_courses;

  /// No description provided for @library_services_offered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get library_services_offered;

  /// No description provided for @library_courses_supported.
  ///
  /// In en, this message translates to:
  /// **'Courses Supported'**
  String get library_courses_supported;

  /// No description provided for @library_membership_info.
  ///
  /// In en, this message translates to:
  /// **'Membership Information'**
  String get library_membership_info;

  /// No description provided for @library_details_lbl.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get library_details_lbl;

  /// No description provided for @library_benefits_lbl.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get library_benefits_lbl;

  /// No description provided for @library_registration_process.
  ///
  /// In en, this message translates to:
  /// **'Registration Process'**
  String get library_registration_process;

  /// No description provided for @library_required_documents.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get library_required_documents;

  /// No description provided for @library_rules_guidelines.
  ///
  /// In en, this message translates to:
  /// **'Rules & Guidelines'**
  String get library_rules_guidelines;

  /// No description provided for @library_rules.
  ///
  /// In en, this message translates to:
  /// **'Library Rules'**
  String get library_rules;

  /// No description provided for @library_faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get library_faq;

  /// No description provided for @library_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get library_location;

  /// No description provided for @library_get_directions.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get library_get_directions;

  /// No description provided for @library_facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get library_facilities;

  /// No description provided for @library_no_facilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities listed.'**
  String get library_no_facilities;

  /// No description provided for @library_facility_fallback.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get library_facility_fallback;

  /// No description provided for @library_featured_achievers.
  ///
  /// In en, this message translates to:
  /// **'Featured Achievers'**
  String get library_featured_achievers;

  /// No description provided for @library_no_featured_achievers.
  ///
  /// In en, this message translates to:
  /// **'No featured achievers yet.'**
  String get library_no_featured_achievers;

  /// No description provided for @library_all_achievers_title.
  ///
  /// In en, this message translates to:
  /// **'All Achievers'**
  String get library_all_achievers_title;

  /// No description provided for @library_no_achievers.
  ///
  /// In en, this message translates to:
  /// **'No achievers yet.'**
  String get library_no_achievers;

  /// No description provided for @library_gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get library_gallery;

  /// No description provided for @library_no_gallery_images.
  ///
  /// In en, this message translates to:
  /// **'No images yet.'**
  String get library_no_gallery_images;

  /// No description provided for @library_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get library_reviews;

  /// No description provided for @library_reviews_summary.
  ///
  /// In en, this message translates to:
  /// **'{avg} average from {count} reviews'**
  String library_reviews_summary(String avg, int count);

  /// No description provided for @library_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get library_no_reviews;

  /// No description provided for @library_social_media.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get library_social_media;

  /// No description provided for @lib_title_achievers.
  ///
  /// In en, this message translates to:
  /// **'All Achievers'**
  String get lib_title_achievers;

  /// No description provided for @lib_no_achievers.
  ///
  /// In en, this message translates to:
  /// **'No achievers listed.'**
  String get lib_no_achievers;

  /// No description provided for @lib_title_facilities.
  ///
  /// In en, this message translates to:
  /// **'All Facilities'**
  String get lib_title_facilities;

  /// No description provided for @lib_no_facilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities listed.'**
  String get lib_no_facilities;

  /// No description provided for @err_failed_load_permissions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load permissions.'**
  String get err_failed_load_permissions;

  /// No description provided for @err_check_connection.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get err_check_connection;

  /// No description provided for @err_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get err_no_internet;

  /// No description provided for @btn_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btn_retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
