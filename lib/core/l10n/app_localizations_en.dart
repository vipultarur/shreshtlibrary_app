// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Shresht Library';

  @override
  String get leaderboard_title => 'Leaderboard';

  @override
  String get leaderboard_no_data => 'No Leaderboard Data';

  @override
  String get leaderboard_top_scholars => 'Top Scholars';

  @override
  String get leaderboard_failed_load => 'Failed to load leaderboard';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_attendance => 'Attendance';

  @override
  String get nav_study => 'Study';

  @override
  String get nav_leaderboard => 'Leaderboard';

  @override
  String get nav_profile => 'Profile';

  @override
  String get splash_tagline => 'Your Ultimate Study Companion';

  @override
  String get splash_loading => 'Loading your experience...';

  @override
  String get lang_select_title => 'Choose Language / भाषा चुनें';

  @override
  String get lang_select_subtitle =>
      'Select your preferred language to continue / आगे बढ़ने के लिए अपनी पसंदीदा भाषा चुनें';

  @override
  String get lang_english => 'English';

  @override
  String get lang_hindi => 'हिन्दी';

  @override
  String get lang_gujarati => 'ગુજરાતી';

  @override
  String get btn_continue => 'Continue';

  @override
  String get login_title => 'Welcome Back';

  @override
  String get login_subtitle => 'Sign in to continue your learning journey';

  @override
  String get login_email_mobile_label => 'Email / Mobile';

  @override
  String get login_email_mobile_hint => 'Enter email or mobile number';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_remember_me => 'Remember me';

  @override
  String get login_forgot_pwd => 'Forgot Password?';

  @override
  String get login_btn => 'Sign In';

  @override
  String get login_no_acc => 'Don\'t have an account? ';

  @override
  String get login_sign_up => 'Sign Up';

  @override
  String get login_success => 'Login successful!';

  @override
  String get login_failed => 'Login failed';

  @override
  String get err_required => 'This field is required';

  @override
  String get err_invalid_email => 'Please enter a valid email address';

  @override
  String get err_invalid_mobile => 'Mobile number must be 10 digits';

  @override
  String get err_password_len => 'Password must be at least 6 characters';

  @override
  String get register_title => 'Create Account';

  @override
  String get register_subtitle =>
      'Join us to access exclusive library features';

  @override
  String get register_personal_info => 'Step 1 of 2: Personal Info';

  @override
  String get register_first_name => 'First Name';

  @override
  String get register_first_name_hint => 'John';

  @override
  String get register_last_name => 'Last Name';

  @override
  String get register_last_name_hint => 'Doe';

  @override
  String get register_email => 'Email Address';

  @override
  String get register_email_hint => 'john.doe@example.com';

  @override
  String get register_mobile => 'Mobile Number';

  @override
  String get register_mobile_hint => 'Your mobile number';

  @override
  String get register_send_otp => 'Send Verification OTP';

  @override
  String get register_verified => 'Verified';

  @override
  String get register_otp_whatsapp => 'OTP (Sent to WhatsApp)';

  @override
  String get register_otp_hint => 'Enter 6-digit OTP';

  @override
  String get register_verify_otp => 'Verify OTP';

  @override
  String register_resend_otp_in(String seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get register_resend_otp => 'Resend OTP';

  @override
  String get register_step2_header => 'Step 2 of 2: Profile Details';

  @override
  String get register_step2_subheader =>
      'We need a little more info to get you started';

  @override
  String get register_dob => 'Birthday';

  @override
  String get register_dob_hint => 'YYYY-MM-DD';

  @override
  String get register_gender => 'Gender';

  @override
  String get register_gender_male => 'Male';

  @override
  String get register_gender_female => 'Female';

  @override
  String get register_goal => 'Study Goal';

  @override
  String get register_pwd => 'Password';

  @override
  String get register_confirm_pwd => 'Confirm Password';

  @override
  String get register_confirm_pwd_hint => 'Re-enter password';

  @override
  String get register_success => 'Registration successful!';

  @override
  String get register_failed => 'Registration failed';

  @override
  String get register_already_have_acc => 'Already have an account? ';

  @override
  String get register_sign_in => 'Sign In';

  @override
  String get register_passwords_mismatch => 'Passwords do not match';

  @override
  String get home_good_morning => 'Good Morning';

  @override
  String get home_holiday => 'Holiday';

  @override
  String get home_holiday_desc =>
      'Attendance is closed today due to a holiday.';

  @override
  String get home_ok => 'OK';

  @override
  String get home_scan => 'Scan';

  @override
  String get home_achievers => 'Achievers';

  @override
  String get home_no_achievers => 'No achievers yet.';

  @override
  String get home_facilities => 'Facilities';

  @override
  String get home_no_facilities => 'No facilities available.';

  @override
  String get home_pending_activation => 'Pending Activation';

  @override
  String get home_pending_activation_desc =>
      'Please purchase a plan or contact admin to activate.';

  @override
  String get home_plans => 'Plans';

  @override
  String get home_account_suspended => 'Account Suspended';

  @override
  String get home_account_suspended_desc =>
      'Your account has been suspended by the administrator.';

  @override
  String get home_membership_expired => 'Membership Expired';

  @override
  String get home_membership_expired_desc =>
      'Your membership has expired. Please renew to continue accessing library features.';

  @override
  String get home_renew => 'Renew';

  @override
  String get home_failed_load_user => 'Failed to load user info';

  @override
  String get attendance_title => 'Attendance';

  @override
  String get attendance_checkout_success => 'Checked out successfully';

  @override
  String get attendance_check_out => 'Check Out';

  @override
  String get attendance_wait => 'Wait...';

  @override
  String get attendance_days_present => 'Days Present';

  @override
  String get attendance_days_absent => 'Days Absent';

  @override
  String get attendance_late_marks => 'Late Marks';

  @override
  String get attendance_monthly_study => 'Monthly Study Hours';

  @override
  String get attendance_today_study => 'Today Study';

  @override
  String get attendance_check_in => 'Check-In';

  @override
  String get attendance_check_out_lbl => 'Check-Out';

  @override
  String get study_area => 'Study Area';

  @override
  String get study_tracker => 'Tracker';

  @override
  String get study_history => 'History';

  @override
  String get study_analytics => 'Analytics';

  @override
  String get study_not_checked_in => 'Not Checked In';

  @override
  String get study_not_checked_in_desc =>
      'Please check in at the library to start an anti-distraction study session.';

  @override
  String get study_ready_focus => 'Ready to Focus?';

  @override
  String get study_ready_focus_desc =>
      'Start an anti-distraction study session. If you move your phone, tracking pauses.';

  @override
  String get study_start_btn => 'Start New Session';

  @override
  String get study_paused => 'PAUSED';

  @override
  String study_total_paused(String time) {
    return 'Total Paused: $time';
  }

  @override
  String get study_quit_btn => 'Quit';

  @override
  String study_history_sessions(int count) {
    return 'Total sessions in memory: $count';
  }

  @override
  String get study_history_empty => 'No Study Sessions on this date';

  @override
  String get study_history_empty_desc =>
      'Take a break, or start a new session!';

  @override
  String study_history_started_at(String time) {
    return 'Started at $time';
  }

  @override
  String get study_history_studied => 'Studied';

  @override
  String get study_failed_chart => 'Failed to load chart';

  @override
  String get study_failed_history => 'Failed to load history';

  @override
  String get study_no_data => 'No data available';

  @override
  String get study_total_time => 'Total Time';

  @override
  String get study_avg_daily => 'Avg Daily';

  @override
  String get study_avg_weekly => 'Avg Weekly';

  @override
  String get study_most_productive => 'Most Productive';

  @override
  String get study_unknown_date => 'Unknown Date';

  @override
  String get study_analytics_week => 'Week';

  @override
  String get study_analytics_month => 'Month';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_language => 'Language';

  @override
  String get profile_select_language => 'Select Language';

  @override
  String get forgot_pwd_title => 'Recovery';

  @override
  String get forgot_pwd_subtitle => 'Reset your password securely';

  @override
  String get forgot_pwd_header => 'Forgot Password?';

  @override
  String get forgot_pwd_desc =>
      'Enter your registered email address or mobile number. We will send you a reset link or OTP to reset your password.';

  @override
  String get forgot_pwd_label_input => 'Email Address or Mobile Number';

  @override
  String get forgot_pwd_hint_input => 'john.doe@example.com or 9999999999';

  @override
  String forgot_pwd_btn_resend(String seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get forgot_pwd_btn_send => 'Send Reset Link or OTP';

  @override
  String get forgot_pwd_or => 'OR';

  @override
  String get forgot_pwd_token_desc =>
      'Already have a token or OTP? Enter it below with your new password.';

  @override
  String get forgot_pwd_label_token => 'Reset Token or OTP';

  @override
  String get forgot_pwd_hint_token => 'Enter the token or OTP';

  @override
  String get forgot_pwd_label_new_pwd => 'New Password';

  @override
  String get forgot_pwd_btn_reset => 'Reset Password';

  @override
  String get forgot_pwd_back_to_signin => 'Back to Sign In';

  @override
  String get forgot_pwd_snack_email =>
      'Password reset link sent to your email.';

  @override
  String get forgot_pwd_snack_whatsapp =>
      'Password reset OTP sent to your WhatsApp.';

  @override
  String get forgot_pwd_snack_success =>
      'Password reset successfully. You can now login.';

  @override
  String get referral_code_valid => 'Referral code is valid.';

  @override
  String get profile_updated => 'Profile updated.';

  @override
  String get profile_photo_updated => 'Photo updated.';

  @override
  String payment_failed(String message) {
    return 'Payment Failed: $message';
  }

  @override
  String payment_external_wallet(String wallet) {
    return 'External Wallet Selected: $wallet';
  }

  @override
  String get payment_unavailable =>
      'Online payments are currently unavailable.';

  @override
  String get payment_razorpay_error => 'Error launching Razorpay.';

  @override
  String get payment_select_plan => 'Select a membership plan.';

  @override
  String get payment_submitted => 'Payment submitted for admin verification.';

  @override
  String get noti_marked_read => 'Marked as read.';

  @override
  String get noti_all_marked_read => 'All notifications marked as read.';

  @override
  String get noti_failed_mark => 'Failed to mark as read.';

  @override
  String get noti_all_cleared => 'All notifications cleared.';

  @override
  String get noti_failed_clear => 'Failed to clear notifications.';

  @override
  String get noti_failed_delete => 'Failed to delete notification.';

  @override
  String get review_submitted => 'Review submitted for approval.';

  @override
  String get register_snack_otp_success =>
      'OTP sent to your WhatsApp successfully!';

  @override
  String get register_snack_mobile_verified =>
      'Mobile number verified successfully!';

  @override
  String get register_snack_fix_step1 => 'Please fix errors in Step 1';

  @override
  String get register_snack_fill_step1 =>
      'Please fill all required fields in Step 1';

  @override
  String get register_snack_verify_mobile =>
      'Please verify your mobile number first.';

  @override
  String get register_snack_success => 'Registration successful!';

  @override
  String get register_parent_mobile => 'Parent Mobile';

  @override
  String get register_parent_mobile_hint => 'Optional';

  @override
  String get register_full_address => 'Full Address';

  @override
  String get register_full_address_hint => 'Your Home Address';

  @override
  String get register_back_step1 => 'Back to Step 1';

  @override
  String get register_err_invalid_mobile =>
      'Enter a valid 10-digit mobile number.';

  @override
  String get register_err_otp_required => 'OTP is required.';

  @override
  String get register_err_invalid_otp => 'Enter a valid 6-digit OTP.';

  @override
  String get register_err_first_name_required => 'First name is required';

  @override
  String get register_err_last_name_required => 'Last name is required';

  @override
  String get register_err_email_required => 'Email is required';

  @override
  String get register_err_email_invalid =>
      'Please enter a valid email address.';

  @override
  String get register_err_mobile_required => 'Mobile number is required';

  @override
  String get register_err_mobile_invalid =>
      'Mobile number must be exactly 10 digits.';

  @override
  String get register_err_dob_required => 'Birthday is required';

  @override
  String get register_err_password_required => 'Password is required';

  @override
  String get register_err_password_len =>
      'Password must be at least 6 characters long';

  @override
  String get register_err_confirm_password_required =>
      'Confirm password is required';

  @override
  String get register_err_password_mismatch => 'Passwords do not match';

  @override
  String get register_err_mobile_exists => 'Mobile number already exists.';

  @override
  String get register_err_email_exists => 'Email already exists.';

  @override
  String get referral_apply_label => 'Apply referral code';

  @override
  String get referral_btn_apply => 'Apply';

  @override
  String get profile_personal_info => 'Personal Information';

  @override
  String get profile_first_name => 'First name';

  @override
  String get profile_last_name => 'Last name';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_goal => 'Goal (e.g. UPSC, SSC)';

  @override
  String get profile_dob => 'Date of Birth (YYYY-MM-DD)';

  @override
  String get profile_parent_mobile => 'Parent Mobile Number';

  @override
  String get profile_caste => 'Caste';

  @override
  String get profile_address => 'Address';

  @override
  String get profile_save_changes => 'Save Changes';

  @override
  String get payment_label_plan => 'Plan';

  @override
  String get payment_label_mode => 'Payment mode';

  @override
  String get payment_label_transaction => 'Transaction ID / UPI reference';

  @override
  String get payment_btn_manual => 'Submit Manual';

  @override
  String get payment_btn_online => 'Pay Online';

  @override
  String get payment_noti_title => 'Payment Submitted';

  @override
  String get payment_noti_body =>
      'Your payment has been submitted for verification.';

  @override
  String get noti_title => 'Notifications';

  @override
  String get noti_btn_mark_read => 'Mark Read';

  @override
  String get noti_btn_view_details => 'View Details';

  @override
  String get noti_btn_mark_all_read => 'Mark All Read';

  @override
  String get noti_btn_clear_all => 'Clear All';

  @override
  String get noti_empty => 'No notifications yet.';

  @override
  String review_stars(int rating) {
    return '$rating stars';
  }

  @override
  String get review_label_rating => 'Rating';

  @override
  String get review_label_review => 'Review';

  @override
  String get review_btn_submit => 'Submit review';

  @override
  String get maintenance_title => 'We\'re Under Maintenance';

  @override
  String get maintenance_desc =>
      'Sorry for the inconvenience. We\'re performing some updates and maintenance on our servers to improve your experience. Please check back later.';

  @override
  String get btn_refresh => 'Refresh';

  @override
  String get profile_section_account => 'Account';

  @override
  String get profile_tile_info => 'Account Information';

  @override
  String get profile_tile_id_card => 'Digital ID Card';

  @override
  String get profile_section_subscription => 'Accounts & Subscription';

  @override
  String get profile_tile_payments => 'My Payments';

  @override
  String get profile_tile_notifications => 'Notifications';

  @override
  String get profile_tile_logout => 'Logout';

  @override
  String get profile_no_email => 'No email provided';

  @override
  String get profile_edit_btn => 'Edit';

  @override
  String get profile_label_loading => 'Loading...';

  @override
  String get profile_label_name => 'Name';

  @override
  String get profile_label_mobile => 'Mobile';

  @override
  String get profile_label_goal => 'Goal';

  @override
  String get profile_tile_referrals => 'Referrals';

  @override
  String get profile_referral_program => 'Referral Program';

  @override
  String get profile_your_referral_code => 'Your Referral Code';

  @override
  String profile_referral_used_by(int count) {
    return 'Used by $count students';
  }

  @override
  String get profile_referral_history => 'Referral History';

  @override
  String get profile_no_referral_history => 'No referral history yet.';

  @override
  String get library_title => 'Library';

  @override
  String get library_details => 'Library Details';

  @override
  String get library_label_address => 'Address';

  @override
  String get library_label_phone => 'Phone';

  @override
  String get library_label_email => 'Email';

  @override
  String get library_label_whatsapp => 'WhatsApp';

  @override
  String get library_label_emergency_contact => 'Emergency Contact';

  @override
  String get library_label_working_hours => 'Working Hours';

  @override
  String library_weekly_off(String day) {
    return '(Off: $day)';
  }

  @override
  String get library_label_website => 'Website';

  @override
  String get library_capacity_stats => 'Library Capacity & Stats';

  @override
  String library_total_capacity(int count) {
    return 'Total Capacity: $count Seats';
  }

  @override
  String library_currently_available(int count) {
    return 'Currently Available: $count Seats';
  }

  @override
  String get library_about_us => 'About Us';

  @override
  String get library_history => 'History';

  @override
  String get library_mission => 'Mission';

  @override
  String get library_vision => 'Vision';

  @override
  String get library_services_courses => 'Services & Courses';

  @override
  String get library_services_offered => 'Services Offered';

  @override
  String get library_courses_supported => 'Courses Supported';

  @override
  String get library_membership_info => 'Membership Information';

  @override
  String get library_details_lbl => 'Details';

  @override
  String get library_benefits_lbl => 'Benefits';

  @override
  String get library_registration_process => 'Registration Process';

  @override
  String get library_required_documents => 'Required Documents';

  @override
  String get library_rules_guidelines => 'Rules & Guidelines';

  @override
  String get library_rules => 'Library Rules';

  @override
  String get library_faq => 'Frequently Asked Questions';

  @override
  String get library_location => 'Location';

  @override
  String get library_get_directions => 'Get Directions';

  @override
  String get library_facilities => 'Facilities';

  @override
  String get library_no_facilities => 'No facilities listed.';

  @override
  String get library_facility_fallback => 'Facility';

  @override
  String get library_featured_achievers => 'Featured Achievers';

  @override
  String get library_no_featured_achievers => 'No featured achievers yet.';

  @override
  String get library_all_achievers_title => 'All Achievers';

  @override
  String get library_no_achievers => 'No achievers yet.';

  @override
  String get library_gallery => 'Gallery';

  @override
  String get library_no_gallery_images => 'No images yet.';

  @override
  String get library_reviews => 'Reviews';

  @override
  String library_reviews_summary(String avg, int count) {
    return '$avg average from $count reviews';
  }

  @override
  String get library_no_reviews => 'No reviews yet.';

  @override
  String get library_social_media => 'Social Media';

  @override
  String get lib_title_achievers => 'All Achievers';

  @override
  String get lib_no_achievers => 'No achievers listed.';

  @override
  String get lib_title_facilities => 'All Facilities';

  @override
  String get lib_no_facilities => 'No facilities listed.';

  @override
  String get err_failed_load_permissions => 'Failed to load permissions.';

  @override
  String get err_check_connection =>
      'Please check your connection and try again.';

  @override
  String get err_no_internet => 'No Internet Connection';

  @override
  String get btn_retry => 'Retry';
}
