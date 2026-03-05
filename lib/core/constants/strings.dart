const appName = 'VACCIGUIDE';
const appVersion = '1.0.0';

const welcomeMessage = 'مرحبًا بك في\n $appName';
const loginPrompt = 'الرجاء تسجيل الدخول للمتابعة';
const registerPrompt = 'ليس لديك حساب؟';
const registerNow = 'سجل الآن';
const alreadyHaveAccount = 'هل لديك حساب؟ تسجيل الدخول';
const invalidCredentials = 'بيانات الاعتماد غير صحيحة';

const fullName = 'الاسم الكامل';
const username = 'اسم المستخدم';
const email = 'البريد الإلكتروني';
const phone = 'رقم الهاتف';
const address = 'العنوان';
const gender = 'الجنس';
const userType = 'نوع المستخدم';
const male = 'ذكر';
const female = 'أنثى';

const child = 'طفل';
const parent = 'ولي أمر';
const other = 'آخر';
const password = 'كلمة المرور';
const confirmPassword = 'تأكيد كلمة المرور';

const forgotPassword = 'نسيت كلمة المرور؟';
const resetPasswordTitle = 'إعادة تعيين كلمة المرور';
const resetPasswordMessage =
    'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور';
const resetPasswordSend = 'إرسال الرابط';
const resetPasswordSending = 'جارٍ الإرسال...';
const resetPasswordSuccess =
    'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني ✅';
const resetPasswordCancel = 'إلغاء';
const login = 'تسجيل الدخول';
const next = 'التالي';
const back = 'رجوع';
const register = 'إنشاء حساب';
const logout = 'تسجيل الخروج';
const home = 'الرئيسية';
const profile = 'الملف الشخصي';
const settings = 'الإعدادات';
const notifications = 'الإشعارات';
const search = 'بحث';
const add = 'إضافة';
const edit = 'تعديل';
const delete = 'حذف';
const save = 'حفظ';
const cancel = 'إلغاء';
const update = 'تحديث';
const yes = 'نعم';
const no = 'لا';
const ok = 'موافق';
const loading = 'جارٍ التحميل...';
const error = 'حدث خطأ ما';
const success = 'تم بنجاح';
const noData = 'لا توجد بيانات';
const welcome = 'مرحبًا بك في $appName';
const enterEmail = 'الرجاء إدخال البريد الإلكتروني';
const enterPassword = 'الرجاء إدخال كلمة المرور';
const enterName = 'الرجاء إدخال الاسم';
const enterPhone = 'الرجاء إدخال رقم الهاتف';
const passwordsDoNotMatch = 'كلمتا المرور غير متطابقتين';
const invalidEmail = 'البريد الإلكتروني غير صالح';
const weakPassword = 'كلمة المرور ضعيفة';
const userNotFound = 'المستخدم غير موجود';
const wrongPassword = 'كلمة المرور غير صحيحة';
const accountExists = 'الحساب موجود بالفعل';
const fillAllFields = 'الرجاء ملء جميع الحقول';
const noInternet = 'لا يوجد اتصال بالإنترنت';
const tryAgain = 'حاول مرة أخرى';
const darkMode = 'الوضع الداكن';
const lightMode = 'الوضع الفاتح';
const language = 'اللغة';
const arabic = 'العربية';
const english = 'الإنجليزية';
const theme = 'السمة';
const version = 'الإصدار';
const about = 'حول';
const terms = 'الشروط والأحكام';
const privacy = 'سياسة الخصوصية';
const contactUs = 'اتصل بنا';
const faq = 'الأسئلة الشائعة';
const noNotifications = 'لا توجد إشعارات';
const markAllAsRead = 'وضع علامة مقروءة على الكل';
const viewAll = 'عرض الكل';
const notificationSettings = 'إعدادات الإشعارات';
const enableNotifications = 'تمكين الإشعارات';
const disableNotifications = 'تعطيل الإشعارات';
const selectClassroom = 'اختر الأسرة';

