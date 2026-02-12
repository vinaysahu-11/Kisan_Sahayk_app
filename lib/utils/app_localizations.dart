import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });

      return true;
    } catch (e) {
      // Fallback to English
      if (locale.languageCode != 'en') {
        try {
          String jsonString = await rootBundle.loadString('assets/lang/en.json');
          Map<String, dynamic> jsonMap = json.decode(jsonString);

          _localizedStrings = jsonMap.map((key, value) {
            return MapEntry(key, value.toString());
          });
        } catch (e) {
          // If English also fails, use empty map
          _localizedStrings = {};
        }
      }
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // App Info
  String get appName => translate('app_name');
  String get tagline => translate('tagline');
  String get harKisanTagline => translate('har_kisan_tagline');
  String get welcome => translate('welcome');
  String get chooseLanguage => translate('choose_language');
  String get selectLanguageHint => translate('select_language_hint');
  String get languageSelected => translate('language_selected');
  String get welcomeBack => translate('welcome_back');
  String get appTagline => translate('app_tagline');
  String get ourServices => translate('our_services');
  
  // Auth
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get mobile => translate('mobile');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get fullName => translate('full_name');
  String get confirmPassword => translate('confirm_password');
  String get invalidPhone => translate('invalid_phone');
  String get phoneNotRegistered => translate('phone_not_registered');
  String get invalidOTP => translate('invalid_otp');
  String get enterOtp => translate('enter_otp');
  String get verifyOtp => translate('verify_otp');
  String get sendOtp => translate('send_otp');
  String get otpSent => translate('otp_sent');
  String get mobileVerification => translate('mobile_verification');
  String get changeMobile => translate('change_mobile');
  String get enterValidMobile => translate('enter_valid_mobile');
  String get otpSentSuccess => translate('otp_sent_success');
  String get enter6DigitOtp => translate('enter_6_digit_otp');
  String get invalidOtpRetry => translate('invalid_otp_retry');
  String get loginToContinue => translate('login_to_continue');
  String get mobileNumber => translate('mobile_number');
  String get enterOTP => translate('enter_otp_hint');
  String get changePhoneNumber => translate('change_phone_number');
  String get demoCredentials => translate('demo_credentials');
  
  // Navigation
  String get dashboard => translate('dashboard');
  String get home => translate('home');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get logout => translate('logout');
  String get goBack => translate('go_back');
  
  // Main Services
  String get buyProduct => translate('buy_product');
  String get sellProduct => translate('sell_product');
  String get transport => translate('transport');
  String get labour => translate('labour');
  String get jobs => translate('jobs');
  String get weather => translate('weather');
  String get weatherForecast => translate('weather_forecast');
  String get bookings => translate('bookings');
  String get orders => translate('orders');
  String get wallet => translate('wallet');
  String get help => translate('help');
  String get about => translate('about');
  String get language => translate('language');
  
  // Service Descriptions
  String get bookTransport => translate('book_transport');
  String get hireLabour => translate('hire_labour');
  String get listYourProduct => translate('list_your_product');
  String get jobOpportunities => translate('job_opportunities');
  
  // Marketplace
  String get marketplace => translate('marketplace');
  String get kisanMarket => translate('kisan_market');
  String get openMarketplace => translate('open_marketplace');
  String get featuredProducts => translate('featured_products');
  String get categories => translate('categories');
  String get allCategories => translate('all_categories');
  String get all => translate('all');
  String get search => translate('search');
  String get searchProducts => translate('search_products');
  String get clearSearch => translate('clear_search');
  String get cart => translate('cart');
  String get checkout => translate('checkout');
  String get addToCart => translate('add_to_cart');
  String get addedToCart => translate('added_to_cart');
  String get buyNow => translate('buy_now');
  String get price => translate('price');
  String get quantity => translate('quantity');
  String get total => translate('total');
  String get subtotal => translate('subtotal');
  String get deliveryFee => translate('delivery_fee');
  String get codCharge => translate('cod_charge');
  String get platformFee => translate('platform_fee');
  String get free => translate('free');
  String get viewAll => translate('view_all');
  String get seeAll => translate('see_all');
  String get filter => translate('filter');
  
  // Features
  String get escrowPayment => translate('escrow_payment');
  String get codAvailable => translate('cod_available');
  String get codAvailableOnly => translate('cod_available_only');
  String get freeDelivery => translate('free_delivery');
  String get sellerRatings => translate('seller_ratings');
  String get walletCashback => translate('wallet_cashback');
  String get easyReturns => translate('easy_returns');
  
  // Orders
  String get myOrders => translate('my_orders');
  String get activeOrders => translate('active_orders');
  String get completedOrders => translate('completed_orders');
  String get orderDetails => translate('order_details');
  String get orderStatus => translate('order_status');
  String get trackOrder => translate('track_order');
  String get cancelOrder => translate('cancel_order');
  String get cancelOrderConfirm => translate('cancel_order_confirm');
  String get returnOrder => translate('return_order');
  String get returnDispute => translate('return_dispute');
  String get returnRaised => translate('return_raised');
  String get rateOrder => translate('rate_order');
  String get orderNotFound => translate('order_not_found');
  String get orderCancelled => translate('order_cancelled');
  String get orderProgressed => translate('order_progressed');
  String get raiseReturnDispute => translate('raise_return_dispute');
  String get simulateNextStep => translate('simulate_next_step');
  String get thankYouRating => translate('thank_you_rating');
  String get viewOrders => translate('view_orders');
  String get clearCart => translate('clear_cart');
  String get removeAllItems => translate('remove_all_items');
  
  // Address
  String get deliveryAddress => translate('delivery_address');
  String get myAddresses => translate('my_addresses');
  String get addAddress => translate('add_address');
  String get addNew => translate('add_new');
  String get editAddress => translate('edit_address');
  String get selectAddress => translate('select_address');
  String get selectDeliveryAddress => translate('select_delivery_address');
  String get houseNo => translate('house_no');
  String get street => translate('street');
  String get city => translate('city');
  String get state => translate('state');
  String get pincode => translate('pincode');
  String get saveAddress => translate('save_address');
  String get addressAdded => translate('address_added');
  String get setAsDefault => translate('set_as_default');
  
  // Payment
  String get paymentMethod => translate('payment_method');
  String get payment => translate('payment');
  String get cashOnDelivery => translate('cash_on_delivery');
  String get onlinePayment => translate('online_payment');
  String get walletPayment => translate('wallet_payment');
  String get placeOrder => translate('place_order');
  String get completePayment => translate('complete_payment');
  String get paymentSuccessful => translate('payment_successful');
  String get cartEmpty => translate('cart_empty');
  
  // Transport Booking
  String get transportServices => translate('transport_services');
  String get transportBooking => translate('transport_booking');
  String get bookNow => translate('book_now');
  String get fromLocation => translate('from_location');
  String get toLocation => translate('to_location');
  String get vehicleType => translate('vehicle_type');
  String get loadWeight => translate('load_weight');
  String get pickupDate => translate('pickup_date');
  String get selectVehicle => translate('select_vehicle');
  String get selectBothLocations => translate('select_both_locations');
  String get loadDetails => translate('load_details');
  String get selectScheduledTime => translate('select_scheduled_time');
  String get confirmBooking => translate('confirm_booking');
  String get bookingFailed => translate('booking_failed');
  String get gpsAutoDetect => translate('gps_auto_detect');
  String get selectVehicleType => translate('select_vehicle_type');
  String get fareBreakdown => translate('fare_breakdown');
  
  // Transport Partner
  String get transportPartner => translate('transport_partner');
  String get transportPartnerRegistration => translate('transport_partner_registration');
  String get partnerDashboard => translate('partner_dashboard');
  String get personalDetails => translate('personal_details');
  String get bankDetails => translate('bank_details');
  String get vehicleDetails => translate('vehicle_details');
  String get vehicleInformation => translate('vehicle_information');
  String get documents => translate('documents');
  String get uploadProfilePhoto => translate('upload_profile_photo');
  String get loadCapacity => translate('load_capacity');
  String get typeOfLoad => translate('type_of_load');
  String get serviceAreaRadius => translate('service_area_radius');
  String get submitApplication => translate('submit_application');
  String get applicationStatus => translate('application_status');
  String get tapSimulateApproval => translate('tap_simulate_approval');
  String get approveNowDemo => translate('approve_now_demo');
  String get todaysEarnings => translate('todays_earnings');
  String get tripCompleted => translate('trip_completed');
  String get tripInProgress => translate('trip_in_progress');
  String get myWallet => translate('my_wallet');
  String get availableBalance => translate('available_balance');
  String get withdrawToBank => translate('withdraw_to_bank');
  String get transactionHistory => translate('transaction_history');
  String get uploadDrivingLicense => translate('upload_driving_license');
  String get registrationSubmitted => translate('registration_submitted');
  String get registrationSuccessful => translate('registration_successful');
  String get goToDashboard => translate('go_to_dashboard');
  String get registrationFailed => translate('registration_failed');
  String get upload => translate('upload');
  String get selectAtLeastOneLoad => translate('select_at_least_one_load');
  String get cancelBooking => translate('cancel_booking');
  String get rateTrip => translate('rate_trip');
  String get selectRating => translate('select_rating');

  String get activeBooking => translate('active_booking');
  String get activeLabourBooking => translate('active_labour_booking');
  String get cancelBookingNo => translate('cancel_booking_no');
  String get cancelBookingYes => translate('cancel_booking_yes');
  String get call => translate('call');
  String get chat => translate('chat');
  
  // Labour
  String get labourServices => translate('labour_services');
  String get labourBooking => translate('labour_booking');
  String get bookLabour => translate('book_labour');
  String get selectLabourType => translate('select_labour_type');
  String get skillType => translate('skill_type');
  String get workersNeeded => translate('workers_needed');
  String get workDate => translate('work_date');
  String get dailyWage => translate('daily_wage');
  String get bookingDetails => translate('booking_details');
  String get workLocation => translate('work_location');
  String get enterWorkLocation => translate('enter_work_location');
  String get locationDetected => translate('location_detected');
  String get rateWorkers => translate('rate_workers');
  String get thankYou => translate('thank_you');

  // Labour Partner
  String get becomeLabourPartner => translate('become_labour_partner');
  String get labourPartnerRegistration => translate('labour_partner_registration');
  String get labourDashboard => translate('labour_dashboard');
  String get labourPartnerDashboard => translate('labour_partner_dashboard');
  String get selectSkills => translate('select_skills');
  String get skillsExperience => translate('skills_experience');
  String get workDetails => translate('work_details');
  String get documentVerification => translate('document_verification');
  String get selectAtLeastOneSkill => translate('select_at_least_one_skill');
  String get activeJob => translate('active_job');
  String get jobRequestRejected => translate('job_request_rejected');
  String get withdrawRequestSubmitted => translate('withdraw_request_submitted');
  String get rateExperience => translate('rate_experience');
  String get thankYouFeedback => translate('thank_you_feedback');
  String get workHistory => translate('work_history');
  String get profileSettings => translate('profile_settings');
  String get withdrawAll => translate('withdraw_all');
  String get withdrawalRequested => translate('withdrawal_requested');
  String get requestWithdrawal => translate('request_withdrawal');
  
  // Delivery Partner
  String get deliveryPartner => translate('delivery_partner');
  String get becomeDeliveryPartner => translate('become_delivery_partner');
  String get deliveryDashboard => translate('delivery_dashboard');
  String get deliveryRegistration => translate('delivery_registration');
  String get becomePartner => translate('become_partner');
  String get registration => translate('registration');
  String get personalInfo => translate('personal_info');
  String get policeVerification => translate('police_verification');
  String get requiredForApproval => translate('required_for_approval');
  String get earnings => translate('earnings');
  String get active => translate('active');
  String get online => translate('online');
  String get offline => translate('offline');
  String get accept => translate('accept');
  String get acceptOrder => translate('accept_order');
  String get orderAccepted => translate('order_accepted');
  String get reject => translate('reject');
  String get rejectOrder => translate('reject_order');
  String get selectReason => translate('select_reason');
  String get selectRejectionReason => translate('select_rejection_reason');
  String get tooFar => translate('too_far');
  String get vehicleIssue => translate('vehicle_issue');
  String get personal => translate('personal');
  String get incompleteDocuments => translate('incomplete_documents');
  String get verificationFailed => translate('verification_failed');
  String get duplicateApplication => translate('duplicate_application');
  String get invalidOtpActionFailed => translate('invalid_otp_action_failed');
  String get actionFailed => translate('action_failed');
  String get pickup => translate('pickup');
  String get pickupOtp => translate('pickup_otp');
  String get deliveryOtp => translate('delivery_otp');
  String get deliver => translate('deliver');
  String get completed => translate('completed');
  String get reachedPickup => translate('reached_pickup');
  String get confirmPickupOtp => translate('confirm_pickup_otp');
  String get reachedDelivery => translate('reached_delivery');
  String get confirmDeliveryOtp => translate('confirm_delivery_otp');
  String get verify => translate('verify');
  String get notLoggedIn => translate('not_logged_in');
  String get noApplicationFound => translate('no_application_found');

  // Safety Center
  String get safetyCenter => translate('safety_center');
  String get emergencyAlert => translate('emergency_alert');
  String get sendAlert => translate('send_alert');
  String get emergencyAlertSent => translate('emergency_alert_sent');
  String get realtimeLocation => translate('realtime_location');
  String get shareLocationAdmin => translate('share_location_admin');
  String get autoCheckin => translate('auto_checkin');
  String get autoCheckinDesc => translate('auto_checkin_desc');
  String get verifiedBadge => translate('verified_badge');
  String get policeVerified => translate('police_verified');

  // Incentives & Performance
  String get incentivesRewards => translate('incentives_rewards');
  String get performance => translate('performance');
  String get codManagement => translate('cod_management');
  String get withdrawBalance => translate('withdraw_balance');
  String get insufficientBalance => translate('insufficient_balance');
  String get noTransactions => translate('no_transactions');
  
  // Time Periods
  String get today => translate('today');
  String get thisWeek => translate('this_week');
  String get thisMonth => translate('this_month');
  String get totalEarnings => translate('total_earnings');
  String get pending => translate('pending');
  String get approved => translate('approved');
  String get rejected => translate('rejected');
  String get approve => translate('approve');
  String get blockPartner => translate('block_partner');

  String get deliveryPartners => translate('delivery_partners');
  String get noPartnersFound => translate('no_partners_found');
  
  // Settings
  String get notificationSettings => translate('notification_settings');
  String get enableNotifications => translate('enable_notifications');
  String get receiveAllNotifications => translate('receive_all_notifications');
  String get weatherAlerts => translate('weather_alerts');
  String get getWeatherUpdates => translate('get_weather_updates');
  String get priceUpdates => translate('price_updates');
  String get marketPriceNotifications => translate('market_price_notifications');
  String get allMarkedRead => translate('all_marked_read');
  String get markAllRead => translate('mark_all_read');
  
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get switchToDarkTheme => translate('switch_to_dark_theme');
  String get darkModeComingSoon => translate('dark_mode_coming_soon');
  String get changeAppLanguage => translate('change_app_language');
  
  String get account => translate('account');
  String get editProfile => translate('edit_profile');
  String get changePassword => translate('change_password');
  String get featureComingSoon => translate('feature_coming_soon');
  String get privacyPolicy => translate('privacy_policy');
  String get openingPrivacyPolicy => translate('opening_privacy_policy');
  
  String get more => translate('more');
  String get rateApp => translate('rate_app');
  String get learnMore => translate('learn_more');
  String get thankYouSupport => translate('thank_you_support');

  // Seller Module
  String get sellerDashboard => translate('seller_dashboard');
  String get addProduct => translate('add_product');
  String get addNewProduct => translate('add_new_product');
  String get myProducts => translate('my_products');
  String get product => translate('product');
  String get productDetails => translate('product_details');
  String get productNotFound => translate('product_not_found');
  String get productListed => translate('product_listed');
  String get productListedSuccess => translate('product_listed_success');
  String get listProduct => translate('list_product');
  String get productListedSuccessfully => translate('product_listed_successfully');
  String get updateStock => translate('update_stock');
  String get stockUpdated => translate('stock_updated');
  String get editComingSoon => translate('edit_coming_soon');
  String get edit => translate('edit');

  String get category => translate('category');
  String get manageCategories => translate('manage_categories');
  String get addCategory => translate('add_category');
  String get editCategory => translate('edit_category');
  String get deleteCategory => translate('delete_category');
  String get noneRoot => translate('none_root');
  String get add => translate('add');
  String get categoryAdded => translate('category_added');
  String get categoryUpdated => translate('category_updated');
  String get categoryDeleted => translate('category_deleted');
  String get delete => translate('delete');

  String get manageSellers => translate('manage_sellers');
  String get products => translate('products');
  String get rejectKyc => translate('reject_kyc');
  String get approveKyc => translate('approve_kyc');
  String get kycApproved => translate('kyc_approved');
  String get kycRejected => translate('kyc_rejected');
  String get forceUpgrade => translate('force_upgrade');
  String get upgradeSellerConfirm => translate('upgrade_seller_confirm');
  String get upgrade => translate('upgrade');
  String get sellerUpgraded => translate('seller_upgraded');
  String get forceDowngrade => translate('force_downgrade');
  String get downgradeSellerConfirm => translate('downgrade_seller_confirm');
  String get downgrade => translate('downgrade');
  String get sellerDowngraded => translate('seller_downgraded');
  String get kycDocuments => translate('kyc_documents');
  String get uploadKyc => translate('upload_kyc');
  String get resubmitKyc => translate('resubmit_kyc');
  String get kycSubmitted => translate('kyc_submitted');
  String get renewSubscription => translate('renew_subscription');
  String get subscribe => translate('subscribe');
  String get confirmSubscription => translate('confirm_subscription');
  String get confirmUpgradeBigSeller => translate('confirm_upgrade_big_seller');
  String get successfullyUpgraded => translate('successfully_upgraded');
  String get completeRegistration => translate('complete_registration');
  String get welcomeExclaim => translate('welcome_exclaim');
  String get sellerLogin => translate('seller_login');

  String get cod => translate('cod');
  String get codDesc => translate('cod_desc');
  String get selfPickup => translate('self_pickup');
  String get sellerDelivery => translate('seller_delivery');
  String get sellerDeliveryDesc => translate('seller_delivery_desc');
  String get deliveryOptions => translate('delivery_options');
  String get pricingPreview => translate('pricing_preview');
  String get confirm => translate('confirm');
  String get selectCategory => translate('select_category');
  String get successExclaim => translate('success_exclaim');

  String get orderAcceptedMsg => translate('order_accepted_msg');
  String get orderRejectedMsg => translate('order_rejected_msg');
  String get markShipped => translate('mark_shipped');
  String get markDelivered => translate('mark_delivered');
  String get orderShipped => translate('order_shipped');
  String get orderDelivered => translate('order_delivered');
  String get rejectOrderConfirm => translate('reject_order_confirm');

  String get sellerWallet => translate('seller_wallet');
  String get withdraw => translate('withdraw');
  String get withdrawFunds => translate('withdraw_funds');
  String get withdrawalSuccessful => translate('withdrawal_successful');

  // Help
  String get callingSupport => translate('calling_support');
  String get openingEmail => translate('opening_email');
  String get startingChat => translate('starting_chat');

  // Partner Dashboard
  String get tripHistoryComing => translate('trip_history_coming');
  String get vehicleInfoComing => translate('vehicle_info_coming');
  String get supportComing => translate('support_coming');
  String get ratingComing => translate('rating_coming');

  // Admin
  String get adminDashboard => translate('admin_dashboard');
  
  // Actions
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get submit => translate('submit');
  String get continueBtn => translate('continue_btn');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get loading => translate('loading');
  String get success => translate('success');
  String get error => translate('error');
  String get retry => translate('retry');
  
  // Empty States
  String get noItems => translate('no_items');
  String get noOrders => translate('no_orders');
  String get noNotifications => translate('no_notifications');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'cg'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
