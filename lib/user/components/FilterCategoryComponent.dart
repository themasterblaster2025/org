import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_delivery/extensions/extension_util/bool_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/list_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';

import '../../extensions/common.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main/models/CategoryModel.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Constants.dart';

class FilterCategoryComponent extends StatefulWidget {
  final int? storeId;
  final List<int>? selectedCategory;
  final List<int>? selectedSubCategory;
  final Function(List<int>, List<int>) onUpdate;

  FilterCategoryComponent({this.storeId, this.selectedCategory, this.selectedSubCategory, required this.onUpdate});

  @override
  FilterCategoryComponentState createState() => FilterCategoryComponentState();
}

class FilterCategoryComponentState extends State<FilterCategoryComponent> {
  List<Category> categoryList = [];
  ScrollController scrollController = ScrollController();
  int page = 1;
  int totalPage = 1;
  bool isLastPage = false;

  List<int> selectedCategory = [];
  List<int> selectedSubCategory = [];

  @override
  void initState() {
    super.initState();

    init();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !appStore.isLoading) {
        if (page < totalPage) {
          page++;
          init();
        }
      }
    });
  }

  void init() async {
    appStore.setLoading(true);
    await getCategorySubcategoryList(page: page, storeDetailId: widget.storeId).then((value) {
      appStore.setLoading(false);
      totalPage = value.pagination!.totalPages.validate(value: 1);
      page = value.pagination!.currentPage.validate(value: 1);
      isLastPage = false;
      if (page == 1) {
        categoryList.clear();
      }
      categoryList.addAll(value.data!);
      setState(() {});
    }).catchError((e) {
      isLastPage = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
    selectedCategory = widget.selectedCategory.validate();
    selectedSubCategory = widget.selectedSubCategory.validate();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("categoryFilter", style: boldTextStyle(size: 18)), // todo
                    // Text(language.categoryFilter, style: boldTextStyle(size: 18)),
                    Icon(Icons.close).onTap(() {
                      finish(context);
                    }),
                  ],
                ).paddingOnly(left: 16, top: 50, right: 16, bottom: 16),
                categoryList.isNotEmpty
                    ? Column(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: categoryList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Category item = categoryList[index];
                        return Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(horizontal: 8),
                            childrenPadding: EdgeInsets.symmetric(horizontal: 24),
                            initiallyExpanded: selectedSubCategory.toSet().intersection(item.subCategory.validate().map((e) => e.id).toList().toSet()).isNotEmpty,
                            title: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: colorPrimary,
                              value: selectedCategory.contains(item.id.validate()),
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text('${item.name}', style: primaryTextStyle()),
                              onChanged: (value) {
                                if (value.validate()) {
                                  selectedCategory.add(item.id.validate());
                                } else {
                                  selectedCategory.remove(item.id.validate());
                                }
                                setState(() {});
                              },
                            ),
                            children: item.subCategory.validate().map((e) {
                              return CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                value: selectedSubCategory.contains(e.id.validate()),
                                activeColor: colorPrimary,
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text('${e.subcategoryName}', style: primaryTextStyle()),
                                onChanged: (value) {
                                  if (value.validate()) {
                                    selectedSubCategory.add(e.id.validate());
                                  } else {
                                    selectedSubCategory.remove(e.id.validate());
                                  }
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ).expand(),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius), side: BorderSide(color: appStore.isDarkMode ? Colors.white12 : viewLineColor)),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent),
                          child: Text(language.clear, style: boldTextStyle(color: Colors.grey)),
                          onPressed: () {
                            selectedCategory.clear();
                            selectedSubCategory.clear();
                            Navigator.pop(context);
                            widget.onUpdate.call(selectedCategory, selectedSubCategory);
                          },
                        ).expand(),
                        16.width,
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultRadius)),
                            elevation: 0,
                            backgroundColor: colorPrimary,
                          ),
                          child: Text("apply", style: boldTextStyle(color: Colors.white)),// todo
                          // child: Text(language.apply, style: boldTextStyle(color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onUpdate.call(selectedCategory, selectedSubCategory);
                          },
                        ).expand()
                      ],
                    ).paddingAll(16),
                  ],
                ).expand()
                    : appStore.isLoading
                    ? SizedBox()
                    : emptyWidget(),
              ],
            ),
            loaderWidget().visible(appStore.isLoading)
          ],
        ),
      ),
    );
  }
}
