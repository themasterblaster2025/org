import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mighty_delivery/extensions/common.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/num_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main/models/ProductListModel.dart';
import 'package:mighty_delivery/main/network/RestApis.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:mighty_delivery/user/screens/StoreDetailScreen.dart';
import '../../extensions/app_button.dart';
import '../../extensions/decorations.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/models/StoreListModel.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../components/FilterCategoryComponent.dart';
import '../components/ProductItemComponent.dart';
import 'CreateOrderScreen.dart';

class ProductListScreen extends StatefulWidget {
  final StoreData store;
  final ProductData? product;

  ProductListScreen({required this.store, this.product});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<ProductData> productList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;
  int totalCount = 0;
  num productAmount = 0;

  List<ProductData> orderItems = [];
  List<int> selectedCategory = [];
  List<int> selectedSubCategory = [];

  bool showBottom = false;

  int totalItem = 0;

  @override
  void initState() {
    super.initState();
    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent &&
          !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          productListApi();
        }
      }
    });
  }

  Future<void> init() async {
    if (widget.product != null) {
      orderItems.add(widget.product!);
      orderItems.first.count = 1;
      totalCount = 1;
      countProductAmount();
      setState(() {});
    }
    await productListApi();
  }

  Future<void> productListApi() async {
    appStore.setLoading(true);
    await getProductList(page: page, storeDetailId: widget.store.id).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      totalItem = value.pagination!.totalItems.validate();
      isLastPage = false;
      if (page == 1) {
        productList.clear();
      }
      productList.addAll(value.data.validate().where((element) =>
          selectedCategory.contains(element.categoryId) ||
          selectedSubCategory.contains(element.subcategoryId) ||
          (selectedCategory.isEmpty && selectedSubCategory.isEmpty)));
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: commonAppBarWidget(widget.store.storeName.validate(),actions: [
                Stack(
                  children: [
                    Align(
                        alignment: AlignmentDirectional.center,
                        child: Icon(Ionicons.md_options_outline, color: Colors.white)),
                    Positioned(
                      right: 8,
                      top: 16,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      ),
                    ).visible(selectedCategory.isNotEmpty || selectedSubCategory.isNotEmpty),
                  ],
                ).withWidth(40).onTap(() {
                  _key.currentState!.openEndDrawer();
                },
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent),
              ], ),
      // appBar : AppBar(
      //   titleTextStyle: primaryTextStyle(color: Colors.white, size: 20),
      //   iconTheme: IconThemeData(color: Colors.white),
      //   title: Text(widget.store.storeName.validate()),
      //   actions: [
      //     Stack(
      //       children: [
      //         Align(
      //             alignment: AlignmentDirectional.center,
      //             child: Icon(Ionicons.md_options_outline, color: Colors.white)),
      //         Positioned(
      //           right: 8,
      //           top: 16,
      //           child: Container(
      //             height: 10,
      //             width: 10,
      //             decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      //           ),
      //         ).visible(selectedCategory.isNotEmpty || selectedSubCategory.isNotEmpty),
      //       ],
      //     ).withWidth(40).onTap(() {
      //       _key.currentState!.openEndDrawer();
      //     },
      //         splashColor: Colors.transparent,
      //         hoverColor: Colors.transparent,
      //         highlightColor: Colors.transparent),
      //   ],
      // ),
      endDrawerEnableOpenDragGesture: true,
          endDrawer: FilterCategoryComponent(
        storeId: widget.store.id,
        selectedCategory: selectedCategory,
        selectedSubCategory: selectedSubCategory,
        onUpdate: (categoryList, subCategoryList) {
          page = 1;
          selectedCategory = categoryList;
          selectedSubCategory = subCategoryList;
          orderItems.clear();
          productListApi();
        },
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            productList.isNotEmpty
                ? SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: context.width(),
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: colorPrimary.withOpacity(0.08),
                              borderRadius: radius(defaultRadius)),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              commonCachedNetworkImage(
                                      widget.store.storeImage.validate(),
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover)
                                  .cornerRadiusWithClipRRect(defaultRadius),
                              10.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.store.storeName.validate(),
                                      style: boldTextStyle(size: 16)),
                                  4.height,
                                  Text('$totalItem products', // todo
                                  // Text('$totalItem ${language.products}',
                                      style: secondaryTextStyle()),
                                ],
                              ).expand()
                            ],
                          ),
                        ).onTap((){
                          StoreDetailScreen(store: widget.store).launch(context);
                        }),
                        16.height,
                        ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            ProductData item = productList[index];
                            orderItems.forEach((element) {
                              if (item.id == element.id) {
                                item.count = element.count;
                              }
                            });
                            return ProductItemComponent(
                                product: item,
                                onAdd: (count) {
                                  totalCount += 1;
                                  orderItems.removeWhere((element) => element.id == item.id);
                                  if (count > 0) {
                                    orderItems.add(item);
                                  }
                                  countProductAmount();
                                  setState(() {});
                                },
                                onRemove: (count) {
                                  totalCount -= 1;
                                  orderItems.removeWhere((element) => element.id == item.id);
                                  if (count > 0) {
                                    orderItems.add(item);
                                  }
                                  countProductAmount();
                                  setState(() {});
                                });
                          },
                        ),
                      ],
                    ),
                  )
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            loaderWidget().center().visible(appStore.isLoading),
          ],
        );
      }),
      bottomNavigationBar: orderItems.isNotEmpty
          ? BottomAppBar(
              child: InkWell(
                onTap: () async {
                  countProductAmount();
                  setState(() {});
                  await showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                    builder: (context) {
                      return Container(
                        width: context.width(),
                        decoration: boxDecorationWithShadow(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("itemsAdded", style: boldTextStyle()), // todo
                                // Text(language.itemsAdded, style: boldTextStyle()),
                                InkWell(
                                    child: Icon(Icons.close),
                                    onTap: () {
                                      finish(context);
                                    }),
                              ],
                            ).paddingAll(16),
                            Divider(height: 0),
                            ListView.builder(
                              padding: EdgeInsets.all(16),
                              shrinkWrap: true,
                              itemCount: orderItems.length,
                              itemBuilder: (context, index) {
                                ProductData item = orderItems[index];
                                return ProductItemComponent(product: item, isView: true);
                              },
                            ),
                            Divider(height: 0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(language.total, style: boldTextStyle()),
                                Text(printAmount(productAmount),
                                    style: boldTextStyle(size: 14, color: colorPrimary)),
                              ],
                            ).paddingAll(16),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.local_grocery_store_outlined),
                    8.width,
                    Text('$totalCount ${totalCount > 1 ? "items" : "item"} added', style: primaryTextStyle()), // todo
                    // Text('$totalCount ${totalCount > 1 ? language.items : language.item} ${language.added}', style: primaryTextStyle()),
                    Icon(showBottom ? Icons.arrow_drop_down : Icons.arrow_drop_up),
                    Spacer(),
                    AppButton(
                      color: colorPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.next, style: boldTextStyle(color: Colors.white,height: 1.1)),
                          Icon(Icons.navigate_next, color: Colors.white),
                        ],
                      ),
                      onTap: () {

                        CreateOrderScreen(orderItems: orderItems, storeId: widget.store.id).launch(context);
                      },
                    ),
                  ],
                ).paddingSymmetric(vertical: 8, horizontal: 16),
              ),
            )
          : null,
    );
  }

  countProductAmount() {
    productAmount = 0;
    orderItems.forEach((element) {
      productAmount = productAmount + (element.price.validate() * element.count.validate());
    });
  }
}
