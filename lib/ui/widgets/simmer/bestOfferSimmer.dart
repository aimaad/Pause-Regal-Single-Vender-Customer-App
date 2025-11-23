import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BestOfferSimmer extends StatelessWidget {
  final int? length;
  final double? width, height;
  const BestOfferSimmer({Key? key, this.length, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        child: Container(
          height: height!,
          margin: EdgeInsetsDirectional.only(start: width! / 20.0),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: length == 3 ? 0.79 : 0.77,
            children: List.generate(length!, (index) {
              return Padding(
                padding: EdgeInsetsDirectional.only(top: height! / 88.0),
                child: Container(
                  decoration: DesignConfig.boxDecorationContainer(
                      shimmerContentColor, 10.0),
                  width: width! / 3.0,
                  height: height! / 9.0,
                  padding:
                      const EdgeInsetsDirectional.only(top: 14.0, bottom: 14.0),
                  margin: EdgeInsetsDirectional.only(end: width! / 20.0),
                  child: Container(
                      height: 8.0, width: 40.0, color: shimmerContentColor),
                ),
              );
            }),
          ),
        ));
  }
}
