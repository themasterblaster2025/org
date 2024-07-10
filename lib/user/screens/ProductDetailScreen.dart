import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/components/HtmlWidgtet.dart';
import 'package:mighty_delivery/main/models/ProductListModel.dart';

import '../../extensions/decorations.dart';
import '../../extensions/text_styles.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductData product;
  const ProductDetailScreen({required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: widget.product.title.validate(),
      body: ListView(
        padding: EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          commonCachedNetworkImage(widget.product.productImage.validate(),
              fit: BoxFit.cover,
              width: context.width(),
              height: context.width() * 0.7)
              .cornerRadiusWithClipRRect(defaultRadius),
          8.height,
          Text(
            printAmount(
              widget.product.price.validate(),
            ),
            style: boldTextStyle(color: colorPrimary),
          ),
          6.height,
          Divider(height: 10,color: dividerColor,),
          10.height,
          Text( language.description,
            style: boldTextStyle(size: 18),
          ),
          8.height,
          HtmlWidgetComponent(postContent: widget.product.description.validate(),),
        ],
      ),
    );
  }
}