import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/loader_widget.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/HtmlWidgtet.dart';
import 'package:mighty_delivery/main/models/PageResponse.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';

import '../../main/network/RestApis.dart';

class InsuranceDetailsScreen extends StatefulWidget {
  InsuranceDetailsScreen({super.key});

  @override
  State<InsuranceDetailsScreen> createState() => _InsuranceDetailsScreenState();
}

class _InsuranceDetailsScreenState extends State<InsuranceDetailsScreen> {
  PageResponse? data;
  String title = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    getInsuranceDetails();
  }

  getInsuranceDetails() async {
    appStore.setLoading(true);
    await getPageDetailsById(id: "11").then((value) {
      title = value.data!.title!;
      description = value.data!.description!;
      print("-------------------------$description");
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBarWidget((title.isNotEmpty) ? title.toString() : ""),
        body: Stack(
          children: [
            description != null && description.isNotEmpty
                ? SingleChildScrollView(child: HtmlWidget(postContent: description))
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            if (appStore.isLoading)
              Center(
                child: loaderWidget(),
              )
          ],
        ));
  }
}
