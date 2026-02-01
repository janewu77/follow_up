// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FollowUP';

  @override
  String get login => 'Login';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get username => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get testAccount => 'Test Account:';

  @override
  String get testAccountAlice => 'Username: alice / Password: alice123';

  @override
  String get testAccountDemo => 'Username: demo / Password: demo123';

  @override
  String get home => 'Home';

  @override
  String get add => 'Add';

  @override
  String get events => 'Events';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to logout?';

  @override
  String welcomeBack(String username) {
    return 'Welcome back, $username';
  }

  @override
  String get addEventPrompt => 'Any new events to add today?';

  @override
  String get textRecognition => 'Text Recognition';

  @override
  String get inputDescription => 'Input description';

  @override
  String get imageRecognition => 'Image Recognition';

  @override
  String get photoOrUpload => 'Photo or upload';

  @override
  String get followedEvents => 'Followed Events';

  @override
  String get viewAll => 'View All';

  @override
  String get noFollowedEvents => 'No followed events yet';

  @override
  String get addEvent => 'Add Event';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get pasteDescription =>
      'Paste event description, AI will automatically recognize time, location, etc.';

  @override
  String get eventDescription => 'Event Description';

  @override
  String get eventDescriptionHint =>
      'e.g., Next Saturday at 7pm, there\'s a Beethoven concert at Hamburg Philharmonic...';

  @override
  String get additionalNote => 'Additional Note (Optional)';

  @override
  String get uploadPoster =>
      'Upload event poster or flyer, AI will automatically recognize event information';

  @override
  String get eventImage => 'Event Image';

  @override
  String get recognizeSchedule => 'Recognize Schedule';

  @override
  String get aiRecognizing => 'AI is recognizing event information...';

  @override
  String get schedulePreview => 'Schedule Preview';

  @override
  String get editActivity => 'Edit Activity';

  @override
  String get confirmActivity => 'Confirm Activity';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get enterEventTitle => 'Enter event title';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get location => 'Location';

  @override
  String get eventLocation => 'Event location';

  @override
  String get description => 'Description';

  @override
  String get eventDescriptionField => 'Event description...';

  @override
  String get downloadIcs => 'Download ICS';

  @override
  String get saveActivity => 'Save Activity';

  @override
  String get saving => 'Saving...';

  @override
  String get activitySaved => 'Activity saved';

  @override
  String multipleEventsDetected(int count) {
    return 'Detected $count events, swipe left/right to switch';
  }

  @override
  String get eventList => 'Event List';

  @override
  String get allEvents => 'All Events';

  @override
  String get followed => 'Followed';

  @override
  String get noEvents => 'No events yet';

  @override
  String get noFollowedEventsYet => 'No followed events yet';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get deleteEventConfirm =>
      'Are you sure you want to delete this event? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get eventDeleted => 'Event deleted';

  @override
  String get icsDownloaded => 'ICS file downloaded';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get fileSaved => 'File saved';

  @override
  String get pleaseEnterEventDescription => 'Please enter event description';

  @override
  String get pleaseSelectImage => 'Please select an image';

  @override
  String get pleaseEnterEventTitle => 'Please enter event title';

  @override
  String get pleaseSelectStartDate => 'Please select start date';

  @override
  String get landingHeroTitle => 'Never Miss an Event Again';

  @override
  String get landingHeroSubtitle =>
      'FollowUP is your smart personal assistant for tracking events. Automatically extract event information from text or images, sync to your calendar, and get timely reminders.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get learnMore => 'Learn More';

  @override
  String get painPointsTitle => 'Do You Ever Experience These Problems?';

  @override
  String get painPoint1Title => 'Scattered Information';

  @override
  String get painPoint1Desc =>
      'Event info buried in emails, chats, and social media, hard to track';

  @override
  String get painPoint2Title => 'Manual Entry is Tedious';

  @override
  String get painPoint2Desc =>
      'Manually entering events into calendar is time-consuming and error-prone';

  @override
  String get painPoint3Title => 'Easy to Forget';

  @override
  String get painPoint3Desc =>
      'Missing important events due to no timely reminders';

  @override
  String get howItWorksTitle => 'How It Works';

  @override
  String get step1Title => 'Capture Information';

  @override
  String get step1Desc => 'Paste text or upload event poster/screenshot';

  @override
  String get step2Title => 'AI Recognition';

  @override
  String get step2Desc =>
      'Intelligently extract time, location, and other key info';

  @override
  String get step3Title => 'One-Click Save';

  @override
  String get step3Desc => 'Confirm and add to calendar with reminders';

  @override
  String get featuresTitle => 'Key Features';

  @override
  String get feature1Title => 'Text Recognition';

  @override
  String get feature1Desc =>
      'Paste event description and let AI extract the information';

  @override
  String get feature2Title => 'Image Recognition';

  @override
  String get feature2Desc =>
      'Upload event posters or screenshots for automatic parsing';

  @override
  String get feature3Title => 'Calendar Sync';

  @override
  String get feature3Desc => 'Export to ICS format, sync with any calendar app';

  @override
  String get feature4Title => 'Follow Events';

  @override
  String get feature4Desc => 'Follow important events for timely reminders';

  @override
  String get demoTitle => 'See It In Action';

  @override
  String get demoDesc =>
      'Watch how FollowUP transforms messy event info into organized calendar entries';

  @override
  String get tryNow => 'Try Now';

  @override
  String get pricingTitle => 'Simple, Transparent Pricing';

  @override
  String get pricingFree => 'Free';

  @override
  String get pricingFreePriceDesc => 'for personal use';

  @override
  String get pricingFreeFeature1 => '10 events per month';

  @override
  String get pricingFreeFeature2 => 'Text recognition';

  @override
  String get pricingFreeFeature3 => 'Basic calendar export';

  @override
  String get pricingPro => 'Pro';

  @override
  String get pricingProPrice => '€4.99';

  @override
  String get pricingProPriceDesc => '/month';

  @override
  String get pricingProFeature1 => 'Unlimited events';

  @override
  String get pricingProFeature2 => 'Image recognition';

  @override
  String get pricingProFeature3 => 'Priority AI processing';

  @override
  String get pricingProFeature4 => 'Advanced reminders';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get startFreeTrial => 'Start Free Trial';

  @override
  String get pricingTeam => 'Team';

  @override
  String get pricingTeamPrice => '€19.99';

  @override
  String get pricingTeamPriceDesc => '/month';

  @override
  String get pricingTeamFeature1 => 'Everything in Pro';

  @override
  String get pricingTeamFeature2 => 'Team collaboration';

  @override
  String get pricingTeamFeature3 => 'Shared calendars';

  @override
  String get pricingTeamFeature4 => 'Admin dashboard';

  @override
  String get contactSales => 'Contact Sales';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faq1Question => 'What types of events can FollowUP recognize?';

  @override
  String get faq1Answer =>
      'FollowUP can recognize most event formats including concerts, meetings, conferences, social gatherings, and more. It works with both formal and informal event descriptions.';

  @override
  String get faq2Question => 'How accurate is the AI recognition?';

  @override
  String get faq2Answer =>
      'Our AI achieves 95%+ accuracy for standard event formats. You can always review and edit the extracted information before saving.';

  @override
  String get faq3Question =>
      'Can I sync with Google Calendar or Apple Calendar?';

  @override
  String get faq3Answer =>
      'Yes! Export events as ICS files and import them into any calendar app including Google Calendar, Apple Calendar, Outlook, and more.';

  @override
  String get faq4Question => 'Is my data secure?';

  @override
  String get faq4Answer =>
      'Absolutely. We use industry-standard encryption and never share your data with third parties. Your events are stored securely and only accessible by you.';

  @override
  String get footerTagline => 'Your Smart Event Assistant';

  @override
  String get footerProduct => 'Product';

  @override
  String get footerFeatures => 'Features';

  @override
  String get footerPricing => 'Pricing';

  @override
  String get footerCompany => 'Company';

  @override
  String get footerAbout => 'About';

  @override
  String get footerContact => 'Contact';

  @override
  String get footerLegal => 'Legal';

  @override
  String get footerPrivacy => 'Privacy';

  @override
  String get footerTerms => 'Terms';

  @override
  String get footerCopyright => '© 2025 FollowUP. All rights reserved.';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'or';

  @override
  String get privacyFirst => 'Privacy First';

  @override
  String get quickSetup => '30 Second Setup';

  @override
  String get freeToStart => 'Free to Start';

  @override
  String get painPointsSubtitle => 'Life events come at you fast';

  @override
  String get painPointsDesc =>
      'Important dates come as screenshots, posters, messages, or voice memos.\nManually adding to calendar? Tedious and easy to forget.';

  @override
  String get painPointNeedSimpler => 'You need a simpler way';

  @override
  String get painPointPhoto => 'Event poster screenshots';

  @override
  String get painPointMessage => 'Dates in messages';

  @override
  String get painPointFlyer => 'Flyers and invitations';

  @override
  String get painPointVoice => 'Voice memos';

  @override
  String get captureStep => 'Capture';

  @override
  String get captureStepDesc => 'Photo, text, or voice';

  @override
  String get understandStep => 'Understand';

  @override
  String get understandStepDesc => 'AI smart processing';

  @override
  String get confirmStep => 'Confirm';

  @override
  String get confirmStepDesc => 'Review and edit';

  @override
  String get doneStep => 'Done';

  @override
  String get doneStepDesc => 'Add to calendar';

  @override
  String get featurePrivacyTitle => 'Privacy First';

  @override
  String get featurePrivacyDesc =>
      'No account required, your data is stored securely';

  @override
  String get featureSmartTitle => 'Smart Recognition';

  @override
  String get featureSmartDesc =>
      'AI automatically extracts date, time, location and key info';

  @override
  String get featureControlTitle => 'Full Control';

  @override
  String get featureControlDesc =>
      'Review and edit recognition results before confirming';

  @override
  String get featureFocusSubtitle => 'Reduce mental load, focus on life';

  @override
  String get featureFocusDesc =>
      'FollowUP quietly manages your schedule, letting you focus on what really matters';

  @override
  String get demoInputLabel => 'Input';

  @override
  String get demoTextTab => 'Text';

  @override
  String get demoImageTab => 'Image';

  @override
  String get demoVoiceTab => 'Voice';

  @override
  String get demoInputPlaceholder =>
      'Enter text containing event information...';

  @override
  String get demoClickUpload => 'Click to upload image';

  @override
  String get demoClickRecord => 'Click to start recording';

  @override
  String get demoEventPreview => 'Event Preview';

  @override
  String get demoTeamDinner => 'Team Dinner';

  @override
  String get demoRecognized => 'Successfully recognized';

  @override
  String get demoNextFriday => 'Next Friday 19:00';

  @override
  String get demoRestaurant => 'Olive Garden Restaurant · Main Street';

  @override
  String get demoBirthdayCard => 'Remember to bring Sarah\'s birthday card';

  @override
  String get demoExtractedEvent => 'Extracted event will appear here';

  @override
  String get demoAddToCalendar => 'Add to Calendar';

  @override
  String get theProblem => 'The Problem';

  @override
  String get stillHaveQuestions => 'Still have questions?';

  @override
  String get everythingYouNeed => 'Everything you need to know about FollowUP';

  @override
  String get footerCTATitle => 'Ready to never forget an event again?';

  @override
  String get footerCTASubtitle =>
      'Start using FollowUP for free and let AI manage your schedule';

  @override
  String get footerDescription =>
      'Transform life\'s moments into calendar events\nNever worry about forgetting again';

  @override
  String chatWelcome(String username) {
    return 'Hi $username! 👋 I\'m your FollowUP assistant. Tell me about an event you\'d like to add to your calendar, or paste any text containing event information.';
  }

  @override
  String get chatStartHint => 'Start a conversation to add events';

  @override
  String get chatInputHint => 'Describe an event or paste text...';

  @override
  String get chatProcessing =>
      'I found event information in your message! Would you like me to extract the details and add it to your calendar?';

  @override
  String get chatExtractEvent => 'Extract Event';

  @override
  String get chatUploadImage => 'Upload Image';

  @override
  String get chatViewEvents => 'My Events';

  @override
  String get profile => 'Profile';

  @override
  String get accountInfo => 'Account Info';

  @override
  String get userId => 'User ID';

  @override
  String get registeredAt => 'Registered At';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get serverConnection => 'Server Connection';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get testing => 'Testing...';

  @override
  String get unknown => 'Unknown';

  @override
  String get myEvents => 'My Events';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get retry => 'Retry';

  @override
  String get unableToGetUserInfo => 'Unable to get user info';

  @override
  String get sourceTypeImage => 'Image';

  @override
  String get sourceTypeText => 'Text';

  @override
  String get sourceImage => 'Source Image';
}
