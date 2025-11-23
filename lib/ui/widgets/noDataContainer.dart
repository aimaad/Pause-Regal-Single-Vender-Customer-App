import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoDataContainer extends StatelessWidget {
  final String? title, subTitle, image;
  final double? width, height;
  const NoDataContainer(
      {Key? key,
      this.title,
      this.subTitle,
      this.image,
      this.width,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
          start: width! / 20.0,
          end: width! / 20.0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
              minWidth: viewportConstraints.maxWidth),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(DesignConfig.setSvgPath(image!)),
                SizedBox(height: height! / 20.0),
                Text(title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: height! / 80.0),
                Text(subTitle!,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ]),
        ),
      );
    });
  }
}