// Validation messages
const nameValidation = 'الاسم يجب أن يكون من 3 إلى 50 حرفًا';
const usernameValidation = 'اسم المستخدم يجب أن يكون من 3 إلى 20 حرفًا';
const phoneValidation = 'رقم الهاتف يجب أن يكون 11 رقمًا';
const addressValidation = 'العنوان يجب أن يكون من 5 إلى 100 حرفًا';
const passwordValidation = 'كلمة المرور يجب أن تكون من 6 إلى 20 حرفًا';
const genericError = 'حدث خطأ غير متوقع. الرجاء المحاولة لاحقًاًا.';
const unauthorized = 'غير مصرح. الرجاء تسجيل الدخول مرة أخرى.';
const forbidden = 'ممنوع. ليس لديك إذن للوصول إلى هذا المورد.';
const notFound = 'المورد غير موجود.';
const serverError = 'خطأ في الخادم. الرجاء المحاولة لاحقًا.';
const badRequest = 'طلب غير صالح. الرجاء التحقق من البيانات المدخلة.';
const timeoutError = 'انتهت مهلة الاتصال. الرجاء المحاولة مرة أخرى.';
const noResponse = 'لا يوجد رد من الخادم. الرجاء المحاولة مرة أخرى.';
const unexpectedError = 'حدث خطأ غير متوقع. الرجاء المحاولة لاحقًا.';
const offline = 'أنت غير متصل بالإنترنت. الرجاء التحقق من اتصال';
const online = 'أنت متصل بالإنترنت.';
const loadingData = 'جارٍ تحميل البيانات...';
const submit = 'إرسال';
const submitting = 'جارٍ الإرسال...';
const refreshing = 'جارٍ التحديث...';
const searching = 'جارٍ البحث...';
const noResults = 'لا توجد نتائج.';
const pullToRefresh = 'اسحب للتحديث';
const releaseToRefresh = 'حرر للتحديث';
const refreshingData = 'جارٍ تحديث البيانات...';
const lastUpdated = 'آخر تحديث: ';
const viewProfile = 'عرض الملف الشخصي';
const editProfile = 'تعديل الملف الشخصي';
const changePassword = 'تغيير كلمة المرور';
const currentPassword = 'كلمة المرور الحالية';
const newPassword = 'كلمة المرور الجديدة';
const confirmNewPassword = 'تأكيد كلمة المرور الجديدة';
const passwordChanged = 'تم تغيير كلمة المرور بنجاح';
const deleteAccount = 'حذف الحساب';
const accountDeleted = 'تم حذف الحساب بنجاح';
const areYouSure = 'هل أنت متأكد؟';
const thisActionCannotBeUndone = 'هذا الإجراء لا يمكن التراجع عنه.';
const enterCurrentPassword = 'الرجاء إدخال كلمة المرور الحالية';
const enterNewPassword = 'الرجاء إدخال كلمة المرور الجديدة';
const enterConfirmNewPassword = 'الرجاء تأكيد كلمة المرور الجديدة';
const passwordsMustMatch = 'كلمتا المرور يجب أن تتطابقا';
const weakNewPassword = 'كلمة المرور الجديدة ضعيفة';
const changeLanguage = 'تغيير اللغة';

// Fallback messages
const somethingWentWrong = 'حدث خطأ ما. الرجاء المحاولة لاحقًا.';
const unableToProcess = 'غير قادر على معالجة الطلب. الرجاء المحاولة لاحقًا.';
const actionFailed = 'فشل الإجراء. الرجاء المحاولة مرة أخرى.';
const actionSuccessful = 'تم الإجراء بنجاح.';
const loadingFailed = 'فشل التحميل. الرجاء المحاولة مرة أخرى.';

// Auth fallback messages
const authFailed = 'فشل المصادقة. الرجاء التحقق من بيانات الاعتماد الخاصة بك.';
const sessionExpired = 'انتهت الجلسة. الرجاء تسجيل الدخول مرة أخرى.';
const registrationFailed = 'فشل التسجيل. الرجاء المحاولة مرة أخرى.';
const registrationSuccessful = 'تم إنشاء الحساب بنجاح';
const passwordResetFailed =
    'فشل إعادة تعيين كلمة المرور. الرجاء المحاولة مرة أخرى.';
const passwordResetEmailSent =
    'تم إرسال بريد إلكتروني لإعادة تعيين كلمة المرور.';
const invalidResetToken = 'رمز إعادة التعيين غير صالح أو منتهي الصلاحية.';
const emailAlreadyInUse =
    'البريد الإلكتروني مستخدم بالفعل. الرجاء استخدام بريد إلكتروني مختلف.';
const usernameAlreadyInUse =
    'اسم المستخدم مستخدم بالفعل. الرجاء اختيار اسم مستخدم مختلف.';
