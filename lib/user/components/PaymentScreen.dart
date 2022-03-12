import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutterwave_standard/core/TransactionCallBack.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/core/navigation_controller.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/requests/standard_request.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:flutterwave_standard/models/subaccount.dart';
import 'package:flutterwave_standard/view/flutterwave_style.dart';
import 'package:flutterwave_standard/view/view_utils.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/components/BodyCornerWidget.dart';
import 'package:mighty_delivery/main/models/PaymentGatewayListModel.dart';
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

class PaymentScreenState extends State<PaymentScreen> implements TransactionCallBack{
  late NavigationController controller;
  List<PaymentGatewayData> paymentGatewayList = [];
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
    getPaymentGatewayListApiCall();
    plugin.initialize(publicKey: payStackPublicKey);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  getPaymentGatewayListApiCall() async {
    appStore.setLoading(true);
    await getPaymentGatewayList().then((value) {
      appStore.setLoading(false);
      //paymentGatewayList.add(PaymentGatewayData(title: 'Cash', type: 'cash', gatewayLogo: 'assets/icons/ic_cash.png'));
      paymentGatewayList.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
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
      'key': razorKey,
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
      appBarText: "My Standard Blue",
      buttonColor: Color(0xffd0ebff),
      appBarIcon: Icon(Icons.message, color: Color(0xffd0ebff)),
      buttonTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      appBarColor: Color(0xffd0ebff),
      dialogCancelTextStyle: TextStyle(color: Colors.redAccent, fontSize: 18),
      dialogContinueTextStyle: TextStyle(color: Colors.blue, fontSize: 18));

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
      publicKey: flutterWavePublicKey,
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
    Map<String,dynamic> req = {
      "txn_id" : chargeResponse.transactionId.toString(),
      "status" : chargeResponse.status.toString(),
      "reference" : chargeResponse.txRef.toString(),
    };
    savePaymentApiCall(paymentStatus : PAYMENT_PAID,txnId: chargeResponse.transactionId,paymentType: PAYMENT_TYPE_FLUTTERWAVE,transactionDetail: req);
  }


 /* _handlePaymentInitialization() async {
    final style = FlutterwaveStyle(
      appBarText: "Flutter Wave",
      buttonColor: colorPrimary,
      buttonTextStyle: primaryTextStyle(),
      appBarColor: colorPrimary,
      dialogCancelTextStyle: boldTextStyle(),
      dialogContinueTextStyle: boldTextStyle(color: colorPrimary),
      mainBackgroundColor: context.scaffoldBackgroundColor,
      mainTextStyle: TextStyle(color: Colors.indigo, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.white,
      appBarIcon: Icon(Icons.arrow_back, color: Colors.white),
      buttonText: "Pay $currencySymbol ${widget.totalAmount}",
      appBarTitleTextStyle: boldTextStyle(color: Colors.white,size: 20),
    );

    final Customer customer = Customer(name: getStringAsync(NAME), phoneNumber: getStringAsync(USER_CONTACT_NUMBER), email: getStringAsync(USER_EMAIL));

    final subAccounts = [
      SubAccount(id: "RS_1A3278129B808CB588B53A14608169AD", transactionChargeType: "flat", transactionPercentage: 25),
      SubAccount(id: "RS_C7C265B8E4B16C2D472475D7F9F4426A", transactionChargeType: "flat", transactionPercentage: 50)
    ];

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        style: style,
        publicKey: flutterWavePublicKey,
        currency: "INR",
        txRef: DateTime.now().millisecond.toString(),
        amount: widget.totalAmount.toString(),
        customer: customer,
        subAccounts: subAccounts,
        paymentOptions: "card, payattitude",
        customization: Customization(title: "Test Payment"),
        redirectUrl: "https://www.google.com",
        isTestMode: true);
    final ChargeResponse response = await flutterwave.charge();
    if (response != null) {
      print(response.status);
    } else {
      //this.showLoading("No Response!");
    }
  }*/

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    controller = NavigationController(Client(), style, this);
    return Scaffold(
      appBar: appBarWidget('Payment', color: colorPrimary, elevation: 0, textColor: white),
      body: BodyCornerWidget(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Methods', style: boldTextStyle()),
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
                            borderRadius: BorderRadius.circular(defaultRadius),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              commonCachedNetworkImage('${mData.gatewayLogo}'),
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
              child: commonButton('Pay Now', () {
                if (selectedPaymentType == PAYMENT_TYPE_STRIPE) {
                  toast('stripe');
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
