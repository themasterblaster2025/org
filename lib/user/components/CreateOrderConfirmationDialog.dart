import 'package:flutter/material.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class CreateOrderConfirmationDialog extends StatefulWidget {
  static String tag = '/CreateOrderConfirmationDialog';
  final Function() onDraft;
  final Function() onCreate;

  CreateOrderConfirmationDialog({required this.onDraft,required this.onCreate});

  @override
  CreateOrderConfirmationDialogState createState() => CreateOrderConfirmationDialogState();
}

class CreateOrderConfirmationDialogState extends State<CreateOrderConfirmationDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Confirmation', style: boldTextStyle(size: 18)),
            CloseButton(),
          ],
        ),
        16.height,
        Text('Are you sure you want to Create Order?', style: primaryTextStyle(size: 16)),
        30.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            commonButton('Save Draft', widget.onDraft, color: Colors.grey),
            16.width,
            commonButton('Create', widget.onCreate),
          ],
        ),
      ],
    );
  }
}
