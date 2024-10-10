import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/colors.dart';
import 'package:mighty_delivery/extensions/decorations.dart';
import 'package:mighty_delivery/extensions/extension_util/int_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/string_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/ClaimListResponseModel.dart';
import 'package:mighty_delivery/main/utils/Colors.dart';
import 'package:mighty_delivery/main/utils/Common.dart';
import 'package:mighty_delivery/main/utils/Widgets.dart';
import 'package:video_player/video_player.dart';

import '../../extensions/extension_util/context_extensions.dart';
import '../../extensions/text_styles.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/screens/DisplayAttachmentViewScreen.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';

class ClaimDetailstDetailsScreen extends StatefulWidget {
  ClaimItem item;
  ClaimDetailstDetailsScreen(this.item);

  @override
  State<StatefulWidget> createState() {
    return _ClaimDetailstDetailsScreenState();
  }
}

class _ClaimDetailstDetailsScreenState extends State<ClaimDetailstDetailsScreen> {
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   _videoPlayerController1.dispose();
  //   _chewieController?.dispose();
  //   super.dispose();
  // }
  //
  // Future<void> initializePlayer() async {
  //   _videoPlayerController1 = VideoPlayerController.networkUrl(Uri.parse(widget.video));
  //   await Future.wait([_videoPlayerController1.initialize()]);
  //   _createChewieController();
  //   setState(() {});
  // }
  //
  // void _createChewieController() {
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController1,
  //     autoPlay: true,
  //     looping: true,
  //     deviceOrientationsAfterFullScreen: [
  //       DeviceOrientation.portraitDown,
  //       DeviceOrientation.portraitUp,
  //     ],
  //     progressIndicatorDelay: bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
  //     hideControlsTimer: const Duration(seconds: 1),
  //     showOptions: false,
  //     materialProgressColors: ChewieProgressColors(
  //       playedColor: ColorUtils.colorPrimary,
  //       handleColor: ColorUtils.colorPrimary,
  //       backgroundColor: textSecondaryColorGlobal,
  //       bufferedColor: textSecondaryColorGlobal,
  //     ),
  //     // autoInitialize: true,
  //   );
  // }
  Widget buildFileWidget(String url, int id) {
    // Check if the file is an image or PDF
    bool isImage = url.contains('jpg') || url.contains('jpeg') || url.contains('png');

    return Stack(
      children: [
        Container(
          width: 180,
          height: 180,
          decoration: boxDecorationWithRoundedCorners(border: Border.all(color: ColorUtils.colorPrimary)),
          child: isImage
              ? commonCachedNetworkImage(url, width: 180, height: 180).cornerRadiusWithClipRRect(10)
              // Image.file(
              //         width: 100, height: 100,
              //         File(file.path!), // File object for local image display
              //         fit: BoxFit.cover,
              //       ).cornerRadiusWithClipRRect(10)
              : Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
        ).paddingOnly(left: 8, right: 8).onTap(() {
          DisplayAttachmentViewScreen(
            isPhoto: isImage,
            value: url,
            id: id,
          ).launch(context);
        })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBarTitle: widget.item.trakingNo,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                  backgroundColor: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${DateFormat('dd MMM yyyy').format(DateTime.parse("${widget.item.createdAt!}").toLocal())} ',
                              style: primaryTextStyle(size: 14))
                          .expand(),
                      getClaimStatus(
                        widget.item.status!.validate(),
                      )
                    ],
                  ),
                  8.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('# ${widget.item.id}', style: boldTextStyle(size: 14)).expand(),
                            ],
                          ),
                          4.height,
                        ],
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
            16.height,
            Text(
              language.proofValue,
              style: boldTextStyle(),
            ),
            8.height,
            Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                    backgroundColor: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.width(),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.all(12),
                      child: Text(widget.item.profValue!, style: primaryTextStyle()),
                    ),
                  ],
                )),
            16.height,
            Text(
              language.proofDetails,
              style: boldTextStyle(),
            ),
            8.height,
            Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                    backgroundColor: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.width(),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        widget.item.profValue!,
                        style: primaryTextStyle(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                )),
            16.height,
            if (widget.item.attachmentFile != null && widget.item.attachmentFile!.length > 0)
              Text("Atachments", style: boldTextStyle()),
            if (widget.item.attachmentFile != null && widget.item.attachmentFile!.length > 0) 8.height,
            if (widget.item.attachmentFile != null && widget.item.attachmentFile!.length > 0)
              Container(
                width: context.width(),
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.item.attachmentFile!.length,
                  itemBuilder: (context, index) {
                    return buildFileWidget(widget.item.attachmentFile![index], widget.item.id.validate());
                  },
                ),
              ),
            if(widget.item.claimsHistory != null && widget.item.claimsHistory!.isNotEmpty) ...[
            16.height,
            Text(
              "Approved amount", // todo
              style: boldTextStyle(),
            ),
            8.height,
            Container(
                decoration: boxDecorationWithRoundedCorners(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                    backgroundColor: Colors.transparent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.width(),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.all(12),
                      child: Text(widget.item.claimsHistory![0].amount.validate().toString(), style: primaryTextStyle()),
                    ),
                  ],
                )),
              16.height,
              Text(
                language.description,
                style: boldTextStyle(),
              ),
              8.height,
              Container(
                  decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(defaultRadius),
                      border: Border.all(color: ColorUtils.colorPrimary.withOpacity(0.3)),
                      backgroundColor: Colors.transparent),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: context.width(),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(12),
                        child: Text(widget.item.claimsHistory![0].description.validate().toString(), style: primaryTextStyle()),
                      ),
                    ],
                  )),

              if(widget.item.claimsHistory![0].attachmentFile != null && widget.item.claimsHistory![0].attachmentFile!.length >0)...[
                16.height,
                Text(
                  language.attachment,
                  style: boldTextStyle(),
                ),
                8.height,
                Container(
                  width: context.width(),
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.item.claimsHistory![0].attachmentFile!.length,
                    itemBuilder: (context, index) {
                      return buildFileWidget(widget.item.claimsHistory![0].attachmentFile![index], widget.item.id.validate());
                    },
                  ),
                ),
              ],
    ],
          ],
        ),
      ),
    );
  }
}