const accountLocked = 'تم قفل الحساب. الرجاء الاتصال بالدعم.';
const tooManyAttempts = 'محاولات كثيرة جدًا. الرجاء المحاولة مرة أخرى لاحقًا.';
const verifyYourEmail = 'الرجاء التحقق من بريدك الإلكتروني لإكمال التسجيل.';
const emailNotVerified =
    'البريد الإلكتروني غير مُحقق. الرجاء التحقق من بريدك الإلكتروني.';
const resendVerificationEmail = 'إعادة إرسال بريد التحقق الإلكتروني.';
const checkYourEmail =
    'الرجاء التحقق من بريدك الإلكتروني للحصول على مزيد من التعليمات.';
const invalidEmailOrPassword = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
const accountDisabled = 'تم تعطيل الحساب. الرجاء الاتصال بالدعم.';
const loginSuccessful = 'تم تسجيل الدخول بنجاح.';
const logoutSuccessful = 'تم تسجيل الخروج بنجاح.';
const registrationComplete = 'اكتمل التسجيل. يمكنك الآن تسجيل الدخول.';
const loginFailed = 'فشل تسجيل الدخول. الرجاء الرجاء المحاولة مرة أخرى.';
const loginLoading = 'جارٍ تسجيل الدخول...';
const registering = 'جارٍ إنشاء الحساب...';

const sessionExpiredPleaseLoginAgain =
    'انتهت الجلسة. الرجاء تسجيل الدخول مرة أخرى.';

// Profile image strings
const profileImage = 'الصورة الشخصية';
const selectImage = 'اختر صورة';
const changeImage = 'تغيير الصورة';
const removeImage = 'إزالة الصورة';
const imageRequired = 'الصورة الشخصية مطلوبة';
const imageTooLarge = 'حجم الصورة كبير جدًا. الحد الأقصى 2 ميجابايت';
const imageSelected = 'تم اختيار الصورة';
const selectImageFromGallery = 'اختر من المعرض';
const takePhoto = 'التقط صورة';
const uploadingImage = 'جاري رفع الصورة...';
const pleaseWait = 'الرجاء الانتظار...';
const imageUploadFailed = 'فشل رفع الصورة. الرجاء المحاولة مرة أخرى.';
const imageUploadSuccessful = 'تم رفع الصورة بنجاح.';

// Login screen specific strings
const signInToContinue = 'سجّل الدخول للمتابعة';
const pleaseEnterYourEmail = 'الرجاء إدخال بريدك الإلكتروني';
const pleaseEnterValidEmail = 'الرجاء إدخال بريد إلكتروني صحيح';
const pleaseEnterYourPassword = 'الرجاء إدخال كلمة المرور';
const passwordMustBe6Characters =
    'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
const or = 'أو';
const signInWithGoogle = 'تسجيل الدخول بحساب جوجل';
const googleSignInFailed =
    'فشل تسجيل الدخول بحساب جوجل. يرجى المحاولة مرة أخرى';
const googleSignInCancelled = 'تم إلغاء تسجيل الدخول بحساب جوجل';
const googleSignInLoading = 'جارٍ تسجيل الدخول بحساب جوجل...';

// Complete Profile screen strings
const completeYourProfile = 'أكمل بياناتك الشخصية';
const completeProfileSubtitle = 'الرجاء إكمال بياناتك للمتابعة';
const profileCompletedSuccessfully = 'تم حفظ البيانات بنجاح';
const completeProfileError =
    'حدث خطأ أثناء حفظ البيانات. الرجاء المحاولة مرة أخرى';

// User-friendly error messages
const errorInvalidEmail = 'البريد الإلكتروني غير صحيح';
const errorUserNotFound = 'لم يتم العثور على حساب بهذا البريد الإلكتروني';
const errorWrongPassword = 'كلمة المرور غير صحيحة';
const errorUserDisabled = 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم';
const errorTooManyRequests = 'محاولات كثيرة جداً. يرجى المحاولة لاحقاً';
const errorNetworkRequestFailed =
    'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك';
const errorOperationNotAllowed = 'عملية غير مسموح بها';
const errorWeakPassword = 'كلمة المرور ضعيفة جداً';
const errorEmailAlreadyInUse = 'هذا البريد الإلكتروني مستخدم بالفعل';
const errorInvalidCredential = 'بيانات الدخول غير صحيحة';
const errorAccountExistsWithDifferentCredential =
    'يوجد حساب بهذا البريد الإلكتروني بطريقة تسجيل دخول مختلفة';
