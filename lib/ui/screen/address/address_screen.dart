import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/address/getLocationDetailCubit.dart';
import 'package:erestroSingleVender/cubit/address/searchLocationCubit.dart';
import 'package:erestroSingleVender/cubit/address/updateAddressCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/addressModel.dart';
import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/cubit/address/addAddressCubit.dart';
import 'package:erestroSingleVender/cubit/address/addressCubit.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/ui/screen/home/home_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/keyboardOverlay.dart';
import 'package:erestroSingleVender/ui/widgets/pinAnimation.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/mapLoadSimmer.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/getLocationByLatLong.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/locationDialog.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:geocoding/geocoding.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'dart:ui' as ui;
import 'package:location_geocoder/location_geocoder.dart';

class AddressScreen extends StatefulWidget {
  final AddressModel? addressModel;
  final String? from;
  const AddressScreen({Key? key, this.addressModel, this.from})
      : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
  static Route<AddressScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<AddAddressCubit>(
              create: (_) => AddAddressCubit(
                AddressRepository(),
              ),
            ),
            BlocProvider<UpdateAddressCubit>(
              create: (_) => UpdateAddressCubit(
                AddressRepository(),
              ),
            )
          ],
          child: AddressScreen(
              addressModel: arguments['addressModel'],
              from: arguments['from'])),
    );
  }
}

class _AddressScreenState extends State<AddressScreen> {
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  final Set<Marker> _markers = {};
  double? width, height;
  String? locationStatus = officeKey;
  late Position position;
  TextEditingController areaRoadApartmentNameController =
      TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController alternateMobileNumberController =
      TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController landmarkController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  TextEditingController pinCodeController = TextEditingController(text: "");
  TextEditingController locationSearchController =
      TextEditingController(text: "");
  Timer? _debounce;
  String? states, country, pincode, latitude, longitude, address, city, area;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  String? checkStatusFirstTime = "1", isPhoneValidated = "";
  bool markerMove = false;
  String? countryCode = defaulCountryCode,
      alternetNumbercountryCode = defaulCountryCode;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  FocusNode alternetNumberFocusNode = FocusNode();
  FocusNode alternetNumberFocusNodeAndroid = FocusNode();
  late LocatitonGeocoder geocoder; /*  = LocatitonGeocoder(placeSearchApiKey) */
  var geolocation = GetLocationByLatLong('');

