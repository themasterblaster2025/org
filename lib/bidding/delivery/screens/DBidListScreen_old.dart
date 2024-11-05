// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:mighty_delivery/bidding/extensions/extension_util/animation_extensions.dart';
// import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
// import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
// import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
// import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
// import 'package:mighty_delivery/extensions/shared_pref.dart';
// import 'package:mighty_delivery/main.dart';
// import 'package:mighty_delivery/main/components/CommonScaffoldComponent.dart';
// import 'package:mighty_delivery/main/models/OrderListModel.dart';

// import '../../../delivery/fragment/DHomeFragment.dart';
// import '../../../extensions/animatedList/animated_configurations.dart';
// import '../../../extensions/animatedList/animated_list_view.dart';
// import '../../../extensions/app_text_field.dart';
// import '../../../extensions/common.dart';
// import '../../../extensions/confirmation_dialog.dart';
// import '../../../extensions/decorations.dart';
// import '../../../extensions/system_utils.dart';
// import '../../../extensions/text_styles.dart';
// import '../../../main/utils/Common.dart';
// import '../../../main/utils/Constants.dart';
// import '../../../main/utils/dynamic_theme.dart';
// import '../../../user/screens/OrderDetailScreen.dart';
// import '../../main/components/DashedLineComponent.dart';
// import '../../main/components/TopBarAddressComponent.dart';
// import '../../utils/Constants.dart';
// import '../models/BidResponseModel.dart';
// import '../network/RestApis.dart';

// class DBidlistscreen extends StatefulWidget {
//   final OrderData? orderData;
//   const DBidlistscreen({super.key, required this.orderData});

//   @override
//   State<DBidlistscreen> createState() => _DBidlistscreenState();
// }

// class _DBidlistscreenState extends State<DBidlistscreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late double biddedAmount;
//   String? reason;
//   TextEditingController reasonController = TextEditingController();
//   late StreamSubscription _streamSubscription;

//   List<Data> OrderBidData = [];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     startShake();
//     getOrderBidListApiCall(widget.orderData!.id!);
//     biddedAmount = widget.orderData!.totalAmount!.toDouble();
//     _listenToStream();
//   }

