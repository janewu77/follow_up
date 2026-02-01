import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('zh'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'FollowUP'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get loginToContinue;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get loggingIn;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @testAccount.
  ///
  /// In en, this message translates to:
  /// **'Test Account:'**
  String get testAccount;

  /// No description provided for @testAccountAlice.
  ///
  /// In en, this message translates to:
  /// **'Username: alice / Password: alice123'**
  String get testAccountAlice;

  /// No description provided for @testAccountDemo.
  ///
  /// In en, this message translates to:
  /// **'Username: demo / Password: demo123'**
  String get testAccountDemo;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogoutMessage;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}'**
  String welcomeBack(String username);

  /// No description provided for @addEventPrompt.
  ///
  /// In en, this message translates to:
  /// **'Any new events to add today?'**
  String get addEventPrompt;

  /// No description provided for @textRecognition.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition'**
  String get textRecognition;

  /// No description provided for @inputDescription.
  ///
  /// In en, this message translates to:
  /// **'Input description'**
  String get inputDescription;

  /// No description provided for @imageRecognition.
  ///
  /// In en, this message translates to:
  /// **'Image Recognition'**
  String get imageRecognition;

  /// No description provided for @photoOrUpload.
  ///
  /// In en, this message translates to:
  /// **'Photo or upload'**
  String get photoOrUpload;

  /// No description provided for @followedEvents.
  ///
  /// In en, this message translates to:
  /// **'Followed Events'**
  String get followedEvents;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noFollowedEvents.
  ///
  /// In en, this message translates to:
  /// **'No followed events yet'**
  String get noFollowedEvents;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add Activity'**
  String get addActivity;

  /// No description provided for @pasteDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste event description, AI will automatically recognize time, location, etc.'**
  String get pasteDescription;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @eventDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Next Saturday at 7pm, there\'s a Beethoven concert at Hamburg Philharmonic...'**
  String get eventDescriptionHint;

  /// No description provided for @additionalNote.
  ///
  /// In en, this message translates to:
  /// **'Additional Note (Optional)'**
  String get additionalNote;

  /// No description provided for @uploadPoster.
  ///
  /// In en, this message translates to:
  /// **'Upload event poster or flyer, AI will automatically recognize event information'**
  String get uploadPoster;

  /// No description provided for @eventImage.
  ///
  /// In en, this message translates to:
  /// **'Event Image'**
  String get eventImage;

  /// No description provided for @recognizeSchedule.
  ///
  /// In en, this message translates to:
  /// **'Recognize Schedule'**
  String get recognizeSchedule;

  /// No description provided for @aiRecognizing.
  ///
  /// In en, this message translates to:
  /// **'AI is recognizing event information...'**
  String get aiRecognizing;

  /// No description provided for @schedulePreview.
  ///
  /// In en, this message translates to:
  /// **'Schedule Preview'**
  String get schedulePreview;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivity;

  /// No description provided for @confirmActivity.
  ///
  /// In en, this message translates to:
  /// **'Confirm Activity'**
  String get confirmActivity;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @enterEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter event title'**
  String get enterEventTitle;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Event location'**
  String get eventLocation;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @eventDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Event description...'**
  String get eventDescriptionField;

  /// No description provided for @downloadIcs.
  ///
  /// In en, this message translates to:
  /// **'Download ICS'**
  String get downloadIcs;

  /// No description provided for @saveActivity.
  ///
  /// In en, this message translates to:
  /// **'Save Activity'**
  String get saveActivity;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @activitySaved.
  ///
  /// In en, this message translates to:
  /// **'Activity saved'**
  String get activitySaved;

  /// No description provided for @multipleEventsDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} events, swipe left/right to switch'**
  String multipleEventsDetected(int count);

  /// No description provided for @eventList.
  ///
  /// In en, this message translates to:
  /// **'Event List'**
  String get eventList;

  /// No description provided for @allEvents.
  ///
  /// In en, this message translates to:
  /// **'All Events'**
  String get allEvents;

  /// No description provided for @followed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get followed;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEvents;

  /// No description provided for @noFollowedEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No followed events yet'**
  String get noFollowedEventsYet;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @deleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event? This action cannot be undone.'**
  String get deleteEventConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'Event deleted'**
  String get eventDeleted;

  /// No description provided for @icsDownloaded.
  ///
  /// In en, this message translates to:
  /// **'ICS file downloaded'**
  String get icsDownloaded;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get fileSaved;

  /// No description provided for @pleaseEnterEventDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter event description'**
  String get pleaseEnterEventDescription;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectImage;

  /// No description provided for @pleaseEnterEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter event title'**
  String get pleaseEnterEventTitle;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @landingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Never Miss an Event Again'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FollowUP is your smart personal assistant for tracking events. Automatically extract event information from text or images, sync to your calendar, and get timely reminders.'**
  String get landingHeroSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @painPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Do You Ever Experience These Problems?'**
  String get painPointsTitle;

  /// No description provided for @painPoint1Title.
  ///
  /// In en, this message translates to:
  /// **'Scattered Information'**
  String get painPoint1Title;

  /// No description provided for @painPoint1Desc.
  ///
  /// In en, this message translates to:
  /// **'Event info buried in emails, chats, and social media, hard to track'**
  String get painPoint1Desc;

  /// No description provided for @painPoint2Title.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry is Tedious'**
  String get painPoint2Title;

  /// No description provided for @painPoint2Desc.
  ///
  /// In en, this message translates to:
  /// **'Manually entering events into calendar is time-consuming and error-prone'**
  String get painPoint2Desc;

  /// No description provided for @painPoint3Title.
  ///
  /// In en, this message translates to:
  /// **'Easy to Forget'**
  String get painPoint3Title;

  /// No description provided for @painPoint3Desc.
  ///
  /// In en, this message translates to:
  /// **'Missing important events due to no timely reminders'**
  String get painPoint3Desc;

  /// No description provided for @howItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorksTitle;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Capture Information'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Paste text or upload event poster/screenshot'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'AI Recognition'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Intelligently extract time, location, and other key info'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'One-Click Save'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Confirm and add to calendar with reminders'**
  String get step3Desc;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get featuresTitle;

  /// No description provided for @feature1Title.
  ///
  /// In en, this message translates to:
  /// **'Text Recognition'**
  String get feature1Title;

  /// No description provided for @feature1Desc.
  ///
  /// In en, this message translates to:
  /// **'Paste event description and let AI extract the information'**
  String get feature1Desc;

  /// No description provided for @feature2Title.
  ///
  /// In en, this message translates to:
  /// **'Image Recognition'**
  String get feature2Title;

  /// No description provided for @feature2Desc.
  ///
  /// In en, this message translates to:
  /// **'Upload event posters or screenshots for automatic parsing'**
  String get feature2Desc;

  /// No description provided for @feature3Title.
  ///
  /// In en, this message translates to:
  /// **'Calendar Sync'**
  String get feature3Title;

  /// No description provided for @feature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Export to ICS format, sync with any calendar app'**
  String get feature3Desc;

  /// No description provided for @feature4Title.
  ///
  /// In en, this message translates to:
  /// **'Follow Events'**
  String get feature4Title;

  /// No description provided for @feature4Desc.
  ///
  /// In en, this message translates to:
  /// **'Follow important events for timely reminders'**
  String get feature4Desc;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'See It In Action'**
  String get demoTitle;

  /// No description provided for @demoDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch how FollowUP transforms messy event info into organized calendar entries'**
  String get demoDesc;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try Now'**
  String get tryNow;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple, Transparent Pricing'**
  String get pricingTitle;

  /// No description provided for @pricingFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get pricingFree;

  /// No description provided for @pricingFreePriceDesc.
  ///
  /// In en, this message translates to:
  /// **'for personal use'**
  String get pricingFreePriceDesc;

  /// No description provided for @pricingFreeFeature1.
  ///
  /// In en, this message translates to:
  /// **'10 events per month'**
  String get pricingFreeFeature1;

  /// No description provided for @pricingFreeFeature2.
  ///
  /// In en, this message translates to:
  /// **'Text recognition'**
  String get pricingFreeFeature2;

  /// No description provided for @pricingFreeFeature3.
  ///
  /// In en, this message translates to:
  /// **'Basic calendar export'**
  String get pricingFreeFeature3;

  /// No description provided for @pricingPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pricingPro;

  /// No description provided for @pricingProPrice.
  ///
  /// In en, this message translates to:
  /// **'€4.99'**
  String get pricingProPrice;

  /// No description provided for @pricingProPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get pricingProPriceDesc;

  /// No description provided for @pricingProFeature1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited events'**
  String get pricingProFeature1;

  /// No description provided for @pricingProFeature2.
  ///
  /// In en, this message translates to:
  /// **'Image recognition'**
  String get pricingProFeature2;

  /// No description provided for @pricingProFeature3.
  ///
  /// In en, this message translates to:
  /// **'Priority AI processing'**
  String get pricingProFeature3;

  /// No description provided for @pricingProFeature4.
  ///
  /// In en, this message translates to:
  /// **'Advanced reminders'**
  String get pricingProFeature4;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @pricingTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get pricingTeam;

  /// No description provided for @pricingTeamPrice.
  ///
  /// In en, this message translates to:
  /// **'€19.99'**
  String get pricingTeamPrice;

  /// No description provided for @pricingTeamPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get pricingTeamPriceDesc;

  /// No description provided for @pricingTeamFeature1.
  ///
  /// In en, this message translates to:
  /// **'Everything in Pro'**
  String get pricingTeamFeature1;

  /// No description provided for @pricingTeamFeature2.
  ///
  /// In en, this message translates to:
  /// **'Team collaboration'**
  String get pricingTeamFeature2;

  /// No description provided for @pricingTeamFeature3.
  ///
  /// In en, this message translates to:
  /// **'Shared calendars'**
  String get pricingTeamFeature3;

  /// No description provided for @pricingTeamFeature4.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get pricingTeamFeature4;

  /// No description provided for @contactSales.
  ///
  /// In en, this message translates to:
  /// **'Contact Sales'**
  String get contactSales;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faq1Question.
  ///
  /// In en, this message translates to:
  /// **'What types of events can FollowUP recognize?'**
  String get faq1Question;

  /// No description provided for @faq1Answer.
  ///
  /// In en, this message translates to:
  /// **'FollowUP can recognize most event formats including concerts, meetings, conferences, social gatherings, and more. It works with both formal and informal event descriptions.'**
  String get faq1Answer;

  /// No description provided for @faq2Question.
  ///
  /// In en, this message translates to:
  /// **'How accurate is the AI recognition?'**
  String get faq2Question;

  /// No description provided for @faq2Answer.
  ///
  /// In en, this message translates to:
  /// **'Our AI achieves 95%+ accuracy for standard event formats. You can always review and edit the extracted information before saving.'**
  String get faq2Answer;

  /// No description provided for @faq3Question.
  ///
  /// In en, this message translates to:
  /// **'Can I sync with Google Calendar or Apple Calendar?'**
  String get faq3Question;

  /// No description provided for @faq3Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Export events as ICS files and import them into any calendar app including Google Calendar, Apple Calendar, Outlook, and more.'**
  String get faq3Answer;

  /// No description provided for @faq4Question.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faq4Question;

  /// No description provided for @faq4Answer.
  ///
  /// In en, this message translates to:
  /// **'Absolutely. We use industry-standard encryption and never share your data with third parties. Your events are stored securely and only accessible by you.'**
  String get faq4Answer;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Smart Event Assistant'**
  String get footerTagline;

  /// No description provided for @footerProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get footerProduct;

  /// No description provided for @footerFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get footerFeatures;

  /// No description provided for @footerPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get footerPricing;

  /// No description provided for @footerCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get footerCompany;

  /// No description provided for @footerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get footerAbout;

  /// No description provided for @footerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get footerContact;

  /// No description provided for @footerLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get footerLegal;

  /// No description provided for @footerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get footerPrivacy;

  /// No description provided for @footerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get footerTerms;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 FollowUP. All rights reserved.'**
  String get footerCopyright;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @privacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get privacyFirst;

  /// No description provided for @quickSetup.
  ///
  /// In en, this message translates to:
  /// **'30 Second Setup'**
  String get quickSetup;

  /// No description provided for @freeToStart.
  ///
  /// In en, this message translates to:
  /// **'Free to Start'**
  String get freeToStart;

  /// No description provided for @painPointsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Life events come at you fast'**
  String get painPointsSubtitle;

  /// No description provided for @painPointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Important dates come as screenshots, posters, messages, or voice memos.\nManually adding to calendar? Tedious and easy to forget.'**
  String get painPointsDesc;

  /// No description provided for @painPointNeedSimpler.
  ///
  /// In en, this message translates to:
  /// **'You need a simpler way'**
  String get painPointNeedSimpler;

  /// No description provided for @painPointPhoto.
  ///
  /// In en, this message translates to:
  /// **'Event poster screenshots'**
  String get painPointPhoto;

  /// No description provided for @painPointMessage.
  ///
  /// In en, this message translates to:
  /// **'Dates in messages'**
  String get painPointMessage;

  /// No description provided for @painPointFlyer.
  ///
  /// In en, this message translates to:
  /// **'Flyers and invitations'**
  String get painPointFlyer;

  /// No description provided for @painPointVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice memos'**
  String get painPointVoice;

  /// No description provided for @captureStep.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureStep;

  /// No description provided for @captureStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Photo, text, or voice'**
  String get captureStepDesc;

  /// No description provided for @understandStep.
  ///
  /// In en, this message translates to:
  /// **'Understand'**
  String get understandStep;

  /// No description provided for @understandStepDesc.
  ///
  /// In en, this message translates to:
  /// **'AI smart processing'**
  String get understandStepDesc;

  /// No description provided for @confirmStep.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmStep;

  /// No description provided for @confirmStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Review and edit'**
  String get confirmStepDesc;

  /// No description provided for @doneStep.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneStep;

  /// No description provided for @doneStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get doneStepDesc;

  /// No description provided for @featurePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get featurePrivacyTitle;

  /// No description provided for @featurePrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'No account required, your data is stored securely'**
  String get featurePrivacyDesc;

  /// No description provided for @featureSmartTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Recognition'**
  String get featureSmartTitle;

  /// No description provided for @featureSmartDesc.
  ///
  /// In en, this message translates to:
  /// **'AI automatically extracts date, time, location and key info'**
  String get featureSmartDesc;

  /// No description provided for @featureControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Control'**
  String get featureControlTitle;

  /// No description provided for @featureControlDesc.
  ///
  /// In en, this message translates to:
  /// **'Review and edit recognition results before confirming'**
  String get featureControlDesc;

  /// No description provided for @featureFocusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce mental load, focus on life'**
  String get featureFocusSubtitle;

  /// No description provided for @featureFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'FollowUP quietly manages your schedule, letting you focus on what really matters'**
  String get featureFocusDesc;

  /// No description provided for @demoInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get demoInputLabel;

  /// No description provided for @demoTextTab.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get demoTextTab;

  /// No description provided for @demoImageTab.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get demoImageTab;

  /// No description provided for @demoVoiceTab.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get demoVoiceTab;

  /// No description provided for @demoInputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter text containing event information...'**
  String get demoInputPlaceholder;

  /// No description provided for @demoClickUpload.
  ///
  /// In en, this message translates to:
  /// **'Click to upload image'**
  String get demoClickUpload;

  /// No description provided for @demoClickRecord.
  ///
  /// In en, this message translates to:
  /// **'Click to start recording'**
  String get demoClickRecord;

  /// No description provided for @demoEventPreview.
  ///
  /// In en, this message translates to:
  /// **'Event Preview'**
  String get demoEventPreview;

  /// No description provided for @demoTeamDinner.
  ///
  /// In en, this message translates to:
  /// **'Team Dinner'**
  String get demoTeamDinner;

  /// No description provided for @demoRecognized.
  ///
  /// In en, this message translates to:
  /// **'Successfully recognized'**
  String get demoRecognized;

  /// No description provided for @demoNextFriday.
  ///
  /// In en, this message translates to:
  /// **'Next Friday 19:00'**
  String get demoNextFriday;

  /// No description provided for @demoRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Olive Garden Restaurant · Main Street'**
  String get demoRestaurant;

  /// No description provided for @demoBirthdayCard.
  ///
  /// In en, this message translates to:
  /// **'Remember to bring Sarah\'s birthday card'**
  String get demoBirthdayCard;

  /// No description provided for @demoExtractedEvent.
  ///
  /// In en, this message translates to:
  /// **'Extracted event will appear here'**
  String get demoExtractedEvent;

  /// No description provided for @demoAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get demoAddToCalendar;

  /// No description provided for @theProblem.
  ///
  /// In en, this message translates to:
  /// **'The Problem'**
  String get theProblem;

  /// No description provided for @stillHaveQuestions.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get stillHaveQuestions;

  /// No description provided for @everythingYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to know about FollowUP'**
  String get everythingYouNeed;

  /// No description provided for @footerCTATitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to never forget an event again?'**
  String get footerCTATitle;

  /// No description provided for @footerCTASubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start using FollowUP for free and let AI manage your schedule'**
  String get footerCTASubtitle;

  /// No description provided for @footerDescription.
  ///
  /// In en, this message translates to:
  /// **'Transform life\'s moments into calendar events\nNever worry about forgetting again'**
  String get footerDescription;

  /// No description provided for @chatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi {username}! 👋 I\'m your FollowUP assistant. Tell me about an event you\'d like to add to your calendar, or paste any text containing event information.'**
  String chatWelcome(String username);

  /// No description provided for @chatStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation to add events'**
  String get chatStartHint;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Describe an event or paste text...'**
  String get chatInputHint;

  /// No description provided for @chatProcessing.
  ///
  /// In en, this message translates to:
  /// **'I found event information in your message! Would you like me to extract the details and add it to your calendar?'**
  String get chatProcessing;

  /// No description provided for @chatExtractEvent.
  ///
  /// In en, this message translates to:
  /// **'Extract Event'**
  String get chatExtractEvent;

  /// No description provided for @chatUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get chatUploadImage;

  /// No description provided for @chatViewEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get chatViewEvents;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Info'**
  String get accountInfo;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @registeredAt.
  ///
  /// In en, this message translates to:
  /// **'Registered At'**
  String get registeredAt;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @serverConnection.
  ///
  /// In en, this message translates to:
  /// **'Server Connection'**
  String get serverConnection;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @unableToGetUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to get user info'**
  String get unableToGetUserInfo;

  /// No description provided for @sourceTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get sourceTypeImage;

  /// No description provided for @sourceTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get sourceTypeText;

  /// No description provided for @sourceImage.
  ///
  /// In en, this message translates to:
  /// **'Source Image'**
  String get sourceImage;
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
      <String>['de', 'en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
