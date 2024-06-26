import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/models/ProductListModel.dart';
import 'package:mighty_delivery/user/screens/ProductDetailScreen.dart';
import 'package:mighty_delivery/user/screens/ProductListScreen.dart';

import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Colors.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';

class ProductItemComponent extends StatefulWidget {
  final ProductData product;
  final bool isView;
  final bool isSearch;
  final Function(int)? onAdd;
  final Function(int)? onRemove;

  ProductItemComponent(
      {required this.product,
      this.isView = false,
      this.isSearch = false,
      this.onAdd,
      this.onRemove});

  @override
  ProductItemComponentState createState() => ProductItemComponentState();
}

class ProductItemComponentState extends State<ProductItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: radius(16),
        hoverColor: Colors.white,
        onTap: () async {
          if (!widget.isView) {
            /* await showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder: (context) {
                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.all(16),
                      shrinkWrap: true,
                      children: [
                        Stack(
                          children: [
                            commonCachedNetworkImage(widget.product.productImage.validate(),
                                    fit: BoxFit.cover,
                                    width: context.width(),
                                    height: context.width() * 0.7)
                                .cornerRadiusWithClipRRect(defaultRadius),
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius: radius(defaultRadius),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                                backgroundColor: Colors.grey.withOpacity(0.1),
                              ),
                              width: context.width(),
                              height: context.width() * 0.7,
                            ),
                          ],
                        ),
                        16.height,
                        Text(
                          widget.product.title.validate(),
                          style: boldTextStyle(size: 18),
                        ),
                        8.height,
                        Text(
                          printAmount(
                            widget.product.price.validate(),
                          ),
                          style: boldTextStyle(color: colorPrimary),
                        ),
                        8.height,
                        HtmlWidget(widget.product.description.validate(),),
                       */ /* HtmlWidget(
                          '<html><iframe style="width:100%" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen"></iframe></html>',
                          factoryBuilder: () => MyWidgetFactory(),
                        ),*/ /*
                      ],
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        color: Colors.white,
                        iconSize: 30,
                        onPressed: () {
                          finish(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            );*/
            ProductDetailScreen(
              product: widget.product,
            ).launch(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(defaultRadius),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: commonCachedNetworkImage(widget.product.productImage.validate(),
                          height: widget.isView ? 70 : 90,
                          width: widget.isView ? 70 : 90,
                          fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(defaultRadius),
                ),
                12.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    2.height,
                    Text(widget.product.title.validate(),
                        style: boldTextStyle(size: 14), maxLines: 2),
                    8.height,
                    Row(
                      children: [
                        Text(
                          printAmount(
                            widget.product.price.validate(),
                          ),
                          style: boldTextStyle(size: 14, color: colorPrimary),
                        ),
                        if (widget.isView) 8.width,
                        if (widget.isView)
                          Text(
                            'x ${widget.product.count.validate()}'.toString(),
                            style: secondaryTextStyle(),
                          ),
                      ],
                    ),
                    // ratingWidget().visible(widget.product.totalRating != 0 && !widget.isView)
                  ],
                ).expand(),
              ],
            ).expand(),
            8.width,
            widget.isView
                ? Text(
                    printAmount(
                      widget.product.price.validate() * widget.product.count.validate(),
                    ),
                    style: boldTextStyle(size: 14, color: colorPrimary),
                  )
                : widget.isSearch
                    ? InkWell(
                        onTap: () async {
                          await getStoreDetail(
                            widget.product.storeDetailId.validate(),
                          ).then((value) {
                            ProductListScreen(store: value, product: widget.product)
                                .launch(context);
                          }).catchError((error) {
                            print(error);
                          });
                        },
                        child: Text(
                          "Go to Store", // todo
                          style: boldTextStyle(size: 14, color: colorPrimary),
                        ),
                      )
                    : widget.product.count == 0
                        ? GestureDetector(
                            onTap: () {
                              widget.product.count++;
                              setState(() {});
                              widget.onAdd?.call(widget.product.count);
                            },
                            child: Container(
                              decoration: boxDecorationRoundedWithShadow(30,
                                  backgroundColor: colorPrimary),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 16),
                                  4.width,
                                  Text(
                                    language.add,
                                    style: boldTextStyle(size: 14, color: Colors.white),
                                  ),
                                ],
                              ).paddingSymmetric(horizontal: 16, vertical: 8),
                            ),
                          )
                        : Container(
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(30),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove, color: colorPrimary, size: 12)
                                    .paddingAll(8)
                                    .onTap(() {
                                  if (widget.product.count != 0) {
                                    widget.product.count = widget.product.count - 1;
                                    setState(() {});
                                    widget.onRemove?.call(widget.product.count);
                                  }
                                },
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent),
                                4.width,
                                Text(
                                  widget.product.count.toInt().toString(),
                                  style: boldTextStyle(color: colorPrimary),
                                ),
                                4.width,
                                Icon(Icons.add, color: colorPrimary, size: 16)
                                    .paddingAll(8)
                                    .onTap(() {
                                  widget.product.count = widget.product.count + 1;
                                  setState(() {});
                                  widget.onAdd?.call(widget.product.count);
                                },
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent),
                              ],
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with WebViewFactory {}
