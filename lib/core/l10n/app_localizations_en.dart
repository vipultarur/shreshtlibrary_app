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
  String get home_good_afternoon => 'Good Afternoon';

  @override
  String get home_good_evening => 'Good Evening';

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
      'Please purchase a plan or contact staff to activate.';

  @override
  String get home_plans => 'Plans';

  @override
  String get home_account_suspended => 'Account Suspended';

  @override
  String get home_account_suspended_desc =>
      'Your account has been suspended by the staffistrator.';

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
  String get payment_submitted => 'Payment submitted for staff verification.';

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

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_general => 'General';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_information => 'Information';

  @override
  String get settings_privacy_policy => 'Privacy Policy';

  @override
  String get settings_instructions => 'Instructions';

  @override
  String get settings_developer_info => 'Developer Info';

  @override
  String get settings_app_version => 'App Version';

  @override
  String get settings_logout => 'Logout';

  @override
  String get settings_logout_confirm => 'Are you sure you want to logout?';

  @override
  String get settings_logout_cancel => 'Cancel';

  @override
  String get settings_logout_yes => 'Logout';

  @override
  String get dev_info_title => 'Developer Info';

  @override
  String get dev_info_app_by => 'App developed by';

  @override
  String get dev_info_name => 'Hitesh Patel';

  @override
  String get dev_info_role => 'Lead Developer & Maintainer';

  @override
  String get dev_info_contact => 'Contact: developer@shreshtlibrary.com';

  @override
  String get privacy_policy_title => 'Privacy Policy';

  @override
  String get privacy_policy_intro =>
      'Your privacy is important to us. This privacy policy explains how Shresht Library collects, uses, and protects your personal data.';

  @override
  String get privacy_data_collection => 'Data Collection';

  @override
  String get privacy_data_collection_desc =>
      'We collect information such as your name, mobile number, email, and study goals to provide and improve our library services.';

  @override
  String get privacy_data_usage => 'Data Usage';

  @override
  String get privacy_data_usage_desc =>
      'The collected data is used for user authentication, managing attendance, study session tracking, and communicating library updates.';

  @override
  String get privacy_data_security => 'Data Security';

  @override
  String get privacy_data_security_desc =>
      'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, or disclosure.';

  @override
  String get privacy_contact => 'Contact Us';

  @override
  String get privacy_contact_desc =>
      'If you have any questions about this Privacy Policy, please contact our support team.';

  @override
  String get inst_title => 'Instructions';

  @override
  String get inst_home => 'Home Screen';

  @override
  String get inst_home_desc =>
      'The home screen shows your current library status. The Attendance Status Widget gives you a quick overview of your today\'s attendance. Use the \'Scan\' button to scan the QR code for Check-in and Check-out.';

  @override
  String get inst_attendance => 'Attendance & QR';

  @override
  String get inst_attendance_desc =>
      '• QR Scan: Scan the QR code displayed at the library desk. The system records your Check-in/Check-out times based on the allowed scanning window.\n• Late Marks: If you check in after the allowed time, it will be marked as late.\n• History: Swipe horizontally on the calendar to change months. Colors indicate Present (Green), Absent (Red), or Holiday (Gray).';

  @override
  String get inst_study => 'Study Area';

  @override
  String get inst_study_desc =>
      '• Study Session: Once checked in, you can start a study session to track your productive hours.\n• Anti-distraction: If you move your phone or switch apps, the tracker will pause. Stay focused to earn more hours.\n• Analytics: View your study analytics by swiping or tapping on tabs for daily, weekly, and monthly statistics.';

  @override
  String get inst_status => 'Student Status';

  @override
  String get inst_status_desc =>
      '• Live: You have an active membership and can use all features.\n• Pending: Your membership payment is under review by staff.\n• Suspended: Your account has been temporarily disabled by the admin.\n• Expired: Your membership has ended. Please renew to access features.';

  @override
  String get inst_leaderboard => 'Leaderboard';

  @override
  String get inst_leaderboard_desc =>
      'The leaderboard ranks students based on their total focused study hours. Study consistently without distractions to climb the ranks!';

  @override
  String get inst_home_subtitle => 'Your dashboard overview';

  @override
  String get inst_attendance_subtitle => 'How to check in and out';

  @override
  String get inst_calendar => 'Attendance';

  @override
  String get inst_calendar_subtitle => 'Monthly view, reports and statistics';

  @override
  String get inst_calendar_desc =>
      'View your complete attendance history in the calendar view. You can see your monthly summary, track your total present days, and analyze your punctuality over time.';

  @override
  String get inst_colors => 'Attendance Colors';

  @override
  String get inst_colors_subtitle => 'Know what each color means';

  @override
  String get inst_status_subtitle => 'Understand your membership state';

  @override
  String get inst_study_subtitle => 'Track your productive hours';

  @override
  String get inst_header_title =>
      'Your complete guide to using the app smartly.';

  @override
  String get inst_home_part1 =>
      'The home screen shows your current library status. The Attendance Status Widget gives you a quick overview of your today\'s attendance. Use the ';

  @override
  String get inst_home_scan_btn => 'Scan';

  @override
  String get inst_home_part2 =>
      ' button to scan the QR code for Check-in and Check-out.';

  @override
  String get inst_qr_desc =>
      'QR attendance helps us mark your presence accurately. Scan the QR code displayed at the library entrance within the allowed time.';

  @override
  String get inst_qr_timing => 'Library Timing ';

  @override
  String get inst_qr_dynamic => '(Dynamic)';

  @override
  String get inst_qr_start_time => 'Start Time';

  @override
  String get inst_qr_allowed_time => 'Allowed Time';

  @override
  String get inst_qr_end_time => 'End Time';

  @override
  String get inst_qr_rule1_title => 'Scan only once when you enter.';

  @override
  String get inst_qr_rule1_desc => 'Duplicate scans are not allowed.';

  @override
  String get inst_qr_rule2_title => 'You must scan within the allowed time.';

  @override
  String get inst_qr_rule2_desc1 => 'After that you will be marked as ';

  @override
  String get inst_qr_rule2_desc2 => '.';

  @override
  String get inst_qr_rule3_title =>
      'If you come late after the allowed time, contact library staff.';

  @override
  String get inst_qr_rule3_desc1 =>
      'Staff can mark you manually if permitted. Your status will show as ';

  @override
  String get inst_qr_rule3_desc2 => '.';

  @override
  String get inst_qr_rule4_title =>
      'Make sure your location is ON and internet is available.';

  @override
  String get inst_qr_how_to => 'How to Scan?';

  @override
  String get inst_qr_step1_1 => 'Tap on ';

  @override
  String get inst_qr_step1_2 => ' button.';

  @override
  String get inst_qr_step2 => 'Allow camera permission.';

  @override
  String get inst_qr_step3 => 'Point camera to the QR code.';

  @override
  String get inst_qr_step4 => 'Wait for success message.';

  @override
  String get inst_qr_step5 => 'Your attendance will be recorded.';

  @override
  String get inst_color_present_title => 'Present';

  @override
  String get inst_color_present_desc => 'You were marked present on time.';

  @override
  String get inst_color_late_title => 'Late';

  @override
  String get inst_color_late_desc =>
      'You scanned after the allowed arrival time.';

  @override
  String get inst_color_absent_title => 'Absent';

  @override
  String get inst_color_absent_desc =>
      'You did not attend or failed to scan your QR.';

  @override
  String get inst_color_holiday_title => 'Holiday';

  @override
  String get inst_color_holiday_desc => 'The library was closed for a holiday.';

  @override
  String get inst_color_pending_title => 'Pending';

  @override
  String get inst_color_pending_desc =>
      'Your attendance status is pending review.';

  @override
  String get inst_status_live_title => 'Live';

  @override
  String get inst_status_live_desc =>
      'You have an active membership and can use all features.';

  @override
  String get inst_status_pending_title => 'Pending';

  @override
  String get inst_status_pending_desc =>
      'Your membership payment is under review by staff.';

  @override
  String get inst_status_suspended_title => 'Suspended';

  @override
  String get inst_status_suspended_desc =>
      'Your account has been temporarily disabled by the admin.';

  @override
  String get inst_status_expired_title => 'Expired';

  @override
  String get inst_status_expired_desc =>
      'Your membership has ended. Please renew to access features.';

  @override
  String get inst_study_desc_main =>
      'Study Area helps you focus and track your productive study hours with beautiful analytics.';

  @override
  String get inst_study_start_title => 'Start Session';

  @override
  String get inst_study_start_1 => 'Tap on ';

  @override
  String get inst_study_start_btn => 'Start New Session';

  @override
  String get inst_study_start_2 => ' to begin.';

  @override
  String get inst_study_pause_title => 'Pause / Resume';

  @override
  String get inst_study_pause_desc => 'You can pause and resume anytime.';

  @override
  String get inst_study_break_title => 'Break Time';

  @override
  String get inst_study_break_desc =>
      'Take short breaks. App will not count break time.';

  @override
  String get inst_study_end_title => 'End Session';

  @override
  String get inst_study_end_1 => 'Tap ';

  @override
  String get inst_study_end_btn => 'Quit';

  @override
  String get inst_study_end_2 => ' to end your session.';

  @override
  String get inst_study_analytics_title => 'Analytics';

  @override
  String get inst_study_analytics_desc =>
      'View daily, weekly and monthly study analytics.';

  @override
  String get inst_study_streak_title => 'Focus Streak';

  @override
  String get inst_study_streak_desc =>
      'Maintain your streak and increase your focus time.';

  @override
  String get inst_tips => 'Tips';

  @override
  String get inst_tip1 => 'Keep your phone away from distractions.';

  @override
  String get inst_tip2 => 'Use break time to relax your eyes.';

  @override
  String get inst_tip3 => 'Consistency is the key to success.';

  @override
  String get inst_welcome_to => 'Welcome to';

  @override
  String get inst_shresht_library => 'Shresht Library';
}
