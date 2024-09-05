import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_delivery/extensions/common.dart';
import 'package:mighty_delivery/extensions/decorations.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/extensions/system_utils.dart';
import 'package:video_player/video_player.dart';

import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../components/CommonScaffoldComponent.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/dynamic_theme.dart';

class AddSupportTicketScreen extends StatefulWidget {
  const AddSupportTicketScreen({super.key});

  @override
  State<AddSupportTicketScreen> createState() => _AddSupportTicketScreenState();
}

class _AddSupportTicketScreenState extends State<AddSupportTicketScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController messageCon = TextEditingController();
  TextEditingController supportTypeCon = TextEditingController();
  TextEditingController resolutionDetailcon = TextEditingController();
  //todo add keys
  //List<String> supportType = ["Vehicle", "Orders", "Delivery person"];
  String? selectedSupportType;
  String? selectedUploadValue;
  XFile? image;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    selectedSupportType = SUPPORT_TYPE[0];
  }

  @override
  void dispose() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.dispose();
    }

    super.dispose();
  }

  Future saveCustomerSupportApi() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('customersupport-save');
    multiPartRequest.fields['message'] = messageCon.text;
    multiPartRequest.fields['support_type'] = selectedSupportType!;
    multiPartRequest.fields['user_id'] = getIntAsync(USER_ID).toString();
    multiPartRequest.fields['status'] = "pending";
    //  multiPartRequest.fields['resolution_detail'] = "resuolution details";
    if (selectedUploadValue == "Image") if (image != null)
      multiPartRequest.files.add(await MultipartFile.fromPath('support_image', image!.path));
    if (selectedUploadValue == "Video") if (image != null)
      multiPartRequest.files.add(await MultipartFile.fromPath('support_videos', image!.path));

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      appStore.setLoading(false);
      toast(data['message']);
      finish(context);
    }, onError: (error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: language.addSupportTicket, // todo
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.height,
                  Text(language.message, style: primaryTextStyle()), //todo
                  8.height,
                  AppTextField(
                    isValidationRequired: true,
                    controller: messageCon,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.fieldRequiredMsg,
                    decoration: commonInputDecoration(hintText: language.message),
                  ),

                  16.height,
                  // Text("Resolution detail", style: primaryTextStyle()), // todo
                  // 8.height,
                  // AppTextField(
                  //   isValidationRequired: true,
                  //   controller: resolutionDetailcon,
                  //   textFieldType: TextFieldType.NAME,
                  //   errorThisFieldRequired: language.fieldRequiredMsg,
                  //   decoration: commonInputDecoration(hintText: "Resolution detail"),
                  // ),
                  // 16.height,
                  Text(language.supportType, style: primaryTextStyle()),
                  8.height,
                  Container(
                    width: context.width(),
                    height: 50,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(defaultRadius), color: Colors.transparent),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: commonInputDecoration(),
                      hint: Text(language.selectDocument, style: primaryTextStyle()),
                      value: SUPPORT_TYPE[0],
                      dropdownColor: context.cardColor,
                      items: SUPPORT_TYPE.map((String e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: primaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        selectedSupportType = value;
                        setState(() {});
                      },
                    ),
                  ),
                  16.height,
                  Text(language.uploadDetails, style: primaryTextStyle()),
                  8.height,
                  Container(
                    width: context.width(),
                    height: 50,
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: ColorUtils.colorPrimary.withOpacity(0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Center the radio buttons
                      children: <Widget>[
                        Radio<String>(
                          value: IMAGE,
                          groupValue: selectedUploadValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedUploadValue = value;
                            });
                          },
                        ),
                        Text(language.image),
                        SizedBox(width: 20),
                        Radio<String>(
                          value: VIDEO,
                          groupValue: selectedUploadValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedUploadValue = value;
                            });
                          },
                        ),
                        Text(language.video).expand(),
                        if (selectedUploadValue != null && !selectedUploadValue.isEmptyOrNull)
                          Container(
                                  height: 38,
                                  decoration: boxDecorationDefault(
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                      color: Colors.transparent),
                                  child: Text(language.select, style: boldTextStyle(size: 12)).paddingAll(6).center())
                              .onTap(() async {
                            if (selectedUploadValue == IMAGE) {
                              image = null;
                              image = await ImagePicker().pickImage(source: ImageSource.gallery);
                            } else {
                              image = null;
                              image = await ImagePicker().pickVideo(source: ImageSource.gallery);
                            }
                            _controller = VideoPlayerController.file(File(image!.path.toString()));
                            _initializeVideoPlayerFuture = _controller!.initialize();

                            // Loop the video
                            _controller!.setLooping(true);
                            setState(() {});
                          }).paddingRight(10)
                      ],
                    ),
                  ),
                  if (selectedUploadValue == IMAGE && image != null && !image!.path.isEmptyOrNull)
                    Image.file(File(image!.path),
                            height: 150, width: 150, fit: BoxFit.cover, alignment: Alignment.center)
                        .paddingTop(10)
                        .center()
                        .cornerRadiusWithClipRRect(4),
                  if (selectedUploadValue == VIDEO && _controller != null)
                    FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Container(
                            width: 150,
                            height: 150, // Set height as per your requirement
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ).paddingTop(10).center()
                ],
              ),
            ),
          ),
          loaderWidget().visible(appStore.isLoading)
        ],
      ),
      bottomNavigationBar: AppButton(
          color: ColorUtils.colorPrimary,
          textColor: Colors.white,
          text: language.save,
          onTap: () {
            if (formKey.currentState!.validate()) {
              saveCustomerSupportApi();
            }
          }).paddingAll(16),
    );
  }
}
