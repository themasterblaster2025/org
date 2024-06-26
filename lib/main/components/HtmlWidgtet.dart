
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';

class HtmlWidgetComponent extends StatelessWidget {
  final String postContent;
  final Color? color;

  HtmlWidgetComponent({required this.postContent, this.color});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      postContent,
      customWidgetBuilder: (tag) {
        if (tag.localName == 'img' && tag.attributes.containsKey('src')) {

          double? height = tag.attributes['height'] != null ? double.tryParse(tag.attributes['height']!) : null;
          double? width = tag.attributes['width'] != null ? double.tryParse(tag.attributes['width']!) : null;

          print("image url : ${tag.attributes['src']}");
          return CachedNetworkImage(
            imageUrl: tag.attributes['src']!,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            height: height,
            width: width,
          );
        }
        return null;

      },
    );
  }
}

class MyWidgetFactory extends WidgetFactory with CachedNetworkImageFactory {}


// iframe for video
/* HtmlWidget(
                          '<html><iframe style="width:100%" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen"></iframe></html>',
                          factoryBuilder: () => MyWidgetFactory(),
                        ),*/
