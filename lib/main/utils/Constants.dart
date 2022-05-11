const mAppName = 'Mighty Delivery';
const mPrivacyPolicy = 'https://meetmighty.com/codecanyon/document/mighty-delivery/';
const mTermAndCondition = 'https://meetmighty.com/codecanyon/document/mighty-delivery/';
const mHelpAndSupport = 'https://support.meetmighty.com/';
const mContactPref = 'hello@meetmighty.com';
const mCodeCanyonURL = 'https://codecanyon.net/user/meetmighty/portfolio/';

const mBaseUrl = 'https://meetmighty.com/mobile/mighty-local-delivery/api/';
const googleMapAPIKey = 'AIzaSyBAm_XYdWpfE2U_aLkMFGcG9H5wk1yY4yY';

const mOneSignalAppId = 'f2e9c538-d4ad-45d4-8c57-fd081c987fb6';
const mOneSignalRestKey = 'NzcwNjExNzYtYTJjOS00NGNkLWE2ZTUtY2JmMDEyNTFhYTFm';
const mOneSignalChannelId = 'e2422a99-3f76-4afa-a190-e80ab9370270';

const defaultLanguage = "en";

// font size
const headingSize = 24;
const currencySymbol = '₹';
const currencyCode = 'NGN';

// SharedReference keys
const IS_LOGGED_IN = 'IS_LOGIN';
const IS_FIRST_TIME = 'IS_FIRST_TIME';

const USER_ID = 'USER_ID';
const NAME = 'NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_TOKEN = 'USER_TOKEN';
const USER_CONTACT_NUMBER = 'USER_CONTACT_NUMBER';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_TYPE = 'USER_TYPE';
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_ADDRESS = 'USER_ADDRESS';
const STATUS = 'STATUS';
const PLAYER_ID = 'PLAYER_ID';
const FILTER_DATA = 'FILTER_DATA';
const UID = 'UID';
const IS_VERIFIED_DELIVERY_MAN = 'IS_VERIFIED_DELIVERY_MAN';

const COUNTRY_ID = 'COUNTRY_ID';
const COUNTRY_DATA = 'COUNTRY_DATA';

const CITY_ID = 'City';
const CITY_DATA = 'CITY_DATA';

const CLIENT = 'client';
const DELIVERY_MAN = 'delivery_man';

const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';

const PAYMENT_TYPE_STRIPE = 'stripe';
const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYSTACK = 'paystack';
const PAYMENT_TYPE_FLUTTERWAVE = 'flutterwave';
const PAYMENT_TYPE_PAYPAL = 'paypal';
const PAYMENT_TYPE_PAYTABS = 'paytabs';
const PAYMENT_TYPE_MERCADOPAGO = 'mercadopago';
const PAYMENT_TYPE_PAYTM = 'paytm';
const PAYMENT_TYPE_MYFATOORAH = 'myfatoorah';
const PAYMENT_TYPE_CASH = 'cash';

const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';

const PAYMENT_ON_DELIVERY = "on_delivery";
const PAYMENT_ON_PICKUP = "on_pickup";

const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';
const DELETE_USER = 'deleted_at';

// OrderStatus
const COURIER_ASSIGNED = 'courier_assigned';
const COURIER_DEPARTED = 'courier_departed';
const COURIER_TRANSFER = 'courier_transfer';
const ORDER_CREATE = 'create';
const ORDER_ACTIVE = 'active';
const ORDER_CANCELLED = 'cancelled';
const ORDER_DELAYED = 'delayed';
const ORDER_ASSIGNED = 'courier_assigned';
const ORDER_ARRIVED = 'courier_arrived';
const ORDER_PICKED_UP = 'courier_picked_up';
const ORDER_COMPLETED = 'completed';
const ORDER_DRAFT = 'draft';
const ORDER_DEPARTED = 'courier_departed';

const stripeURL = 'https://api.stripe.com/v1/payment_intents';

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

AppThemeMode appThemeMode = AppThemeMode();

const REMEMBER_ME = 'REMEMBER_ME';

const mAppIconUrl = "assets/app_logo.jpg";

///FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;

const TEXT = "TEXT";
const IMAGE = "IMAGE";

const VIDEO = "VIDEO";
const AUDIO = "AUDIO";

const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";

//chat
List<String> rtlLanguage = ['ar', 'ur'];

enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}