const errorRequiresRecentLogin =
    'يرجى تسجيل الدخول مرة أخرى لإتمام هذه العملية';
const errorUnknownError = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
const errorConnectionTimeout = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
const errorServerError = 'خطأ في الخادم. يرجى المحاولة لاحقاً';

// Registration Request Strings
const registrationRequestSubmitted = 'تم إرسال طلب التسجيل بنجاح';
const registrationRequestPending = 'طلب التسجيل قيد المراجعة';
const registrationRequestApproved = 'تم قبول طلب التسجيل';
const registrationRequestRejected = 'تم رفض طلب التسجيل';
const registrationRequestError = 'حدث خطأ أثناء إرسال طلب التسجيل';
const submittingRegistrationRequest = 'جارٍ إرسال طلب التسجيل...';
const checkRegistrationStatus = 'التحقق من حالة الطلب';
const registrationUnderReview = 'طلبك قيد المراجعة من قبل المسؤول';
const adminWillReviewSoon = 'سيقوم المسؤول بمراجعة طلبك قريباً';
const youWillBeNotified = 'سيتم إشعارك عند اتخاذ قرار';
const contactSupportForDetails = 'يمكنك التواصل مع الدعم لمزيد من التفاصيل';
const rejectionReason = 'سبب الرفض';
const requestDate = 'تاريخ الطلب';
const requestStatus = 'حالة الطلب';
const backToLogin = 'العودة لتسجيل الدخول';
const backToRegister = 'العودة للتسجيل';
const registrationRequestLoadError = 'خطأ في تحميل حالة الطلب';
const requestNotFound = 'لم يتم العثور على طلب التسجيل';
const tryAgainOrContactSupport = 'يرجى المحاولة مرة أخرى أو الاتصال بالدعم';

// Drawer strings
const drawerHome = 'الرئيسية';
const drawerProfile = 'الملف الشخصي';
const drawerNotifications = 'الإشعارات';
const drawerSettings = 'الإعدادات';
const drawerAbout = 'حول التطبيق';
const drawerContactUs = 'تواصل معنا';
const drawerLogout = 'تسجيل الخروج';
const drawerLogoutConfirmTitle = 'تسجيل الخروج';
const drawerLogoutConfirmMessage = 'هل أنت متأكد أنك تريد تسجيل الخروج؟';
const drawerLogoutConfirm = 'خروج';
const drawerLogoutCancel = 'إلغاء';
const drawerVersion = 'الإصدار';
const drawerAdminPanel = 'لوحة التحكم';

// About screen strings
const aboutVersion = 'الإصدار';
const aboutWhatIs = 'ما هو $appName؟';
const aboutDescription =
    '$appName هو تطبيق صحي شامل يهدف إلى أن يكون دليلك الموثوق لعالم التطعيمات. '
    'يوفر لك معلومات طبية دقيقة ومحدّثة عن جميع اللقاحات المتاحة، '
    'ويساعدك على تتبع جرعاتك وجرعات أطفالك بسهولة.\n\n'
    'سواء كنت أبًا يبحث عن جدول تطعيمات طفلك، أو مسافرًا يحتاج لمعرفة اللقاحات المطلوبة، '
    'أو ببساطة تريد الاطلاع على آخر الأخبار والتنبيهات الصحية — '
    '$appName هنا ليرشدك في كل خطوة.';

const aboutFeatures = 'المميزات';
const aboutFeatureSearch = 'دليل التطعيمات';
const aboutFeatureSearchDesc =
    'قاعدة بيانات شاملة للقاحات مصنّفة حسب الفئة العمرية وتطعيمات السفر والتطعيمات الإضافية';
const aboutFeatureHistory = 'سجل التطعيمات';
const aboutFeatureHistoryDesc =
    'سجّل جرعاتك واحتفظ بسجل رقمي كامل لتاريخ تطعيماتك';
const aboutFeatureReminders = 'تذكير بالجرعات';
const aboutFeatureRemindersDesc =
    'إشعارات تلقائية تذكّرك بمواعيد الجرعات القادمة حتى لا تفوّت أي موعد';
const aboutFeatureAlerts = 'تنبيهات صحية';
const aboutFeatureAlertsDesc =
    'تنبيهات فورية عند إضافة لقاحات جديدة أو حملات تطعيم طارئة';
const aboutFeatureArticles = 'مقالات وأخبار';
const aboutFeatureArticlesDesc =
    'مقالات صحية موثوقة عن التطعيمات وآخر المستجدات الطبية';
