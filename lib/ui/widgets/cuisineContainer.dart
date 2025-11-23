import 'package:erestroSingleVender/data/model/cuisineModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter/material.dart';

class CuisineContainer extends StatelessWidget {
  final List<CuisineModel> cuisineList;
  final double? width, height;
  final int index;
  const CuisineContainer(
      {Key? key,
      required this.cuisineList,
      this.width,
      this.height,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DesignConfig.imageWidgets(
              cuisineList[index].image!, height! / 16, width! / 4, "2"),
          const SizedBox(height: 6.0),
          SizedBox(
            width: width! / 5,
            child: Text(cuisineList[index].name!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis),
                maxLines: 2),
          ),
        ],
      ),
    );
  }
}
