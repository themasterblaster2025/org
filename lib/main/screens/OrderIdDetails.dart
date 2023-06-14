import 'package:flutter/material.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/OrderDetailModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/user/screens/OrderHistoryScreen.dart';
import 'package:nb_utils/nb_utils.dart';

class OrderIdDetails extends StatelessWidget {
  var codeController = TextEditingController();
  OrderDetailModel orderDetailsModel = OrderDetailModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(hintText: 'Enter code'),
            ),
            ElevatedButton(
                onPressed: () {
                  appStore.setLoading(true);
                  getOrderdata(context);
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }

  void getOrderdata(BuildContext context) async {
    try {
      orderDetailsModel = await getOrderDetails(codeController.text.toInt());

      OrderHistoryScreen(
        orderHistory: [
          OrderHistory(
              id: orderDetailsModel.data?.id!.toInt(),
              orderId: orderDetailsModel.data?.id!.toInt(),
              historyType: orderDetailsModel.data?.parcelType!,
              historyMessage: orderDetailsModel.data?.reason ?? ' ',
              createdAt: orderDetailsModel.data?.date,
              historyData: HistoryData(
                  clientId: orderDetailsModel.data?.clientId!.toInt(),
                  clientName: orderDetailsModel.data?.clientName.toString(),
                  deliveryManName: orderDetailsModel.data?.deliveryManName))
        ],
      ).launch(context);
    } catch (e) {
      toast(e.toString());
    }
  }
}