const aboutFeatureAdmin = 'لوحة تحكم المسؤول';
const aboutFeatureAdminDesc =
    'إدارة كاملة للتطعيمات والمقالات والتنبيهات والمستخدمين';

const aboutBuiltWith = 'مبني بـ';
const aboutDeveloper = 'المطوّر';
const aboutDeveloperName = 'Andrew Michel';
const aboutDeveloperDesc = 'مطور تطبيقات Flutter';
const aboutCopyright = '© 2026 $appName. جميع الحقوق محفوظة.';

// Contact Us / Support strings
const contactUsTitle = 'تواصل معنا';
const contactUsSubtitle = 'نحن هنا لمساعدتك';
const contactUsDesc = 'أرسل لنا استفسارك أو مشكلتك وسنرد عليك في أقرب وقت';
const contactUsName = 'الاسم';
const contactUsEmail = 'البريد الإلكتروني';
const contactUsSubject = 'الموضوع';
const contactUsSubjectHint = 'اكتب موضوع رسالتك...';
const contactUsMessage = 'الرسالة';
const contactUsMessageHint = 'اكتب رسالتك بالتفصيل...';
const contactUsFieldRequired = 'هذا الحقل مطلوب';
const contactUsMessageTooShort = 'الرسالة قصيرة جداً (10 أحرف على الأقل)';
const contactUsSubmit = 'إرسال';
const contactUsSubmitting = 'جارٍ الإرسال...';
const contactUsSuccess = 'تم إرسال رسالتك بنجاح ✅ سنرد عليك قريباً';
const contactUsError = 'حدث خطأ أثناء الإرسال';
const contactUsPreviousTickets = 'رسائلك السابقة';
const contactUsNoTickets = 'لا توجد رسائل سابقة';
const contactUsStatusOpen = 'مفتوح';
const contactUsStatusInProgress = 'قيد المعالجة';
const contactUsStatusResolved = 'تم الحل';

// Admin Panel strings
const adminPanelTitle = 'لوحة التحكم';
const adminTabVaccines = 'التطعيمات';
const adminTabArticles = 'المقالات';
const adminTabAlerts = 'التنبيهات';
const adminTabUsers = 'المستخدمين';
const adminAddVaccine = 'إضافة تطعيم';
const adminEditVaccine = 'تعديل التطعيم';
const adminDeleteVaccine = 'حذف التطعيم';
const adminAddArticle = 'إضافة مقال';
const adminEditArticle = 'تعديل المقال';
const adminDeleteArticle = 'حذف المقال';
const adminAddAlert = 'إضافة تنبيه';
const adminEditAlert = 'تعديل التنبيه';
const adminDeleteAlert = 'حذف التنبيه';
const adminPromoteUser = 'ترقية إلى مسؤول';
const adminDemoteUser = 'تخفيض إلى مستخدم';
const adminDeleteUser = 'حذف المستخدم';
const adminFieldRequired = 'هذا الحقل مطلوب';
const adminConfirmDelete = 'هل أنت متأكد؟';
const adminRoleAdmin = 'مسؤول';
const adminRoleUser = 'مستخدم';
const adminAlertActive = 'نشط';
const adminAlertInactive = 'غير نشط';
const adminPublished = 'منشور';
const adminDraft = 'مسودة';
const adminSeverityHigh = 'عالية';
const adminSeverityMedium = 'متوسطة';
const adminSeverityInfo = 'معلوماتي';

// Home screen strings
const homeLatestNews = 'آخر الأخبار';
const homeNoArticles = 'لا توجد مقالات حالياً';
const homeArticleDetail = 'المقال';
const homeLoadError = 'حدث خطأ أثناء تحميل البيانات';
const homeRetry = 'إعادة المحاولة';

// Bottom Navigation strings
const navHome = 'الرئيسية';
const navHistory = 'السجل';
const navVaccineSearch = 'بحث اللقاحات';

// Vaccine Search strings
const vaccineSearchTitle = 'دليل التطعيمات';
const vaccineSearchSubtitle = 'اختر الفئة للبحث عن التطعيمات';
const vaccineSearchNoResults = 'لا توجد تطعيمات لهذا الاختيار';
const vaccineSearchError = 'حدث خطأ أثناء تحميل التطعيمات';
const vaccineSearchRetry = 'إعادة المحاولة';
const vaccineSearchBack = 'رجوع';
const vaccineSelectSubcategory = 'اختر الفئة الفرعية';
const vaccineTravelSearchHint = 'ابحث باسم الدولة...';
const vaccineTravelSearchButton = 'بحث';

