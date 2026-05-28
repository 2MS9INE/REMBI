import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_kab.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('kab'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'رمبي'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'السوق الرقمي للفلاح الجزائري'**
  String get tagline;

  /// No description provided for @browseListings.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الإعلانات'**
  String get browseListings;

  /// No description provided for @contactFarmer.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بالفلاح'**
  String get contactFarmer;

  /// No description provided for @postListing.
  ///
  /// In ar, this message translates to:
  /// **'نشر إعلان'**
  String get postListing;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @wilaya.
  ///
  /// In ar, this message translates to:
  /// **'الولاية'**
  String get wilaya;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @negotiable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتفاوض'**
  String get negotiable;

  /// No description provided for @sold.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get sold;

  /// No description provided for @available.
  ///
  /// In ar, this message translates to:
  /// **'متاح'**
  String get available;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @report.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ'**
  String get report;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مواشي، محاصيل...'**
  String get searchPlaceholder;

  /// No description provided for @featuredListingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات مميزة'**
  String get featuredListingsTitle;

  /// No description provided for @allWilayas.
  ///
  /// In ar, this message translates to:
  /// **'كل الولايات'**
  String get allWilayas;

  /// No description provided for @priceAsc.
  ///
  /// In ar, this message translates to:
  /// **'السعر (الأقل أولاً)'**
  String get priceAsc;

  /// No description provided for @priceDesc.
  ///
  /// In ar, this message translates to:
  /// **'السعر (الأعلى أولاً)'**
  String get priceDesc;

  /// No description provided for @newest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// No description provided for @mostReviewed.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مراجعة'**
  String get mostReviewed;

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'فرز حسب'**
  String get sortBy;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @listingDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإعلان'**
  String get listingDetailsTitle;

  /// No description provided for @descriptionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get descriptionTitle;

  /// No description provided for @readMore.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ المزيد'**
  String get readMore;

  /// No description provided for @viewProfile.
  ///
  /// In ar, this message translates to:
  /// **'عرض الملف الشخصي'**
  String get viewProfile;

  /// No description provided for @call.
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// No description provided for @reportListing.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن الإعلان'**
  String get reportListing;

  /// No description provided for @reportSubmitted.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ، شكراً لمساهمتك'**
  String get reportSubmitted;

  /// No description provided for @reportFake.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مزيف'**
  String get reportFake;

  /// No description provided for @reportInappropriate.
  ///
  /// In ar, this message translates to:
  /// **'محتوى غير لائق'**
  String get reportInappropriate;

  /// No description provided for @reportDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مكرر'**
  String get reportDuplicate;

  /// No description provided for @reportScam.
  ///
  /// In ar, this message translates to:
  /// **'احتيال'**
  String get reportScam;

  /// No description provided for @priceUponContact.
  ///
  /// In ar, this message translates to:
  /// **'السعر عند الاتصال'**
  String get priceUponContact;

  /// No description provided for @trustedSeller.
  ///
  /// In ar, this message translates to:
  /// **'بائع موثوق'**
  String get trustedSeller;

  /// No description provided for @sellerListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات البائع'**
  String get sellerListings;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noReviews;

  /// No description provided for @addReview.
  ///
  /// In ar, this message translates to:
  /// **'أضف تقييمك'**
  String get addReview;

  /// No description provided for @noActiveListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات نشطة حالياً'**
  String get noActiveListings;

  /// No description provided for @yourName.
  ///
  /// In ar, this message translates to:
  /// **'اسمك'**
  String get yourName;

  /// No description provided for @reviewThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكراً على تقييمك'**
  String get reviewThanks;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @whatsappNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب (اختياري)'**
  String get whatsappNumber;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'0XXXXXXXXX'**
  String get phoneHint;

  /// No description provided for @whatsappHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الواتساب (اختياري)'**
  String get whatsappHint;

  /// No description provided for @selectWilaya.
  ///
  /// In ar, this message translates to:
  /// **'اختر ولايتك'**
  String get selectWilaya;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get registerTitle;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ سجّل الآن'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟ سجّل الدخول'**
  String get haveAccount;

  /// No description provided for @profilePhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة الملف الشخصي'**
  String get profilePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة'**
  String get addPhoto;

  /// No description provided for @registering.
  ///
  /// In ar, this message translates to:
  /// **'جاري إنشاء الحساب...'**
  String get registering;

  /// No description provided for @loggingIn.
  ///
  /// In ar, this message translates to:
  /// **'جاري تسجيل الدخول...'**
  String get loggingIn;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون رقم الهاتف 10 أرقام ويبدأ بـ 05 أو 06 أو 07'**
  String get phoneInvalid;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @farmerDashboard.
  ///
  /// In ar, this message translates to:
  /// **'مزرعتي'**
  String get farmerDashboard;

  /// No description provided for @myListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلاناتي'**
  String get myListings;

  /// No description provided for @addListing.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إعلان'**
  String get addListing;

  /// No description provided for @totalListings.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get totalListings;

  /// No description provided for @totalViews.
  ///
  /// In ar, this message translates to:
  /// **'المشاهدات'**
  String get totalViews;

  /// No description provided for @activeListings.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeListings;

  /// No description provided for @requestVerification.
  ///
  /// In ar, this message translates to:
  /// **'طلب الشارة'**
  String get requestVerification;

  /// No description provided for @verificationRequested.
  ///
  /// In ar, this message translates to:
  /// **'طلب التحقق قيد الانتظار'**
  String get verificationRequested;

  /// No description provided for @verificationRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب التحقق'**
  String get verificationRequestSent;

  /// No description provided for @editListing.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإعلان'**
  String get editListing;

  /// No description provided for @deleteListing.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان'**
  String get deleteListing;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان؟'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟'**
  String get deleteConfirmMessage;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'نعم، احذف'**
  String get confirmDelete;

  /// No description provided for @markAsSold.
  ///
  /// In ar, this message translates to:
  /// **'وضع علامة كمباع'**
  String get markAsSold;

  /// No description provided for @markAsAvailable.
  ///
  /// In ar, this message translates to:
  /// **'وضع علامة كمتاح'**
  String get markAsAvailable;

  /// No description provided for @expiresoon.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي قريباً'**
  String get expiresoon;

  /// No description provided for @noListingsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات بعد. ابدأ بإضافة واحد!'**
  String get noListingsYet;

  /// No description provided for @createListing.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء إعلان'**
  String get createListing;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @publishListing.
  ///
  /// In ar, this message translates to:
  /// **'نشر الإعلان'**
  String get publishListing;

  /// No description provided for @categorySelect.
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة'**
  String get categorySelect;

  /// No description provided for @subcategorySelect.
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة فرعية'**
  String get subcategorySelect;

  /// No description provided for @livestock.
  ///
  /// In ar, this message translates to:
  /// **'مواشي'**
  String get livestock;

  /// No description provided for @crops.
  ///
  /// In ar, this message translates to:
  /// **'محاصيل'**
  String get crops;

  /// No description provided for @artisan.
  ///
  /// In ar, this message translates to:
  /// **'منتجات حرفية'**
  String get artisan;

  /// No description provided for @services.
  ///
  /// In ar, this message translates to:
  /// **'خدمات فلاحية'**
  String get services;

  /// No description provided for @listingTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get listingTitle;

  /// No description provided for @listingTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get listingTitleHint;

  /// No description provided for @listingDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get listingDescription;

  /// No description provided for @listingDescriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'صف إعلانك (اختياري)'**
  String get listingDescriptionHint;

  /// No description provided for @listingPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر (دج)'**
  String get listingPrice;

  /// No description provided for @negotiableToggle.
  ///
  /// In ar, this message translates to:
  /// **'السعر قابل للتفاوض'**
  String get negotiableToggle;

  /// No description provided for @photos.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get photos;

  /// No description provided for @addPhotoSlot.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة'**
  String get addPhotoSlot;

  /// No description provided for @photoRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب صورة واحدة على الأقل'**
  String get photoRequired;

  /// No description provided for @requiredFields.
  ///
  /// In ar, this message translates to:
  /// **'الحقول المطلوبة'**
  String get requiredFields;

  /// No description provided for @optionalFields.
  ///
  /// In ar, this message translates to:
  /// **'الحقول الاختيارية'**
  String get optionalFields;

  /// No description provided for @uploading.
  ///
  /// In ar, this message translates to:
  /// **'جاري الرفع...'**
  String get uploading;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'تمييز الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حتى الآن'**
  String get noNotifications;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In ar, this message translates to:
  /// **'رمبي هو السوق الذكي للفلاح الجزائري. يربط المزارعين والحرفيين بالمشترين.'**
  String get aboutDescription;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @changesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات'**
  String get changesSaved;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @adminPanel.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get adminPanel;

  /// No description provided for @adminStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات'**
  String get adminStats;

  /// No description provided for @adminReports.
  ///
  /// In ar, this message translates to:
  /// **'البلاغات'**
  String get adminReports;

  /// No description provided for @adminVerifications.
  ///
  /// In ar, this message translates to:
  /// **'التوثيق'**
  String get adminVerifications;

  /// No description provided for @adminListings.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات'**
  String get adminListings;

  /// No description provided for @totalFarmers.
  ///
  /// In ar, this message translates to:
  /// **'الفلاحون'**
  String get totalFarmers;

  /// No description provided for @pendingReports.
  ///
  /// In ar, this message translates to:
  /// **'بلاغات معلقة'**
  String get pendingReports;

  /// No description provided for @pendingVerifications.
  ///
  /// In ar, this message translates to:
  /// **'طلبات توثيق'**
  String get pendingVerifications;

  /// No description provided for @listingsByCategory.
  ///
  /// In ar, this message translates to:
  /// **'الإعلانات حسب الفئة'**
  String get listingsByCategory;

  /// No description provided for @topWilayas.
  ///
  /// In ar, this message translates to:
  /// **'أكثر الولايات نشاطاً'**
  String get topWilayas;

  /// No description provided for @dailyNewListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات جديدة (7 أيام)'**
  String get dailyNewListings;

  /// No description provided for @noReports.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات معلقة'**
  String get noReports;

  /// No description provided for @dismiss.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get dismiss;

  /// No description provided for @removeListing.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان'**
  String get removeListing;

  /// No description provided for @warnFarmer.
  ///
  /// In ar, this message translates to:
  /// **'تحذير البائع'**
  String get warnFarmer;

  /// No description provided for @warnFarmerTitle.
  ///
  /// In ar, this message translates to:
  /// **'رسالة تحذير'**
  String get warnFarmerTitle;

  /// No description provided for @warnSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التحذير'**
  String get warnSent;

  /// No description provided for @noVerificationRequests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات توثيق معلقة'**
  String get noVerificationRequests;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @memberSince.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ'**
  String get memberSince;

  /// No description provided for @verificationApproved.
  ///
  /// In ar, this message translates to:
  /// **'تم منح شارة التوثيق'**
  String get verificationApproved;

  /// No description provided for @pin.
  ///
  /// In ar, this message translates to:
  /// **'تمييز'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التمييز'**
  String get unpin;

  /// No description provided for @pinLimitError.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تمييز أكثر من 5 إعلانات في نفس الوقت'**
  String get pinLimitError;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get passwordTooShort;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordMismatch;
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
      <String>['ar', 'en', 'fr', 'kab'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'kab':
      return AppLocalizationsKab();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
