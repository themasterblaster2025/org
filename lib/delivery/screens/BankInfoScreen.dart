import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../main/models/UserBankAccountModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';

class BankInfoScreen extends StatefulWidget {
  @override
  BankInfoScreenState createState() => BankInfoScreenState();
}

class BankInfoScreenState extends State<BankInfoScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();

  UserBankAccount? bankDetail;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    await getUserDetail(getIntAsync(USER_ID)).then((value) {
      // if (value.data!.user_bank_account != null) {
      //   bankDetail = value.data!.user_bank_account!;
      //   bankNameController.text = bankDetail!.bank_name.validate();
      //   bankCodeController.text = bankDetail!.bank_code.validate();
      //   accountHolderNameController.text = bankDetail!.account_holder_name.validate();
      //   accountNumberController.text = bankDetail!.account_number.validate();
      //   appStore.setLoading(false);
      //   setState(() {});
      // }
      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  Future<void> updateBankInfo() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      updateBankDetail(
        accountName: accountHolderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        bankCode: bankCodeController.text.trim(),
        bankName: bankNameController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);

        Navigator.pop(context);
        toast("bank Info Update Successfully");
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Info", style: boldTextStyle(color: Colors.white)),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Bank Name", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: bankNameController,
                    textFieldType: TextFieldType.NAME,
                    decoration: commonInputDecoration(),
                  ),
                  SizedBox(height: 16),
                  Text("Bank Code", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: bankCodeController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: "This field is required",
                    decoration: commonInputDecoration(),
                  ),
                  SizedBox(height: 16),
                  Text("Account Holder Name", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: accountHolderNameController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: "This field is required",
                    decoration: commonInputDecoration(),
                  ),
                  SizedBox(height: 16),
                  Text("Account Number", style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: accountNumberController,
                    textFieldType: TextFieldType.PHONE,
                    errorThisFieldRequired: "This field is required",
                    decoration: commonInputDecoration(),
                  ),
                ],
              ),
            ),
            Observer(builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            })
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: commonButton(
          bankDetail != null ? "Update Bank Detail" : "Add Bank Detail",
           () {
            updateBankInfo();
          },
        ),
      ),
    );
  }
}