// Vaccine Detail strings
const vaccineDetailName = 'اسم التطعيم';
const vaccineDetailImportance = 'أهمية التطعيم والأمراض التي يقي منها';
const vaccineDetailSchedule = 'الجدول الزمني وعدد الجرعات ومدة فعاليته';
const vaccineDetailAdministration = 'طريقة الإعطاء';
const vaccineDetailSideEffects = 'الآثار الجانبية والأدوية اللازمة لها';
const vaccineDetailLocations = 'أماكن تلقي التطعيم';
const vaccineDetailPrecautions = 'الاحتياطات اللازمة قبل أو بعد تلقي التطعيم';
const vaccineDetailWarnings = 'متى يجب تجنبه أو نصائح أو تحذيرات';

// Profile screen strings
const profileTitle = 'الملف الشخصي';
const profilePersonalInfo = 'المعلومات الشخصية';
const profileVaccineHistory = 'سجل التطعيمات';
const profileNoVaccineHistory = 'لا يوجد سجل تطعيمات بعد';
const profileDose = 'الجرعة';
const profileDate = 'التاريخ';
const profileMemberSince = 'عضو منذ';
const profileLoadError = 'حدث خطأ أثناء تحميل البيانات';
const profileNotFound = 'لم يتم العثور على بيانات المستخدم';
const profileEditSuccess = 'تم تحديث البيانات بنجاح';
const profileEditError = 'حدث خطأ أثناء تحديث البيانات';
const profileSave = 'حفظ التعديلات';

// Dose Recording strings
const doseRecordTitle = 'تسجيل جرعة';
const doseRecordButton = 'سجّل جرعة';
const doseRecordSuccess = 'تم تسجيل الجرعة بنجاح ✅';
const doseRecordSuccessWithReminder =
    'تم تسجيل الجرعة بنجاح ✅ سيتم تذكيرك بالجرعة القادمة';
const doseRecordError = 'حدث خطأ أثناء تسجيل الجرعة';
const doseRecordDate = 'تاريخ التطعيم';
const doseRecordNotes = 'ملاحظات (اختياري)';
const doseRecordNumber = 'رقم الجرعة';
const doseRecordProgress = 'تقدم الجرعات';
const doseRecordSubmit = 'تسجيل الجرعة';
const doseRecordSubmitting = 'جارٍ التسجيل...';
const doseUpcoming = 'الجرعات القادمة';
const doseUpcomingReminder = 'سيتم تذكيرك بموعد';
const doseOverdue = 'متأخر';
const doseToday = 'اليوم!';
const doseDaysLeft = 'بعد';
const doseSearchAndRecord = 'ابحث عن تطعيم وسجّل جرعتك الأولى';
// Feedback strings
const feedbackTitle = 'تقييم التطبيق';
const feedbackSubtitle = 'رأيك يهمنا!';
const feedbackDesc = 'ساعدنا نحسّن التطبيق من خلال تقييمك وملاحظاتك';
const feedbackEaseOfUse = 'هل التطبيق سهل الاستخدام والتنقل فيه؟';
const feedbackClarityOfInfo = 'هل المعلومات المقدمة واضحة ومفهومة؟';
const feedbackReliability = 'هل تثق في دقة وموثوقية المعلومات الطبية؟';
const feedbackOverallExperience = 'كيف تقيّم تجربتك العامة مع التطبيق؟';
const feedbackAdditionalFeatures = 'هل عندك اقتراحات أو مميزات إضافية تتمناها؟';
const feedbackAdditionalFeaturesHint = 'اكتب اقتراحاتك هنا... (اختياري)';
const feedbackSubmit = 'إرسال التقييم';
const feedbackSubmitting = 'جارٍ إرسال التقييم...';
const feedbackSuccess = 'شكراً لتقييمك! رأيك يساعدنا نتحسن ❤️';
const feedbackError = 'حدث خطأ أثناء إرسال التقييم';
const feedbackAlreadySubmitted = 'لقد قمت بإرسال تقييمك من قبل. شكراً لك! 🌟';
const feedbackPleaseRate = 'الرجاء تقييم جميع النقاط';
const drawerFeedback = 'تقييم التطبيق';
