import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/models/models.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/DataProviders.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class CancelOrderDialog extends StatefulWidget {
  static String tag = '/CancelOrderDialog';

  final int orderId;
  final Function? onUpdate;

  CancelOrderDialog({required this.orderId,this.onUpdate});

  @override
  CancelOrderDialogState createState() => CancelOrderDialogState();
}

class CancelOrderDialogState extends State<CancelOrderDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController reasonController = TextEditingController();
  List<AppModel> reasonList = getReasonList();
  String? reason;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    reasonList.add(AppModel(name: 'Other'));
  }

  updateOrderApiCall() async {
    appStore.setLoading(true);
    await updateOrder(
      orderId: widget.orderId,
      reason: reason! != 'Other' ? reason : reasonController.text,
      orderStatus: ORDER_CANCELLED,
    ).then((value) {
      appStore.setLoading(false);
      finish(context);
      widget.onUpdate!.call();
      toast('Order Cancel Successfully');
    }).catchError((error) {
      appStore.setLoading(false);

      log(error);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cancel Order', style: boldTextStyle(size: 18)),
                  CloseButton(),
                ],
              ),
              16.height,
              Text('Reason', style: boldTextStyle()),
              8.height,
              DropdownButtonFormField<String>(
                value: reason,
                isExpanded: true,
                decoration: commonInputDecoration(),
                items: reasonList.map((e) {
                  return DropdownMenuItem(
                    value: e.name,
                    child: Text(e.name!),
                  );
                }).toList(),
                onChanged: (String? val) {
                  reason = val;
                  setState(() {});
                },
                validator: (value) {
                  if(value==null) return errorThisFieldRequired;
                },
              ),
              16.height,
              AppTextField(
                controller: reasonController,
                textFieldType: TextFieldType.OTHER,
                decoration: commonInputDecoration(hintText: 'Write reason here...'),
                maxLines: 3,
                minLines: 3,
                validator: (value) {
                  if (value!.isEmpty) return errorThisFieldRequired;
                },
              ).visible(reason == 'Other'),
              16.height,
              Align(
                alignment: Alignment.centerRight,
                child: commonButton('Submit', () {
                  if (formKey.currentState!.validate()) {
                    updateOrderApiCall();
                  }
                }),
              )
            ],
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