//   void startShake() {
//     _animationController.forward(from: 0);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     reasonController.dispose();
//     _streamSubscription.cancel();
//     super.dispose();
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   getOrderBidListApiCall(int orderId) async {
//     appStore.setLoading(true);
//     await getBiddingDetails(orderId).then((value) {
//       log("LEN::: ${value.data!.length}");
//       OrderBidData = value.data ?? [];

//       setState(() {});
//     }).catchError((e, s) {
//       log("CHECK_ERROR::${e}:::STAACK::::$s");
//     }).whenComplete(() => appStore.setLoading(false));
//   }

//   createApplyForBidApiCall() async {
//     appStore.setLoading(true);

//     Map req = {
//       "order_id": widget.orderData!.id.toString(),
//       "bid_amount": biddedAmount.toDouble(),
//       "notes": reasonController.text.trim(),
//     };

//     try {
//       await createBid(req).then((value) {
//         appStore.setLoading(false);
//         toast(value.message);
//         DHomeFragment().launch(context, isNewTask: true);
//       }).whenComplete(
//         () {
//           appStore.setLoading(false);
//         },
//       );
//     } catch (error) {
//       // Handle the error here (e.g., show a toast or log it)
//       appStore.setLoading(false);
//       log('Error during apply bid API call: $error');
//       toast('Failed to apply bid. Please try again.');
//     }
//   }

//   void _showBidBottomSheet(BuildContext context) {
//     biddedAmount = widget.orderData!.totalAmount!.toDouble();
//     double lowestBidAmount = biddedAmount - 10;
//     double highestBidAmount = biddedAmount + 10;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//             return Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: appStore.isDarkMode
//                     ? ColorUtils.scaffoldSecondaryDark
//                     : ColorUtils.scaffoldColorLight,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Place your Bid',
//                               style: boldTextStyle(size: 20)),
//                           IconButton(
//                             icon: Icon(Icons.close,
//                                 color: ColorUtils.colorPrimary, size: 30),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),
//                       8.height,
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             decoration: boxDecorationWithRoundedCorners(
//                               boxShape: BoxShape.circle,
//                               border: Border.all(color: Colors.red),
//                             ),
//                             child: IconButton(
//                               icon: Icon(Icons.remove,
//                                   color: Colors.red, size: 30),
//                               onPressed: () {
//                                 setModalState(() {
//                                   if (biddedAmount > lowestBidAmount) {
//                                     biddedAmount -= 10;
//                                   }
//                                 });
//                               },
//                             ),
//                           ),
//                           24.width,
//                           Text('${appStore.currencyCode}',
//                               style: boldTextStyle(size: 24)),
//                           SizedBox(width: 4),
//                           Text(biddedAmount.toStringAsFixed(2),
//                               style: boldTextStyle(size: 40)),
//                           24.width,
//                           Container(
//                             decoration: boxDecorationWithRoundedCorners(
//                               boxShape: BoxShape.circle,
//                               border: Border.all(color: Colors.green),
//                             ),
//                             child: IconButton(
//                               icon: Icon(Icons.add,
//                                   color: Colors.green, size: 30),
//                               onPressed: () {
//                                 setModalState(() {
//                                   if (biddedAmount < highestBidAmount) {
//                                     biddedAmount += 10;
//                                   }
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ).paddingSymmetric(horizontal: 16, vertical: 12),
//                       10.height,
//                       Text('Say anything... (Optional)',
//                           style: boldTextStyle(size: 16)),
//                       SizedBox(height: 8),
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: ColorUtils.colorPrimary.withOpacity(0.3),
//                         ),
//                         child: AppTextField(
//                           controller: reasonController,
//                           onChanged: (value) {
//                             reason = value;

//                             setState(() {});
//                           },
//                           textFieldType: TextFieldType.NAME,
//                           decoration: InputDecoration(
//                             hintText: 'Write Here',
//                             hintStyle: secondaryTextStyle(
//                                 size: 16, color: Colors.grey),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () async {
//                           hideKeyboard(context);
//                           context.pop();
//                           await showConfirmDialogCustom(
//                             context,
//                             primaryColor: ColorUtils.colorPrimary,
//                             title: "Confirm bid?",
//                             positiveText: language.yes,
//                             negativeText: language.no,
//                             onAccept: (c) {
//                               createApplyForBidApiCall();
//                             },
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: ColorUtils.colorPrimary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text('Confirm',
//                             style:
//                                 boldTextStyle(size: 20, color: Colors.white)),
//                       ).withSize(width: context.width(), height: 60),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   _listenToStream() {
//     _streamSubscription = FirebaseFirestore.instance
//         .collection(ORDERS_BID_COLLECTION)
//         .doc("order_" + widget.orderData!.id!.toString())
//         .snapshots()
//         .listen((snapshot) {
//       log("STREAM IS LISTENING2....");

//       log("SNAPSHOT HAS DATA2::: ${snapshot.exists}");

//       if (snapshot.exists) {
//         getOrderBidListApiCall(widget.orderData!.id!);
//       }
//     }, onError: (error) {
//       log("ERROR::: $error");
//     });
//   }

//   calculateTimeDifference({required String? time}) {
//     DateTime now = DateTime.now();
//     DateTime bidTime = DateTime.parse(time ?? now.toString());
//     Duration difference = now.difference(bidTime);
//     // return time in days, hours, minutes, seconds
//     if (difference.inDays > 0) {
//       return difference.inDays;
//     } else if (difference.inHours > 0) {
//       return difference.inHours;
//     } else if (difference.inMinutes > 0) {
//       return difference.inMinutes;
//     } else {
//       return difference.inSeconds;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CommonScaffoldComponent(
//         appBarTitle: "Bids",
//         action: [
//           Text("${language.orderId} : #${widget.orderData!.id}",
//                   style: boldTextStyle(size: 16, color: Colors.white))
//               .withWidth(120),
//         ],
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Column(
//                 children: [
//                   TopBarAddressComponent(
//                       orderData: widget.orderData,
//                       onTap: () {
//                         OrderDetailScreen(
//                           orderId: widget.orderData!.id!,
//                         ).launch(context);
//                       }),
//                   Container(
//                     width: context.width(),
//                     margin: EdgeInsets.all(16),
//                     decoration: boxDecorationWithRoundedCorners(
//                         borderRadius: BorderRadius.circular(defaultRadius),
//                         border: Border.all(color: Colors.transparent),
//                         backgroundColor:
//                             ColorUtils.colorPrimary.withOpacity(0.1)),
//                     padding: EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Bid Estimate:',
//                               style: boldTextStyle(
//                                 color: ColorUtils.colorPrimary,
//                               ),
//                             ),
//                             Text(
//                               'Your Placed Bid:',
//                               style: boldTextStyle(
//                                 color: ColorUtils.colorPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "${printAmount((widget.orderData!.totalAmount! - 10))} - ${printAmount((widget.orderData!.totalAmount! + 10))}",
//                               style: boldTextStyle(),
//                             ),
//                             Text(
//                               '${printAmount(0)}',
//                               style: boldTextStyle(),
//                             ),
//                           ],
//                         ),
//                         8.height,
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Container(
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     FontAwesome.clock_o,
//                                     color: ColorUtils.colorPrimary,
//                                   ),
//                                   4.width,
//                                   RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: "Ends In: ",
//                                           style: primaryTextStyle(size: 14),
//                                         ),
//                                         TextSpan(
//                                           text: "05:00 ",
//                                           style: boldTextStyle(
//                                               color: Colors.red, size: 14),
//                                         ),
//                                         TextSpan(
//                                           text: "Min",
//                                           style: primaryTextStyle(size: 14),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                         24.height,
//                         SizedBox(
//                           width: context.width(),
//                           height: 1,
//                           child: DashedLineComponent(
//                             axis: Axis.horizontal,
//                             dashWidth: 8.0,
//                             dashHeight: 1.5,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         16.height,
//                         buildContent(),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//             Observer(builder: (context) {
//               return appStore.isLoading ? loaderWidget() : SizedBox();
//             }),
//           ],
//         ),
//         bottomNavigationBar: Container(
//           padding: EdgeInsets.all(16),
//           child: ElevatedButton(
//             onPressed:
//                 appStore.isLoading ? () {} : () => _showBidBottomSheet(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: appStore.isDarkMode
//                   ? ColorUtils.scaffoldSecondaryDark
//                   : ColorUtils.scaffoldColorLight,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(defaultRadius),
//                   side: BorderSide(
//                       color: appStore.isDarkMode
//                           ? Colors.white
//                           : ColorUtils.colorPrimary,
//                       width: 1)),
//             ),
//             child: Text(
//               "Place Bid",
//               style: boldTextStyle(
//                   color: appStore.isDarkMode
//                       ? Colors.white
//                       : ColorUtils.colorPrimary),
//             ),
//           ).withHeight(60).visible(!OrderBidData.any(
//                 (data) {
//                   return data.deliveryManId == getIntAsync(USER_ID);
//                 },
//               )),
//         ).withShakeAnimation(_animationController));
//   }

//   Widget buildContent() {
//     if (appStore.isLoading) {
//       return SizedBox.shrink();
//     } else if (OrderBidData.isEmpty) {
//       return Center(
//           child: Text('No bids yet! Be the first to bid.',
//               style: boldTextStyle()));
//     } else {
//       return buildBidListView();
//     }
//   }

//   Widget buildBidListView() {
//     return AnimatedListView(
//       itemCount: OrderBidData.length,
//       shrinkWrap: true,
//       physics: BouncingScrollPhysics(),
//       listAnimationType: ListAnimationType.Slide,
//       padding: const EdgeInsets.all(0),
//       itemBuilder: (context, index) {
//         var orderDetail = OrderBidData[index];
//         return ListTile(
//           contentPadding: const EdgeInsets.all(0),
//           leading: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               commonCachedNetworkImage(
//                 orderDetail.deliveryManImage,
//                 height: 50,
//                 width: 50,
//               )
//             ],
//           ),
//           title: Text(
//             orderDetail.deliveryManName!.capitalizeFirstLetter(),
//             style: boldTextStyle(),
//           ),
//           subtitle: Text(
//             "${calculateTimeDifference(time: orderDetail.createdAt)} secs ago",
//             style: boldTextStyle(size: 14, color: Colors.grey),
//           ),
//           trailing: Text(
//             "${printAmount(orderDetail.bidAmount!)}",
//             style: boldTextStyle(size: 24),
//           ),
//         );
//       },
//     );
//   }
// }
