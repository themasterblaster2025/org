const mAppName = 'On Demand Local Delivery';

const mBaseUrl = 'https://meetmighty.com/mobile/mighty-local-delivery/api/';
const googleMapAPIKey = 'AIzaSyBAm_XYdWpfE2U_aLkMFGcG9H5wk1yY4yY';

const mOneSignalAppId = 'f2e9c538-d4ad-45d4-8c57-fd081c987fb6';
const mOneSignalRestKey = 'NzcwNjExNzYtYTJjOS00NGNkLWE2ZTUtY2JmMDEyNTFhYTFm';
const mOneSignalChannelId = '9a4cc981-4c6b-4baf-8c5c-915f907446ae';

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
const PAYMENT_TYPE_CASH = 'cash';

const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';

const PAYMENT_ON_DELIVERY = "on_delivery";
const PAYMENT_ON_PICKUP = "on_pickup";

const RESTORE = 'restore';
const FORCE_DELETE = 'forcedelete';

// OrderStatus
const COURIER_ASSIGNED = 'courier_assigned';
const COURIER_DEPARTED = 'courier_departed';
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

/*///RazorPay
const razorKey = "rzp_test_CLw7tH3O3P5eQM";

///StripPayment
const stripeURL = 'https://api.stripe.com/v1/payment_intents';
const stripPaymentKey = 'sk_test_51GrhA2Bz1ljKAgF9FIJPLupBUCHFCOy5rS6LCnYHSu6Od0Qyx3TElGbxIu8BGRvq14fgidGOYyNkQPivZGnzWoVt004fCZxVdk';
const stripPaymentPublishKey = 'pk_test_51GrhA2Bz1ljKAgF98fI6WfB2YUn4CewOB0DNQC1pSeXspUc1LlUYs3ou19oPF0ATcqa52FXTYmv6v0mkvPZb9BSD00SUpBj9tI';

///FlutterWave
const flutterWavePublicKey = 'FLWPUBK_TEST-eb3edef083c890a7e22dc7eec9e0daa5-X';
const flutterWaveSecretKey = 'FLWSECK_TEST-d2759023efce6198a853b8e2dd3beb55-X';
const flutterWaveEncryptionKey = 'FLWSECK_TEST8497cc2db86c';

///PAY STACK DETAIL
const payStackPublicKey = 'pk_test_c46ddf9def17e34152daa1b6e2eb940dedea41f0';*/

class AppThemeMode {
  final int themeModeLight = 1;
  final int themeModeDark = 2;
  final int themeModeSystem = 0;
}

AppThemeMode appThemeMode = AppThemeMode();

const REMEMBER_ME = 'REMEMBER_ME';
