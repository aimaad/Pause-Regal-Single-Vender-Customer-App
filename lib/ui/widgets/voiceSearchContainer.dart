import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VoiceSearchContainer extends StatelessWidget {
  final double? width, height;
  final String? from;
  const VoiceSearchContainer({Key? key, this.width, this.height, this.from})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        margin: EdgeInsetsDirectional.only(
            start: width! / 50.0, top: height! / 99.0, bottom: height! / 99.0),
        width: from == "home" ? width! / 8.0 : width! / 8.8,
        height: from == "home" ? height! / 20.0 : height! / 16.5,
        decoration: DesignConfig.boxDecorationContainer(
            Theme.of(context).colorScheme.primary, 4.0),
        child: SvgPicture.asset(DesignConfig.setSvgPath("voice_search_icon"),
            fit: BoxFit.scaleDown));
  }
}
