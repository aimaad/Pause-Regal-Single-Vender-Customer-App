import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_location_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class LocationDialog extends StatefulWidget {
  final double? width, height;
  final String? from;
  const LocationDialog(
      {Key? key, required this.width, required this.height, this.from})
      : super(key: key);

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: DesignConfig.setRounded(16.0),
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: widget.height! / 40.0),
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.onSurface, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(UiUtils.getTranslatedLabel(context, deviceLocationIsOffLabel),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              textAlign: TextAlign.left),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: widget.width! / 20.0, end: widget.width! / 20.0),
            child: Text(
                UiUtils.getTranslatedLabel(
                    context, deviceLocationOffSubTitleLabel),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.76),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(
            height: 22,
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: widget.width! / 20.0, end: widget.width! / 20.0),
            child: Text(
                UiUtils.getTranslatedLabel(
                    context, deviceLocationOffPermissionLabel),
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 12)),
          ),
          const SizedBox(
            height: 22,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.from == "skip"
                  ? Expanded(
                      child: SmallButtonContainer(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: widget.height,
                      width: widget.width,
                      text: UiUtils.getTranslatedLabel(context, cancelLabel),
                      start: 0,
                      end: 0,
                      bottom: widget.height! / 60.0,
                      top: widget.height! / 99.0,
                      radius: 5.0,
                      status: false,
                      borderColor: Theme.of(context).colorScheme.onSurface,
                      textColor: Theme.of(context).colorScheme.onSecondary,
                      onTap: () async {
                        if (context
                                    .read<SettingsCubit>()
                                    .state
                                    .settingsModel!
                                    .city
                                    .toString() !=
                                "" &&
                            context
                                    .read<SettingsCubit>()
                                    .state
                                    .settingsModel!
                                    .city
                                    .toString() !=
                                "null") {
                          Navigator.of(context).pop();
                          context.read<SettingsCubit>().changeShowSkip();
                          Navigator.of(context).pushReplacementNamed(
                              Routes.home,
                              arguments: {'id': 0});
                        } else {
                          Navigator.of(context).pop();
                          context.read<SettingsCubit>().changeShowSkip();
                          await Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const NoLocationScreen(),
                              ),
                              (Route<dynamic> route) => false);
                        }
                      },
                    ))
                  : const SizedBox(),
              widget.from == "skip"
                  ? const SizedBox.shrink()
                  : Expanded(
                      child: SmallButtonContainer(
                          color: Theme.of(context).colorScheme.primary,
                          height: widget.height,
                          width: widget.width! / 0.7,
                          text:
                              UiUtils.getTranslatedLabel(context, cancelLabel),
                          start: widget.width! / 20.0,
                          end: widget.width! / 20.0,
                          bottom: widget.height! / 60.0,
                          top: widget.height! / 99.0,
                          radius: 5.0,
                          status: false,
                          borderColor: Theme.of(context).colorScheme.primary,
                          textColor: white,
                          onTap: () async {
                            Navigator.of(context).pop();
                          }),
                    ),
              SmallButtonContainer(
                  color: Theme.of(context).colorScheme.primary,
                  height: widget.height,
                  width: widget.width! / 0.7,
                  text: UiUtils.getTranslatedLabel(
                      context, enableDeviceLocationLabel),
                  start: 0,
                  end: widget.width! / 20.0,
                  bottom: widget.height! / 60.0,
                  top: widget.height! / 99.0,
                  radius: 5.0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.primary,
                  textColor: white,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openAppSettings();
                  })
            ],
          ),
        ],
      ),
    );
  }
}