  GlobalKey<FormState> _formKey = GlobalKey();
  bool _submitted = false;
  locationEnableDialog() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return LocationDialog(width: width, height: height);
        });
  }

  defaultLocation() async {
    final List<Address> placemarks =
        await geolocation.findAddressesFromCoordinates(
      Coordinates(latlong!.latitude, latlong!.longitude),
    );
    setState(() {
      latlong = LatLng(
          double.parse(context.read<SettingsCubit>().getSettings().latitude),
          double.parse(context.read<SettingsCubit>().getSettings().longitude));
      _cameraPosition =
          CameraPosition(target: latlong!, zoom: 18.0, bearing: 0);
      if (_controller != null) {
        _controller!
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      }
      states = placemarks.first.adminArea ?? "";
      country = placemarks.first.countryName ?? "";
      pincode = placemarks.first.postalCode ?? "";
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
      if (areaRoadApartmentNameController.text.trim().isEmpty) {
        areaRoadApartmentNameController.text =
            placemarks.first.subLocality ?? "";
        areaRoadApartmentNameController.selection = TextSelection.fromPosition(
            TextPosition(offset: areaRoadApartmentNameController.text.length));
      }
      if (cityController.text.trim().isEmpty) {
        cityController.text =
            placemarks.first.locality ?? placemarks.first.subAdminArea!;
        cityController.selection = TextSelection.fromPosition(
            TextPosition(offset: cityController.text.length));
      }
      address = placemarks.first.addressLine ?? "";
      addressController =
          TextEditingController(text: placemarks.first.addressLine.toString());
      city = placemarks.first.locality ?? placemarks.first.subAdminArea!;

      print(
          "states:$states,country:$country,pincode:$pincode,latitude:$latitude,longitude:${longitude}city:$city");

      locationController.text = placemarks.first.addressLine.toString();
      _markers.add(Marker(
        markerId: const MarkerId("Marker"),
        position: LatLng(position.latitude, position.longitude),
      ));
    });
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
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        defaultLocation();
        locationEnableDialog();
      } else {
        getUserLocation();
      }
    } else {
      try {
        final LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
        );
        position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings);

        final List<Address> placemarks =
            await geolocation.findAddressesFromCoordinates(
          Coordinates(position.latitude, position.longitude),
        );

        if (mounted) {
          if (widget.from == "updateAddress") {
            setState(() {
              latlong = LatLng(double.parse(widget.addressModel!.latitude!),
                  double.parse(widget.addressModel!.longitude!));

              _cameraPosition =
                  CameraPosition(target: latlong!, zoom: 18.0, bearing: 0);
              if (_controller != null) {
                _controller!.animateCamera(
                    CameraUpdate.newCameraPosition(_cameraPosition));
              }
              states = widget.addressModel!.state!;
              country = widget.addressModel!.country!;
              pincode = widget.addressModel!.pincode!;
              latitude = widget.addressModel!.latitude!.toString();
              longitude = widget.addressModel!.longitude!.toString();
              area = widget.addressModel!.area!;
              areaRoadApartmentNameController.text = widget.addressModel!.area!;
              cityController.text = widget.addressModel!.city!;
              addressController = TextEditingController(
                  text: widget.addressModel!.address.toString());
              if (areaRoadApartmentNameController.text.trim().isEmpty) {
                areaRoadApartmentNameController.text =
                    widget.addressModel!.area!;
                areaRoadApartmentNameController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: areaRoadApartmentNameController.text.length));
              }
              if (cityController.text.trim().isEmpty) {
                cityController.text = widget.addressModel!.city!;
                cityController.selection = TextSelection.fromPosition(
                    TextPosition(
                        offset: areaRoadApartmentNameController.text.length));
              }
              address = widget.addressModel!.address!;
              city = widget.addressModel!.city!;

              locationController.text =
                  "${widget.addressModel!.address!},${widget.addressModel!.area!},${widget.addressModel!.city},${widget.addressModel!.state!},${widget.addressModel!.pincode!}";
              _markers.add(Marker(
                markerId: const MarkerId("Marker"),
                position: LatLng(double.parse(widget.addressModel!.latitude!),
                    double.parse(widget.addressModel!.longitude!)),
              ));
            });
          } else {
            setState(() {
              latlong = LatLng(position.latitude, position.longitude);

              _cameraPosition =
                  CameraPosition(target: latlong!, zoom: 18.0, bearing: 0);
              if (_controller != null) {
                _controller!.animateCamera(
                    CameraUpdate.newCameraPosition(_cameraPosition));
              }

              // Handle empty placemarks
              if (placemarks.isNotEmpty) {
                final placemark = placemarks.first;
                states = placemark.adminArea ?? "";
                country = placemark.countryName ?? "";
                pincode = placemark.postalCode ?? "";
                latitude = position.latitude.toString();
                longitude = position.longitude.toString();
                if (areaRoadApartmentNameController.text.trim().isEmpty) {
                  areaRoadApartmentNameController.text =
                      placemark.subLocality ?? "";
                  areaRoadApartmentNameController.selection =
                      TextSelection.fromPosition(TextPosition(
                          offset: areaRoadApartmentNameController.text.length));
                }
                if (cityController.text.trim().isEmpty) {
                  cityController.text =
                      placemark.locality ?? placemark.subAdminArea ?? "";
                  cityController.selection = TextSelection.fromPosition(
                      TextPosition(offset: cityController.text.length));
                }
                address = placemark.addressLine ?? "";
                addressController =
                    TextEditingController(text: placemark.addressLine ?? "");
                city = placemark.locality ?? placemark.subAdminArea ?? "";
                locationController.text = placemark.addressLine ?? "";
              } else {
                // Set default values when no placemarks are found
                states = "";
                country = "";
                pincode = "";
                latitude = position.latitude.toString();
                longitude = position.longitude.toString();
                area = "";
                areaRoadApartmentNameController.text = "";
                cityController.text = "";
                address = "";
                addressController = TextEditingController(text: "");
                city = "";
                locationController.text = "";
              }

              _markers.add(Marker(
                markerId: const MarkerId("Marker"),
                position: LatLng(position.latitude, position.longitude),
              ));
            });
          }
        }
      } catch (e) {
        print("Error getting location details: $e");
        if (mounted) {
          UiUtils.setSnackBar(
              "Unable to get location details. Please try again.",
              context,
              false,
              type: "2");
        }
        // Retry getting location after a delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            getUserLocation();
          }
        });
      }
    }
  }

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

    // Initialize map position
    if (widget.from == "updateAddress" && widget.addressModel != null) {
      latlong = LatLng(
        double.parse(widget.addressModel!.latitude!),
        double.parse(widget.addressModel!.longitude!),
      );
    } else if (context.read<SettingsCubit>().state.settingsModel!.latitude !=
            "" &&
        context.read<SettingsCubit>().state.settingsModel!.longitude != "") {
      latlong = LatLng(
        double.parse(
            context.read<SettingsCubit>().state.settingsModel!.latitude),
        double.parse(
            context.read<SettingsCubit>().state.settingsModel!.longitude),
      );
    } else {
      latlong =
          LatLng(double.parse(defaultLatitude), double.parse(defaultLongitude));
    }

    // Set initial camera position
    _cameraPosition = CameraPosition(
      target: latlong!,
      zoom: 18.0,
      bearing: 0,
    );

    // Get user location after map is initialized
    Future.delayed(Duration(milliseconds: 500), () {
      getUserLocation();
    });

    // Setup keyboard focus listeners
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    alternetNumberFocusNode.addListener(() {
      bool hasFocus = alternetNumberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });

    // Load search history
    loadSearchAddressData();

    if (widget.from == "updateAddress") {
      locationStatus = widget.addressModel!.type!;
      alternateMobileNumberController =
          TextEditingController(text: widget.addressModel!.alternateMobile!);
      phoneNumberController =
          TextEditingController(text: widget.addressModel!.mobile);
      countryCode = widget.addressModel!.countryCode;
      areaRoadApartmentNameController =
          TextEditingController(text: widget.addressModel!.area!);
      addressController =
          TextEditingController(text: widget.addressModel!.address!);
      cityController = TextEditingController(text: widget.addressModel!.city!);
      landmarkController =
          TextEditingController(text: widget.addressModel!.landmark!);
      pinCodeController =
          TextEditingController(text: widget.addressModel!.pincode!);
    } else {
      if (context.read<SettingsCubit>().state.settingsModel!.latitude != "" &&
          context.read<SettingsCubit>().state.settingsModel!.longitude != "") {
        latlong = LatLng(
            double.parse(
                context.read<SettingsCubit>().state.settingsModel!.latitude),
            double.parse(
                context.read<SettingsCubit>().state.settingsModel!.longitude));
        _cameraPosition = CameraPosition(
            target: LatLng(
                double.parse(context
                    .read<SettingsCubit>()
                    .state
                    .settingsModel!
                    .latitude),
                double.parse(context
                    .read<SettingsCubit>()
                    .state
                    .settingsModel!
                    .longitude)),
            zoom: 14.4746);
        city = context.read<SettingsCubit>().state.settingsModel!.city;
        addressController.text =
            context.read<SettingsCubit>().state.settingsModel!.address;
      } else {
        latlong = LatLng(
            double.parse(defaultLatitude), double.parse(defaultLongitude));
        _cameraPosition = CameraPosition(
            target: LatLng(
                double.parse(defaultLatitude), double.parse(defaultLongitude)),
            zoom: 14.4746);
        city = defaultCity;
        addressController.text = defaultAddress;
      }
      phoneNumberController =
          TextEditingController(text: context.read<AuthCubit>().getMobile());
    }
  }

  // Get all items from the database
  loadSearchAddressData() {
    final data = searchAddressBoxData.keys.map((key) {
      final value = searchAddressBoxData.get(key);
      return {
        "key": key,
        "city": value["city"],
        "latitude": value['latitude'],
        "longitude": value['longitude'],
        "address": value['address']
      };
    }).toList();

    setState(() {
      searchAddressData = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  // add Search Address in Database
  Future<void> addSearchAddress(Map<String, dynamic> newItem) async {
    await searchAddressBoxData.add(newItem);
    loadSearchAddressData(); // update the UI
  }

  completeAddressShow() {
    showModalBottomSheet(
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      addressField(),
                      areaRoadApartmentNameField(),
                      mobileNumberField(),
                      alternateMobileNumberField(),
                      landmarkField(),
                      cityField(),
                      pincode == "" ? pinCodeField() : Container(),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(start: width! / 20.0),
                        child: Text(
                            UiUtils.getTranslatedLabel(
                                context, tagThisLocationForLaterLabel),
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500)),
                      ),
                      tagLocation(setState),
                      widget.from == "updateAddress"
                          ? BlocConsumer<UpdateAddressCubit,
                                  UpdateAddressState>(
                              bloc: context.read<UpdateAddressCubit>(),
                              listener: (context, state) {
                                if (state is UpdateAddressSuccess) {
                                  context
                                      .read<AddressCubit>()
                                      .editAddress(state.addressModel);
                                  Navigator.pop(context);
                                  Future.delayed(
                                          const Duration(microseconds: 1000))
                                      .then((value) {
                                    Navigator.pop(context);
                                  });
                                }
                                if (state is UpdateAddressFailure) {
                                  Navigator.pop(context);
                                  UiUtils.setSnackBar(
                                      state.errorMessage, context, false,
                                      type: "2");
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: width!,
                                  child: ButtonContainer(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: height,
                                    width: width,
                                    text: state is UpdateAddressProgress
                                        ? UiUtils.getTranslatedLabel(
                                            context, updateIngLocationLabel)
                                        : UiUtils.getTranslatedLabel(
                                            context, updateLocationLabel),
                                    start: width! / 40.0,
                                    end: width! / 40.0,
                                    bottom: height! / 55.0,
                                    top: 0,
                                    status: (state is UpdateAddressProgress)
                                        ? true
                                        : false,
                                    borderColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (state is UpdateAddressProgress) {
                                        } else {
                                          context
                                              .read<UpdateAddressCubit>()
                                              .fetchUpdateAddress(
                                                widget.addressModel!.id!,
                                                context
                                                    .read<AuthCubit>()
                                                    .getId(),
                                                phoneNumberController.text
                                                    .toString(),
                                                addressController.text,
                                                cityController.text,
                                                latitude ?? "",
                                                longitude ?? "",
                                                areaRoadApartmentNameController
                                                    .text,
                                                locationStatus,
                                                context
                                                    .read<AuthCubit>()
                                                    .getName(),
                                                countryCode
                                                    .toString()
                                                    .replaceAll("+", ""),
                                                alternetNumbercountryCode
                                                    .toString()
                                                    .replaceAll("+", ""),
                                                alternateMobileNumberController
                                                    .text
                                                    .toString(),
                                                landmarkController.text,
                                                pincode == ""
                                                    ? pinCodeController.text
                                                    : pincode!,
                                                states ?? "",
                                                country ?? "",
                                                widget.addressModel!.isDefault,
                                              );
                                        }
                                      }
                                    },
                                  ),
                                );
                              })
                          : BlocConsumer<AddAddressCubit, AddAddressState>(
                              bloc: context.read<AddAddressCubit>(),
                              listener: (context, state) {
                                if (state is AddAddressSuccess) {
                                  context
                                      .read<AddressCubit>()
                                      .addAddress(state.addressModel);
                                  if (widget.from == "login") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const HomeScreen(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    Future.delayed(
                                            const Duration(microseconds: 1000))
                                        .then((value) {
                                      Navigator.pop(context);
                                    });
                                  }
                                }
                                if (state is AddAddressFailure) {
                                  Navigator.pop(context);

                                  UiUtils.setSnackBar(
                                      state.errorMessage, context, false,
                                      type: "2");
                                }
                              },
                              builder: (context, state) {
                                return SizedBox(
                                  width: width!,
                                  child: ButtonContainer(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    height: height,
                                    width: width,
                                    text: state is AddAddressProgress
                                        ? UiUtils.getTranslatedLabel(
                                            context, addingLocationLabel)
                                        : UiUtils.getTranslatedLabel(
                                            context, confirmLocationLabel),
                                    start: width! / 40.0,
                                    end: width! / 40.0,
                                    bottom: height! / 55.0,
                                    top: 0,
                                    status: (state is AddAddressProgress)
                                        ? true
                                        : false,
                                    borderColor:
                                        Theme.of(context).colorScheme.primary,
                                    textColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    onPressed: () {
                                      setState(() => _submitted = true);
                                      _formKey.currentState!.save();
                                      if (_formKey.currentState!.validate() &&
                                          phoneNumberController
                                              .text.isNotEmpty) {
                                        if (state is AddAddressProgress) {
                                        } else {
                                          context
                                              .read<AddAddressCubit>()
                                              .fetchAddAddress(
                                                phoneNumberController.text
                                                    .toString(),
                                                addressController.text,
                                                cityController.text,
                                                latitude ?? "",
                                                longitude ?? "",
                                                areaRoadApartmentNameController
                                                    .text,
                                                locationStatus,
                                                context
                                                    .read<AuthCubit>()
                                                    .getName(),
                                                countryCode.toString(),
                                                alternetNumbercountryCode
                                                    .toString(),
                                                alternateMobileNumberController
                                                    .text,
                                                landmarkController.text,
                                                pincode == ""
                                                    ? pinCodeController.text
                                                    : pincode!,
                                                states ?? "",
                                                country ?? "",
                                                widget.from == "cart"
                                                    ? "1"
                                                    : "0",
                                              );
                                        }
                                      }
                                    },
                                  ),
                                );
                              }),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void dispose() {
    locationSearchController.dispose();
    _debounce?.cancel();
    _connectivitySubscription.cancel();
    locationController.clear();
    areaRoadApartmentNameController.clear();
    addressController.clear();
    cityController.clear();
    landmarkController.clear();
    pinCodeController.clear();
    alternateMobileNumberController.clear();
    _controller!.dispose();
    locationController.dispose();
    areaRoadApartmentNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    alternateMobileNumberController.dispose();
    pinCodeController.dispose();
    landmarkController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget cityField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 40.0,
          end: width! / 20.0,
        ),
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return UiUtils.getTranslatedLabel(context, enterCityLabel);
            }
            return null;
          },
          controller: cityController,
          cursorColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, cityLabel),
              UiUtils.getTranslatedLabel(context, enterCityLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget pinCodeField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 40.0,
          end: width! / 20.0,
        ),
        child: TextFormField(
          controller: pinCodeController,
          cursorColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          textInputAction: TextInputAction.done,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, pinCodeLabel),
              UiUtils.getTranslatedLabel(context, enterpinCodeLabel),
              width!,
              context),
          keyboardType: TextInputType.number,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget addressField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 40.0,
          end: width! / 20.0,
        ),
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return UiUtils.getTranslatedLabel(context, enterAddressLabel);
            }
            return null;
          },
          controller: addressController,
          cursorColor: Theme.of(context).colorScheme.onPrimary,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, addressLabel),
              UiUtils.getTranslatedLabel(context, enterAddressLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget areaRoadApartmentNameField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 40.0,
          end: width! / 20.0,
        ),
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return UiUtils.getTranslatedLabel(
                  context, enterAreaRoadApartmentNameLabel);
            }
            return null;
          },
          controller: areaRoadApartmentNameController,
          cursorColor: Theme.of(context).colorScheme.onPrimary,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, areaRoadApartmentNameLabel),
              UiUtils.getTranslatedLabel(
                  context, enterAreaRoadApartmentNameLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget alternateMobileNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 80.0,
          end: width! / 20.0,
        ),
        child: IntlPhoneField(
          controller: alternateMobileNumberController,
          disableLengthCheck:
              alternateMobileNumberController.text.toString() == ""
                  ? true
                  : false,
          autovalidateMode: AutovalidateMode.disabled,
          textInputAction: TextInputAction.done,
          showDropdownIcon: false,
          dropdownIcon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(width: 1.0, color: textFieldBorder)),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusColor: white,
            counterStyle: const TextStyle(color: white, fontSize: 0),
            border: InputBorder.none,
            hintText: UiUtils.getTranslatedLabel(
                context, enterAlternateMobileNumberLabel),
            labelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.40),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.40),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          flagsButtonMargin: EdgeInsets.all(width! / 40.0),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          focusNode: Platform.isIOS
              ? alternetNumberFocusNode
              : alternetNumberFocusNodeAndroid,
          dropdownIconPosition: IconPosition.trailing,
          initialCountryCode: defaulIsoCountryAlternateCode,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: Directionality.of(context) == ui.TextDirection.rtl
              ? TextAlign.right
              : TextAlign.left,
          onChanged: (phone) {
            setState(() {
              alternetNumbercountryCode = phone.countryCode;
            });
          },
          onCountryChanged: ((value) {
            setState(() {
              print(value.dialCode);
              alternetNumbercountryCode = value.dialCode;
              defaulIsoCountryAlternateCode = value.code;
            });
          }),
        ));
  }

  Widget mobileNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 80.0,
          end: width! / 20.0,
        ),
        child: IntlPhoneField(
          autovalidateMode: _submitted == false
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.always,
          validator: (PhoneNumber? value) {
            print('in widget validator');
            if (value == null || value.number.isEmpty) {
              print('Please Enter Your Phone No');
              return 'Please Enter Your Phone No';
            }
            return null;
          },
          controller: phoneNumberController,
          textInputAction: TextInputAction.done,
          dropdownIcon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76)),
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldBackground,
            contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(width: 1.0, color: textFieldBorder)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusColor: white,
            counterStyle: const TextStyle(color: white, fontSize: 0),
            border: InputBorder.none,
            hintText:
                UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
            labelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.40),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.40),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          flagsButtonMargin: EdgeInsets.all(width! / 40.0),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
          dropdownIconPosition: IconPosition.trailing,
          initialCountryCode: defaulIsoCountryCode,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: Directionality.of(context) == ui.TextDirection.rtl
              ? TextAlign.right
              : TextAlign.left,
          onChanged: (phone) {
            setState(() {
              countryCode = phone.countryCode;
            });
          },
          onCountryChanged: ((value) {
            setState(() {
              print(value.dialCode);
              countryCode = value.dialCode;
              alternetNumbercountryCode = value.code;
            });
          }),
        ));
  }

  Widget landmarkField() {
    return Container(
        padding: EdgeInsetsDirectional.only(
            start: width! / 20.0, top: height! / 99.0),
        margin: EdgeInsetsDirectional.only(
          bottom: height! / 40.0,
          end: width! / 20.0,
        ),
        child: TextField(
          controller: landmarkController,
          cursorColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, landmarkLabel),
              UiUtils.getTranslatedLabel(context, enterLandmarkLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget tagLocation(StateSetter setState) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          end: width! / 40.0,
          top: height! / 99.0,
          start: width! / 40.0,
          bottom: height! / 99.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
          child: TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  locationStatus = homeKey;
                });
              },
              child: Container(
                  width: width,
                  padding: EdgeInsetsDirectional.only(
                    top: height! / 99.0,
                    bottom: height! / 99.0,
                  ),
                  decoration: locationStatus == homeKey
                      ? DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.secondary, 4.0)
                      : DesignConfig.boxDecorationContainerBorder(
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1),
                          4.0,
                          status: true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(DesignConfig.setSvgPath("home_address"),
                          fit: BoxFit.scaleDown,
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                              locationStatus == homeKey
                                  ? white
                                  : Theme.of(context).colorScheme.secondary,
                              BlendMode.srcIn)),
                      const SizedBox(width: 5.0),
                      Text(UiUtils.getTranslatedLabel(context, homeLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: locationStatus == homeKey
                                  ? white
                                  : Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ))),
        ),
        Expanded(
          child: TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  locationStatus = officeKey;
                });
              },
              child: Container(
                  width: width!,
                  padding: EdgeInsetsDirectional.only(
                      top: height! / 99.0, bottom: height! / 99.0),
                  decoration: locationStatus == officeKey
                      ? DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.secondary, 4.0)
                      : DesignConfig.boxDecorationContainerBorder(
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1),
                          4.0,
                          status: true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        DesignConfig.setSvgPath("work_address"),
                        fit: BoxFit.scaleDown,
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                            locationStatus == officeKey
                                ? white
                                : Theme.of(context).colorScheme.secondary,
                            BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5.0),
                      Text(UiUtils.getTranslatedLabel(context, officeLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: locationStatus == officeKey
                                  ? white
                                  : Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ))),
        ),
        Expanded(
          child: TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                setState(() {
                  locationStatus = otherKey;
                });
              },
              child: Container(
                  width: width!,
                  padding: EdgeInsetsDirectional.only(
                      top: height! / 99.0, bottom: height! / 99.0),
                  decoration: locationStatus == otherKey
                      ? DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.secondary, 4.0)
                      : DesignConfig.boxDecorationContainerBorder(
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1),
                          4.0,
                          status: true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(DesignConfig.setSvgPath("other_address"),
                          fit: BoxFit.scaleDown,
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                              locationStatus == otherKey
                                  ? white
                                  : Theme.of(context).colorScheme.secondary,
                              BlendMode.srcIn)),
                      const SizedBox(width: 5),
                      Text(UiUtils.getTranslatedLabel(context, otherLabel),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: locationStatus == otherKey
                                  ? white
                                  : Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ))),
        ),
      ]),
    );
  }

  Widget locationChange() {
    return Container(
        margin: const EdgeInsetsDirectional.only(bottom: 10.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
              SizedBox(width: height! / 99.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.toString(),
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      addressController.text,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSecondary,
                          overflow: TextOverflow.ellipsis),
                      maxLines: 2,
                    ),
                  ],
                ),
              )
            ]));
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.isNotEmpty) {
        context.read<SearchLocationCubit>().fetchSearchLocation(query);
      } else {
        context.read<SearchLocationCubit>().clearResults();
      }
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
                  top: height! / 60.0, start: width! / 20, end: width! / 20),
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
            if (state is SearchLocationSuccess &&
                locationSearchController.text.isNotEmpty)
              Container(
                width: width,
                margin: EdgeInsetsDirectional.only(
                    start: width! / 20, end: width! / 20),
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
                constraints: BoxConstraints(maxHeight: height! / 2),
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
                      final secondaryText =
                          placePrediction.structuredFormat.secondaryText.text;

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: ListTile(
                          horizontalTitleGap: 0,
                          dense: true,
                          visualDensity:
                              const VisualDensity(vertical: -4, horizontal: -4),
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
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            secondaryText,
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            // Close keyboard
                            FocusScope.of(context).unfocus();

                            // Update search text
                            locationSearchController.text = mainText;

                            // Fetch location details
                            context
                                .read<GetLoactionDetailCubit>()
                                .fetchLocationDetail(placePrediction.placeId);

                            // Clear search results
                            context.read<SearchLocationCubit>().clearResults();
                          },
                        ),
                      );
                    } catch (e) {
                      print("Error processing suggestion: $e");
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLocationDetailListener() {
    return BlocConsumer<GetLoactionDetailCubit, GetLocationDetailState>(
      listener: (context, state) {
        if (state is GetLocationDetailSuccess) {
          final detail = state.locationDetailsModel;
          if (detail.location != null) {
            setState(() {
              latlong = LatLng(
                detail.location!.latitude ?? 0,
                detail.location!.longitude ?? 0,
              );
              _cameraPosition = CameraPosition(
                target: latlong!,
                zoom: 18.0,
                bearing: 0,
              );

              // Update address fields
              addressController.text = detail.formattedAddress ?? "";
              String cityName = "";
              for (var component in detail.addressComponents ?? []) {
                if (component.types?.contains('locality') ?? false) {
                  cityName = component.longText ?? "";
                  break;
                }
              }
              cityController.text = cityName;
              city = cityName;

              // Update other fields
              latitude = detail.location!.latitude.toString();
              longitude = detail.location!.longitude.toString();
              address = detail.formattedAddress ?? "";

              // Update markers
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: const MarkerId("Selected Location"),
                  position: latlong!,
                ),
              );

              // Animate map to new location
              if (_controller != null) {
                _controller!.animateCamera(
                  CameraUpdate.newCameraPosition(_cameraPosition),
                );
              }

              // Update location controller text
              locationController.text = detail.formattedAddress ?? "";
            });
          }
        } else if (state is GetLocationDetailFailure) {
          UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
        }
      },
      builder: (context, state) {
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (value, dynamic) {
              if (value) {
                return;
              }
              Future.delayed(const Duration(microseconds: 1000)).then((value) {
                Navigator.pop(context);
              });
            },
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: DesignConfig.appBar(
                    context,
                    width!,
                    UiUtils.getTranslatedLabel(context, deliveryAddressLabel),
                    const PreferredSize(
                        preferredSize: Size.zero, child: SizedBox())),
                body: Stack(children: [
                  SizedBox(
                    height: height! / 1.7,
                    child: (latlong != null)
                        ? Stack(
                            children: [
                              SafeArea(
                                child: GoogleMap(
                                    onCameraMove: (position) {
                                      _cameraPosition = position;
                                    },
                                    onCameraIdle: () {
                                      if (markerMove == false) {
                                        if (latlong ==
                                            LatLng(
                                                _cameraPosition.target.latitude,
                                                _cameraPosition
                                                    .target.longitude)) {
                                        } else {
                                          getLocation();
                                        }
                                      }
                                    },
                                    zoomControlsEnabled: false,
                                    minMaxZoomPreference:
                                        const MinMaxZoomPreference(0, 16),
                                    compassEnabled: false,
                                    indoorViewEnabled: true,
                                    mapToolbarEnabled: true,
                                    myLocationButtonEnabled: false,
                                    mapType: MapType.normal,
                                    initialCameraPosition: _cameraPosition,
                                    gestureRecognizers: <Factory<
                                        OneSequenceGestureRecognizer>>{}
                                      ..add(Factory<PanGestureRecognizer>(() =>
                                          PanGestureRecognizer()
                                            ..onUpdate =
                                                (dragUpdateDetails) {}))
                                      ..add(Factory<ScaleGestureRecognizer>(
                                          () => ScaleGestureRecognizer()
                                            ..onStart = (dragUpdateDetails) {}))
                                      ..add(Factory<TapGestureRecognizer>(
                                          () => TapGestureRecognizer()))
                                      ..add(Factory<
                                              VerticalDragGestureRecognizer>(
                                          () => VerticalDragGestureRecognizer()
                                            ..onDown = (dragUpdateDetails) {
                                              if (markerMove == false) {
                                              } else {
                                                setState(() {
                                                  markerMove = false;
                                                });
                                              }
                                            })),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      Future.delayed(
                                              const Duration(milliseconds: 500))
                                          .then((value) {
                                        _controller = (controller);
                                        _controller!.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                _cameraPosition));
                                      });
                                    },
                                    onTap: (latLng) {
                                      _controller!.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              _cameraPosition));
                                      if (markerMove == false) {
                                      } else {
                                        setState(() {
                                          markerMove = false;
                                        });
                                      }
                                    }),
                              ),
                              PinAnimation(
                                  color: Theme.of(context).colorScheme.primary),
                              Center(
                                  child: SvgPicture.asset(
                                      DesignConfig.setSvgPath('other_address'),
                                      width: 35,
                                      height: 35)),
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                end: width! / 90.0,
                                top: height! / 2.0,
                                child: InkWell(
                                  onTap: () =>
                                      _checkPermission(() async {}, context),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsetsDirectional.only(
                                        end: 10),
                                    decoration: DesignConfig
                                        .boxDecorationContainerBorder(
                                            lightFont,
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            10.0),
                                    child: Icon(
                                      Icons.my_location,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : MapLoadSimmer(width: width!, height: height!),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsetsDirectional.only(top: height! / 1.70),
                      width: width,
                      child: Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsetsDirectional.only(
                          top: height! / 30.0,
                          start: width! / 20.0,
                          end: width! / 20.0,
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsetsDirectional.zero,
                          child: latlong != null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text(
                                          UiUtils.getTranslatedLabel(context,
                                              selectDeliveryLocationLabel),
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w500)),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 60.0,
                                            bottom: height! / 40.0),
                                        child: DesignConfig.dividerSolid(),
                                      ),
                                      locationChange(),
                                      SizedBox(
                                        width: width!,
                                        child: ButtonContainer(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          height: height,
                                          width: width,
                                          text: (widget.from == "location" ||
                                                  widget.from == "change")
                                              ? UiUtils.getTranslatedLabel(
                                                  context, confirmLocationLabel)
                                              : UiUtils.getTranslatedLabel(
                                                  context,
                                                  enterCompleteAddressLocationLabel),
                                          start: 0,
                                          end: 0,
                                          bottom: height! / 80.0,
                                          top: height! / 80.0,
                                          status: false,
                                          borderColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onPressed: () {
                                            if (widget.from == "location" ||
                                                widget.from == "change") {
                                              if (city == "") {
                                                UiUtils.setSnackBar(
                                                    StringsRes
                                                        .sorryWeAreNotDeliveryFoodOnCurrentLocation,
                                                    context,
                                                    false,
                                                    type: "2");
                                              } else {
                                                if (mounted) {
                                                  setState(() {
                                                    if (context
                                                            .read<
                                                                SystemConfigCubit>()
                                                            .getDemoMode() ==
                                                        "0") {
                                                      demoModeAddressDefault(
                                                          context, "1");
                                                    } else {
                                                      setAddressForDisplayData(
                                                          context,
                                                          "1",
                                                          city.toString(),
                                                          latitude!.toString(),
                                                          longitude!.toString(),
                                                          address.toString());
                                                    }

                                                    Future.delayed(
                                                        Duration.zero, () {
                                                      addSearchAddress({
                                                        "city": city.toString(),
                                                        "latitude":
                                                            latitude.toString(),
                                                        "longitude": longitude
                                                            .toString(),
                                                        "address":
                                                            address.toString()
                                                      }).then((value) {
                                                        if (widget.from ==
                                                            "location") {
                                                          context
                                                              .read<
                                                                  SettingsCubit>()
                                                              .changeShowSkip();
                                                          Navigator.of(context)
                                                              .pushNamedAndRemoveUntil(
                                                                  Routes.home,
                                                                  (Route<dynamic>
                                                                          route) =>
                                                                      false,
                                                                  arguments: {
                                                                'id': 0
                                                              });
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      });
                                                    });
                                                  });
                                                }
                                              }
                                            } else {
                                              completeAddressShow();
                                            }
                                          },
                                        ),
                                      ),
                                    ])
                              : MapDataLoadSimmer(
                                  width: width!, height: height!),
                        ),
                      ),
                    ),
                  ),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: height! / 99.0,
                      start: 0,
                      end: 0,
                      child: placesAutoCompleteTextField()),
                  _buildLocationDetailListener(),
                ])),
          );
  }

  Set<Marker> myMarker() {
    _markers.clear();
    _markers.add(Marker(
      onDrag: (value) {},
      onDragStart: (value) {},
      onDragEnd: (value) {},
      markerId: MarkerId(Random().nextInt(10000).toString()),
      visible: false,
      position: LatLng(latlong!.latitude, latlong!.longitude),
      draggable: true,
    ));
    return _markers;
  }

  Future<void> getLocation() async {
    try {
      latlong = LatLng(
          _cameraPosition.target.latitude, _cameraPosition.target.longitude);

      final List<Address> placemarks =
          await geolocation.findAddressesFromCoordinates(
        Coordinates(latlong!.latitude, latlong!.longitude),
      );

      if (placemarks.isEmpty) {
        print(
            "No placemarks found for coordinates: ${latlong!.latitude}, ${latlong!.longitude}");
        return;
      }

      final placemark = placemarks.first;

      setState(() {
        states = placemark.adminArea ?? "";
        country = placemark.countryName ?? "";
        pincode = placemark.postalCode ?? "";
        latitude = latlong!.latitude.toString();
        longitude = latlong!.longitude.toString();
        area = placemark.subLocality ?? "";
        areaRoadApartmentNameController.text = placemark.subLocality ?? "";
        address = placemark.addressLine ?? "";
        addressController =
            TextEditingController(text: placemark.addressLine ?? "");
        city = placemark.locality ?? placemark.subAdminArea ?? "";
        cityController.text =
            placemark.locality ?? placemark.subAdminArea ?? "";
        locationController.text = placemark.addressLine ?? "";
      });
    } catch (e) {
      print("Error getting location details: $e");
      // Optionally show an error message to the user
      if (mounted) {
        UiUtils.setSnackBar(
            "Unable to get location details. Please try again.", context, false,
            type: "2");
      }
    }
  }

  void _checkPermission(Function callback, BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => locationEnableDialog());
    } else {
      callback();
      latlong = LatLng(position.latitude, position.longitude);
      _cameraPosition =
          CameraPosition(target: latlong!, zoom: 18.0, bearing: 0);
      if (_controller != null) {
        _controller!
            .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
      }
      setState(() {
        markerMove = false;
      });
    }
  }
}
