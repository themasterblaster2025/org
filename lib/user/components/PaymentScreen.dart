import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterwave_standard/core/TransactionCallBack.dart';
import 'package:flutterwave_standard/core/navigation_controller.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/requests/standard_request.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:flutterwave_standard/view/flutterwave_style.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/PaymentGatewayListModel.dart';
import 'package:mighty_delivery/main/models/StripePayModel.dart';
import 'package:mighty_delivery/main/network/NetworkUtils.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/screens/DashboardScreen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../main.dart';

class PaymentScreen extends StatefulWidget {
  static String tag = '/PaymentScreen';
  final num totalAmount;
  final int orderId;

  PaymentScreen({required this.totalAmount, required this.orderId});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> implements TransactionCallBack {
  late NavigationController controller;
  String? selectedPaymentType;
  late Razorpay _razorpay;

  final plugin = PaystackPlugin();
  CheckoutMethod method = CheckoutMethod.card;
  String? _cardNumber;
  String? _cvv;
  int? _expiryMonth;
  int? _expiryYear;

  bool isDisabled = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    plugin.initialize(publicKey: payStackPublicKey.validate());
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Save Payment
  Future<void> savePaymentApiCall({String? paymentType, String? txnId, String? paymentStatus = PAYMENT_PENDING, Map? transactionDetail}) async {
    Map req = {
      "id": "",
      "order_id": widget.orderId.toString(),
      "client_id": getIntAsync(USER_ID).toString(),
      "datetime": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
      "total_amount": widget.totalAmount.toString(),
      "payment_type": paymentType,
      "txn_id": txnId,
      "payment_status": paymentStatus,
      "transaction_detail": transactionDetail ?? {}
    };

    appStore.setLoading(true);

    savePayment(req).then((value) {
      appStore.setLoading(false);
      snackBar(context, title: value.message.toString());
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      print(error.toString());
    });
  }

  /// Razor Pay
  void razorPayPayment() async {
    var options = {
      'key': razorKey.validate(),
      'amount': (widget.totalAmount * 100).toInt(),
      'theme.color': '#5957b0',
      'name': 'Local Delivery',
      'description': 'On Demand Local Delivery System',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': getStringAsync(USER_CONTACT_NUMBER), 'email': getStringAsync(USER_EMAIL)},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
    Map<String, dynamic> req = {
      'order_id': response.orderId ?? widget.orderId.toString(),
      'txn_id': response.paymentId,
      'signature': response.signature,
    };
    savePaymentApiCall(paymentType: PAYMENT_TYPE_RAZORPAY, paymentStatus: 'paid', txnId: response.paymentId, transactionDetail: req);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!, toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }

  ///PayStack Payment
  void payStackPayment(BuildContext context) async {
    Charge charge = Charge()
      ..amount = (widget.totalAmount * 100).toInt() // In base currency
      ..email = getStringAsync(USER_EMAIL)
      ..card = PaymentCard(number: _cardNumber, cvc: _cvv, expiryMonth: _expiryMonth, expiryYear: _expiryYear);

    charge.reference = _getReference();

    try {
      CheckoutResponse response = await plugin.checkout(context, method: method, charge: charge, fullscreen: false /*, logo: MyLogo()*/);
      payStackUpdateStatus(response.reference, response.message);
      Map<String, dynamic> req = {
        "status": response.status.toString(),
        "card": {
          "number": response.card!.number,
          "cvc": response.card!.cvc,
          "expiry_month": response.card!.expiryMonth,
          "expiry_year": response.card!.expiryYear,
        },
        "message": response.message.toString(),
        "method": response.method.name.toString(),
        "reference": response.reference.toString(),
      };
      if (response.message == 'Success') {
        savePaymentApiCall(paymentType: PAYMENT_TYPE_PAYSTACK, paymentStatus: PAYMENT_PAID, transactionDetail: req);
      } else {
        snackBar(context, title: 'Payment Failed');
      }
    } catch (e) {
      payStackShowMessage("Check console for error");
      rethrow;
    }
  }

  payStackUpdateStatus(String? reference, String message) {
    payStackShowMessage(message, const Duration(seconds: 7));
  }

  void payStackShowMessage(String message, [Duration duration = const Duration(seconds: 4)]) {
    snackBar(context, title: message);
    log(message);
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// FlutterWave Payment
  void flutterWaveCheckout() {
    if (isDisabled) return;
    _showConfirmDialog();
  }

  final style = FlutterwaveStyle(
      buttonColor: Color(0xFF5957b0),
      buttonTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      dialogCancelTextStyle: TextStyle(color: Colors.grey, fontSize: 18),
      dialogContinueTextStyle: TextStyle(color: Color(0xFF5957b0), fontSize: 18));

  void _showConfirmDialog() {
    FlutterwaveViewUtils.showConfirmPaymentModal(
      context,
      currencyCode,
      widget.totalAmount.toString(),
      style.getMainTextStyle(),
      style.getDialogBackgroundColor(),
      style.getDialogCancelTextStyle(),
      style.getDialogContinueTextStyle(),
      _handlePayment,
    );
  }

  void _handlePayment() async {
    final Customer customer = Customer(name: getStringAsync(NAME), phoneNumber: getStringAsync(USER_CONTACT_NUMBER), email: getStringAsync(USER_EMAIL));

    final request = StandardRequest(
      txRef: DateTime.now().millisecond.toString(),
      amount: widget.totalAmount.toString(),
      customer: customer,
      paymentOptions: "card, payattitude",
      customization: Customization(title: "Test Payment"),
      isTestMode: true,
      publicKey: flutterWavePublicKey.validate(),
      currency: currencyCode,
      redirectUrl: "https://www.google.com",
    );

    try {
      Navigator.of(context).pop();
      _toggleButtonActive(false);
      controller.startTransaction(request);
      _toggleButtonActive(true);
    } catch (error) {
      _toggleButtonActive(true);
      _showErrorAndClose(error.toString());
    }
  }

  void _toggleButtonActive(final bool shouldEnable) {
    setState(() {
      isDisabled = !shouldEnable;
    });
  }

  void _showErrorAndClose(final String errorMessage) {
    FlutterwaveViewUtils.showToast(context, errorMessage);
  }

  @override
  onTransactionError() {
    _showErrorAndClose("transaction error");
    toast(errorMessage);
  }

  @override
  onCancelled() {
    toast("Transaction Cancelled");
  }

  @override
  onTransactionSuccess(String id, String txRef) {
    final ChargeResponse chargeResponse = ChargeResponse(status: "success", success: true, transactionId: id, txRef: txRef);
    Map<String, dynamic> req = {
      "txn_id": chargeResponse.transactionId.toString(),
      "status": chargeResponse.status.toString(),
      "reference": chargeResponse.txRef.toString(),
    };
    savePaymentApiCall(paymentStatus: PAYMENT_PAID, txnId: chargeResponse.transactionId, paymentType: PAYMENT_TYPE_FLUTTERWAVE, transactionDetail: req);
  }

  /// StripPayment
  void stripePay() async {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer ${stripPaymentKey.validate()}',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    };

    var request = http.Request('POST', Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(widget.totalAmount * 100).toInt()}',
      'currency': "INR",
    };

    log(request.bodyFields);
    request.headers.addAll(headers);

    log(request);

    appStore.setLoading(true);

    await request.send().then((value) {
      appStore.setLoading(false);
      http.Response.fromStream(value).then((response) async {
        if (response.statusCode == 200) {
          var res = StripePayModel.fromJson(await handleResponse(response));

          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: res.clientSecret.validate(),
              style: ThemeMode.light,
              applePay: true,
              googlePay: true,
              testEnv: true,
              merchantCountryCode: 'IN',
              merchantDisplayName: 'Mighty Delivery',
              customerId: '1',
              customerEphemeralKeySecret: res.clientSecret.validate(),
              setupIntentClientSecret: res.clientSecret.validate(),
            ),
          );
          await Stripe.instance.presentPaymentSheet(parameters: PresentPaymentSheetParameters(clientSecret: res.clientSecret!, confirmPayment: true)).then(
            (value) async {
              savePaymentApiCall(paymentType: PAYMENT_TYPE_STRIPE, paymentStatus: PAYMENT_PAID);
            },
          ).catchError((e) {
            log("presentPaymentSheet ${e.toString()}");
          });
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    controller = NavigationController(Client(), style, this);
    return Scaffold(
      appBar: AppBar(title: Text(language.payment)),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.paymentMethod, style: boldTextStyle()),
                  16.height,
                  ListView.builder(
                    primary: false,
                    shrinkWrap: true,
                    itemCount: paymentGatewayList.length,
                    itemBuilder: (context, index) {
                      PaymentGatewayData mData = paymentGatewayList[index];
                      return GestureDetector(
                        child: Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.cardColor,
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(color: appStore.isDarkMode ? Colors.transparent : borderColor),
                          ),
                          child: Row(
                            children: [
                              commonCachedNetworkImage('${mData.gatewayLogo}',width: 40,height: 40),
                              16.width,
                              Text('${mData.title}',style: primaryTextStyle()).expand(),
                              Icon(Icons.check_circle, color: colorPrimary).visible(mData.type == selectedPaymentType),
                            ],
                          ),
                        ),
                        onTap: () {
                          selectedPaymentType = mData.type;
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: commonButton(language.payNow, () {
                if (selectedPaymentType == PAYMENT_TYPE_STRIPE) {
                  stripePay();
                } else if (selectedPaymentType == PAYMENT_TYPE_RAZORPAY) {
                  razorPayPayment();
                } else if (selectedPaymentType == PAYMENT_TYPE_PAYSTACK) {
                  payStackPayment(context);
                } else if (selectedPaymentType == PAYMENT_TYPE_FLUTTERWAVE) {
                  flutterWaveCheckout();
                }
              }, width: context.width())
                  .paddingAll(16),
            ),
            Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
