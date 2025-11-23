import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductUnavailableDialog extends StatelessWidget {
  final String? startTime, endTime;
  final double? width, height;
  const ProductUnavailableDialog(
      {Key? key, this.startTime, this.endTime, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime startTimeData = DateFormat("hh:mm:ss").parse(startTime!);
    DateTime endTimeData = DateFormat("hh:mm").parse(endTime!);
    var dateFormat = DateFormat("h:mm a");
    return Dialog(
      shape: DesignConfig.setRounded(16.0),
      child: contentBox(context, startTimeData, endTimeData, dateFormat),
    );
  }

  contentBox(BuildContext context, DateTime startTimeData, DateTime endTimeData,
      var dateFormat) {
    return Container(
      margin: EdgeInsets.only(top: height! / 40.0),
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.onSurface, 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: width! / 20.0, end: width! / 20.0),
            child: Text(
                "${UiUtils.getTranslatedLabel(context, itmeAvailableBetweenLabel)} ${dateFormat.format(startTimeData)} to ${dateFormat.format(endTimeData)}",
                textAlign: TextAlign.start,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.76),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                )),
          ),
          SizedBox(height: height! / 20),
          SizedBox(
            width: width,
            child: SmallButtonContainer(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              height: height,
              width: width,
              text: UiUtils.getTranslatedLabel(context, okLabel),
              start: width! / 20.0,
              end: width! / 20.0,
              bottom: height! / 60.0,
              top: height! / 99.0,
              radius: 5.0,
              status: false,
              borderColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              textColor: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
            ),
          )
        ],
      ),
    );
  }
}
