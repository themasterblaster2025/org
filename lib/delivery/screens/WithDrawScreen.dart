import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/models/WithDrawListModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/Widgets.dart';

class WithDrawScreen extends StatefulWidget {
  final Function() onTap;

  WithDrawScreen({required this.onTap});

  @override
  WithDrawScreenState createState() => WithDrawScreenState();
}

class WithDrawScreenState extends State<WithDrawScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController scrollController = ScrollController();
  TextEditingController addMoneyController = TextEditingController();

  int currentPage = 1;
  int totalPage = 1;

  List<WithDrawModel> withDrawData = [];

  int totalAmount = 0;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});

          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  void init() async {
    await getWithDrawList(page: currentPage).then((value) {
      appStore.setLoading(false);
      print("valuee" + value.toJson().toString());
      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      totalAmount = value.wallet_balance!.totalAmount!.toInt();
      if (currentPage == 1) {
        withDrawData.clear();
      }
      withDrawData.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> withDrawRequest({int? userId, int? amount}) async {
    appStore.setLoading(true);
    Map req = {
      "user_id": appStore.uid,
      "currency": appStore.currencyCode.toLowerCase(),
      "amount": amount,
      "status": REQUESTED,
    };
    await saveWithDrawRequest(req).then((value) {
      toast(value.message);
      Navigator.pop(context);
      widget.onTap.call();
      appStore.setLoading(false);
      init();
    }).catchError((error) {
      Navigator.pop(context);
      toast(error.toString());
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WithDraw", style: boldTextStyle(color: Colors.white)),
      ),
      body: Observer(builder: (context) {
        return Form(
          key: formKey,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(defaultRadius)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Available Balance", style: secondaryTextStyle(color: Colors.white)),
                            SizedBox(height: 8),
                            Text('${printAmount(totalAmount)}', style: boldTextStyle(size: 22, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Withdraw History", style: boldTextStyle(size: 18)),
                    SizedBox(height: 16),
                    ListView.builder(
                      itemCount: withDrawData.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        WithDrawModel data = withDrawData[index];

                        return Container(
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.4)), borderRadius: BorderRadius.circular(defaultRadius)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Withdraw History", style: boldTextStyle(size: 14)),
                                    SizedBox(height: 4),
                                    Text(printDate(data.createdAt!), style: secondaryTextStyle(size: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(data.status == 1 ? "approved" : "requested", style: secondaryTextStyle(color: data.status == 1 ? Colors.green : Colors.red)),
                                  SizedBox(height: 4),
                                  Text('${printAmount(data.amount!.toDouble())}', style: secondaryTextStyle()),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              ),
              !appStore.isLoading && withDrawData.isEmpty ? emptyWidget() : SizedBox(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Visibility(
        visible: totalAmount > 0,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: commonButton(
            "WithDraw",
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Add Money', style: boldTextStyle(size: 18)),
                        Divider(),
                        16.height,
                        Text("Amount", style: primaryTextStyle()),
                        8.height,
                        AppTextField(
                          controller: addMoneyController,
                          textFieldType: TextFieldType.PHONE,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (a) {
                            log(a);
                            if (a.toInt() >= totalAmount) {
                              addMoneyController.text = totalAmount.toString();
                            }
                          },
                          decoration: commonInputDecoration(),
                        ),
                        16.height,
                        commonButton(
                          "Withdraw",
                          () async {
                            if (addMoneyController.text.isNotEmpty) {
                              await withDrawRequest(amount: int.parse(addMoneyController.text));
                            } else {
                              toast("Add Amount");
                            }
                          },
                          width: context.width(),
                        ),
                        16.height,
                      ],
                    ).paddingAll(16),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
