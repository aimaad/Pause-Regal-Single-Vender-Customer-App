import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  final double? height;
  final double? width;
  RadioItem(this._item, {Key? key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _item.isSelected!
          ? DesignConfig.boxDecorationContainerBorder(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              8)
          : DesignConfig.boxDecorationContainerBorder(
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.onSurface,
              8,
              status: true),
      margin: EdgeInsetsDirectional.only(bottom: height! / 50.0),
      padding: EdgeInsetsDirectional.only(
          start: height! / 40.0,
          end: height! / 40.0,
          bottom: height! / 60.0,
          top: height! / 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            _item.img != ""
                ? Container(
                    padding: const EdgeInsetsDirectional.all(5.0),
                    decoration: DesignConfig.boxDecorationContainerBorderCustom(
                        Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.50),
                        Theme.of(context).colorScheme.onSurface,
                        5.0),
                    child: SvgPicture.asset(
                      DesignConfig.setSvgPath(_item.img!),
                      height: 20,
                      width: 20,
                    ),
                  )
                : Container(),
            SizedBox(width: height! / 99.0),
            Text(
              _item.name!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
            )
          ]),
          Icon(
            _item.isSelected!
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: _item.isSelected!
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class RadioModel {
  bool? isSelected;
  final String? img;
  final String? name;

  RadioModel({this.isSelected, this.name, this.img});
}
