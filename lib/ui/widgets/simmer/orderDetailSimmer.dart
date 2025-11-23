import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderSimmer extends StatelessWidget {
  final double? width, height;
  const OrderSimmer({Key? key, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        child: Container(
            width: width,
            child: Container(
                padding: EdgeInsetsDirectional.only(
                    start: width! / 40.0,
                    end: width! / 40.0,
                    bottom: height! / 99.0),
                width: width!,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                        ),
                        child: Container(
                          width: width,
                          height: height! / 15.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                        ),
                        child: Container(
                          width: width,
                          height: height! / 15.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                        ),
                        child: Container(
                          width: width,
                          height: height! / 10.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                        ),
                        child: Container(
                          width: width,
                          height: height! / 8.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          start: width! / 40.0,
                          end: width! / 40.0,
                        ),
                        child: Container(
                          width: width,
                          height: height! / 10.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 20.0,
                            bottom: height! / 80.0),
                        child: Container(
                          width: width! / 2.5,
                          height: 8.0,
                          color: shimmerContentColor,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: width! / 40.0,
                            end: width! / 40.0,
                            top: height! / 80.0,
                            bottom: height! / 80.0),
                        child: Row(children: [
                          Container(
                            width: width! / 4.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                          const Spacer(),
                          Container(
                            width: width! / 15.0,
                            height: 8.0,
                            color: shimmerContentColor,
                          ),
                        ]),
                      ),
                    ],
                  ),
                ))));
  }
}
