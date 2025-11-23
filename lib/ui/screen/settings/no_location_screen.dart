import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/address/getLocationDetailCubit.dart';
import 'package:erestroSingleVender/cubit/address/searchLocationCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/addressModel.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/locationDialog.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/getLocationByLatLong.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:location_geocoder/location_geocoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class NoLocationScreen extends StatefulWidget {
  const NoLocationScreen({Key? key}) : super(key: key);

  @override
  NoLocationScreenState createState() => NoLocationScreenState();
}

class NoLocationScreenState extends State<NoLocationScreen> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  double? width, height;
  TextEditingController locationSearchController =
      TextEditingController(text: "");
  Timer? _debounce;
  String? currentAddress = "";
  late LocatitonGeocoder geocoder; /*  = LocatitonGeocoder(placeSearchApiKey) */
  var geolocation = GetLocationByLatLong('');

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    geocoder = LocatitonGeocoder(
        decodeBase64(context.read<SystemConfigCubit>().appReference()));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    locationSearchController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _processLocationDetailSuccess(GetLocationDetailSuccess state) {
    // Handle the successful location detail result
    final locationDetail = state.locationDetailsModel;
    if (locationDetail.location != null) {
      // Extract city name from address components
      String? city;
      if (locationDetail.addressComponents != null) {
        for (var component in locationDetail.addressComponents!) {
          if (component.types?.contains('locality') == true) {
            city = component.longText;
            break;
          } else if (component.types?.contains('administrative_area_level_1') ==
              true) {
            city = component.longText;
            break;
          }
        }
      }

      // Use either found city or formatted address as fallback
      String cityName = city ?? locationDetail.formattedAddress ?? "";

      // Set the location data
      setAddressForDisplayData(
        context,
        "0",
        cityName,
        locationDetail.location!.latitude.toString(),
        locationDetail.location!.longitude.toString(),
        locationDetail.formattedAddress ?? "",
      );

      // Navigate to home screen
      context.read<SettingsCubit>().changeShowSkip();
      Navigator.of(context)
          .pushReplacementNamed(Routes.home, arguments: {'id': 0});
    }
  }

  locationEnableDialog() async {
    if (context.read<SettingsCubit>().state.settingsModel!.city.toString() ==
            "" &&
        context.read<SettingsCubit>().state.settingsModel!.city.toString() ==
            "null") {
      // Use location.
      getUserLocation();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return LocationDialog(width: width, height: height);
          });
    }
  }

  getUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        getUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        locationEnableDialog();
      } else {
        getUserLocation();
      }
    } else {
      try {
        final demoMode = context.read<SystemConfigCubit>().getDemoMode();
        print("Demo mode value: $demoMode");

        if (demoMode == "0") {
          demoModeAddressDefault(context, "0");
          context.read<SettingsCubit>().changeShowSkip();
          Navigator.of(context)
              .pushReplacementNamed(Routes.home, arguments: {'id': 0});
          return;
        }

        if (await Permission.location.serviceStatus.isEnabled) {
          final LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
          );
          Position position = await Geolocator.getCurrentPosition(
              locationSettings: locationSettings);
          final List<Address> placemarks =
              await geolocation.findAddressesFromCoordinates(
            Coordinates(position.latitude, position.longitude),
          );
          String? location =
              "${placemarks.first.addressLine},${placemarks.first.locality ?? placemarks.first.subAdminArea!},${placemarks.first.postalCode},${placemarks.first.countryName}";

          if (mounted) {
            await setAddressForDisplayData(
                context,
                "0",
                placemarks.first.locality ?? placemarks.first.subAdminArea!,
                position.latitude.toString(),
                position.longitude.toString(),
                location.toString().replaceAll(",,", ","));
            context.read<SettingsCubit>().changeShowSkip();
            Navigator.of(context)
                .pushReplacementNamed(Routes.home, arguments: {'id': 0});
          }
        } else {
          getUserLocation();
        }
      } catch (e) {
        getUserLocation();
      }
    }
  }

  getCurrentUserLocation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        getCurrentUserLocation();
      }
    } else if (permission == LocationPermission.denied) {
      print(permission.toString());
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        locationEnableDialog();
      } else {
        getCurrentUserLocation();
      }
    } else {
      try {
        if (await Permission.location.serviceStatus.isEnabled) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.of(context).pushNamed(Routes.address, arguments: {
              'from': 'location',
              'addressModel': AddressModel()
            });
          }
        } else {
          getCurrentUserLocation();
        }
      } catch (e) {
        getCurrentUserLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : BlocListener<GetLoactionDetailCubit, GetLocationDetailState>(
              listener: (context, state) {
                if (state is GetLocationDetailSuccess) {
                  _processLocationDetailSuccess(state);
                } else if (state is GetLocationDetailFailure) {
                  UiUtils.setSnackBar(state.errorMessage, context, false,
                      type: "2");
                }
              },
              child: Scaffold(
                  body: Container(
                alignment: Alignment.center,
                margin: EdgeInsetsDirectional.only(
                    start: width! / 20.0, end: width! / 20.0),
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          DesignConfig.setSvgPath("Location_get"),
                          height: height! / 3.0,
                          width: height! / 3.0,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(height: height! / 20.0),
                        Text(
                          UiUtils.getTranslatedLabel(
                              context, noLocationTitleLabel),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                          maxLines: 2,
                        ),
                        SizedBox(height: height! / 60.0),
                        Text(
                            UiUtils.getTranslatedLabel(
                                context, noLocationDescriptionLabel),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          width: width,
                          child: ButtonContainer(
                            color: Theme.of(context).colorScheme.primary,
                            height: height,
                            width: width,
                            text: UiUtils.getTranslatedLabel(
                                context, noLocationEnableLabel),
                            bottom: height! / 99.0,
                            start: 0,
                            end: 0,
                            top: height! / 20.0,
                            status: false,
                            borderColor: Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              getUserLocation();
                            },
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: ButtonContainer(
                            color: Theme.of(context).colorScheme.onSurface,
                            height: height,
                            width: width,
                            text: UiUtils.getTranslatedLabel(
                                context, noLocationManuallyLabel),
                            bottom: height! / 99.0,
                            start: 0,
                            end: 0,
                            top: height! / 99.0,
                            status: false,
                            borderColor:
                                Theme.of(context).colorScheme.onSurface,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              showLocationBottomModelSheet();
                            },
                          ),
                        ),
                      ]),
                ),
              )),
            ),
    );
  }

  showLocationBottomModelSheet() {
    showModalBottomSheet(
        useSafeArea: true,
        showDragHandle: true,
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        builder: (context) {
          return Container(
            height: (height! / 1.5),
            padding: EdgeInsets.only(left: width! / 15.0, right: width! / 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  placesAutoCompleteTextField(),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                    child: Row(children: [
                      Expanded(child: DesignConfig.dividerSolid()),
                      SizedBox(width: width! / 40.0),
                      Text(
                        UiUtils.getTranslatedLabel(context, orLabel),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: width! / 40.0),
                      Expanded(child: DesignConfig.dividerSolid()),
                    ]),
                  ),
                  ListTile(
                    visualDensity: const VisualDensity(vertical: -4),
                    minLeadingWidth: 0,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.gps_fixed,
                        color: Theme.of(context).colorScheme.secondary),
                    title: Text(
                        UiUtils.getTranslatedLabel(
                            context, useCurrentLocationLabel),
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 5.0),
                      child: Text(
                        currentAddress.toString() == ""
                            ? UiUtils.getTranslatedLabel(context, usingGPSLabel)
                            : currentAddress.toString(),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    onTap: () async {
                      getCurrentUserLocation();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget placesAutoCompleteTextField() {
    return BlocConsumer<SearchLocationCubit, SearchLocationState>(
      listener: (context, state) {
        if (state is SearchLocationFailure) {
          UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Container(
              width: width,
              margin: EdgeInsetsDirectional.only(
                top: height! / 60.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: locationSearchController,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: width! / 25.0,
                    vertical: height! / 60.0,
                  ),
                  hintText: UiUtils.getTranslatedLabel(
                    context,
                    enterLocationAreaCityEtcLabel,
                  ),
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.7),
                    size: 24,
                  ),
                  suffixIcon: locationSearchController.text.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.7),
                              size: 20,
                            ),
                            onPressed: () {
                              locationSearchController.clear();
                              FocusScope.of(context).unfocus();
                              context
                                  .read<SearchLocationCubit>()
                                  .clearResults();
                              setState(() {});
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            if (state is SearchLocationSuccess) ...[
              Builder(builder: (context) {
                if (locationSearchController.text.isNotEmpty &&
                    state.locations.isNotEmpty) {
                  return Container(
                    width: width,
                    padding: EdgeInsetsDirectional.only(
                        top: height! / 80,
                        bottom: height! / 80,
                        start: width! / 40,
                        end: width! / 40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    constraints: BoxConstraints(maxHeight: height! / 3),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.locations.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = state.locations[index];
                        try {
                          final placePrediction = suggestion.placePrediction;
                          final mainText =
                              placePrediction.structuredFormat.mainText.text;
                          final secondaryText = placePrediction
                              .structuredFormat.secondaryText.text;

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: ListTile(
                              horizontalTitleGap: 0,
                              dense: true,
                              visualDensity: const VisualDensity(
                                  vertical: -4, horizontal: -4),
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.location_on,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withValues(alpha: 0.7),
                                size: 20,
                              ),
                              title: Text(
                                mainText,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                secondaryText,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () async {
                                // Close keyboard
                                FocusScope.of(context).unfocus();

                                // Update search text
                                locationSearchController.text = mainText;

                                // Clear search results
                                context
                                    .read<SearchLocationCubit>()
                                    .clearResults();

                                // Close the bottom sheet
                                if (mounted) {
                                  Navigator.pop(context);
                                }

                                // Fetch location details
                                context
                                    .read<GetLoactionDetailCubit>()
                                    .fetchLocationDetail(
                                        placePrediction.placeId);
                              },
                            ),
                          );
                        } catch (e) {
                          print("Error processing suggestion: $e");
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  );
                } else {
                  print("No locations found or search text is empty");
                  return const SizedBox.shrink();
                }
              }),
            ] else if (state is SearchLocationLoading) ...[
              Builder(builder: (context) {
                // print("SearchLocationLoading state");
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
            ] else ...[
              Builder(builder: (context) {
                // print("SearchLocation state: ${state.runtimeType}");
                return const SizedBox.shrink();
              }),
            ],
          ],
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<SearchLocationCubit>().fetchSearchLocation(query);
      } else {
        context.read<SearchLocationCubit>().clearResults();
      }
    });
  }
}
