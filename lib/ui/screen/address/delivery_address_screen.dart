import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/data/model/addressModel.dart';
import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/cubit/address/addressCubit.dart';
import 'package:erestroSingleVender/cubit/address/deleteAddressCubit.dart';
import 'package:erestroSingleVender/cubit/address/updateAddressCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/addressSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/noDataContainer.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({Key? key}) : super(key: key);

  @override
  DeliveryAddressScreenState createState() => DeliveryAddressScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UpdateAddressCubit>(
            create: (_) => UpdateAddressCubit(AddressRepository())),
      ], child: const DeliveryAddressScreen()),
    );
  }
}

class DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
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
    context.read<AddressCubit>().fetchAddress();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> refreshList() async {
    context.read<AddressCubit>().fetchAddress();
  }

  Widget noAddressData() {
    return NoDataContainer(
        image: "address",
        title: UiUtils.getTranslatedLabel(context, noAddressYetLabel),
        subTitle:
            UiUtils.getTranslatedLabel(context, noAddressYetSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget addressData() {
    return BlocConsumer<AddressCubit, AddressState>(
        bloc: context.read<AddressCubit>(),
        listener: (context, state) {
          if (state is AddressFailure) {
            if (state.errorStatusCode.toString() == tockenExpireCode) {}
          }
        },
        builder: (context, state) {
          if (state is AddressProgress || state is AddressInitial) {
            return AddressSimmer(width: width!, height: height!);
          }
          if (state is AddressFailure) {
            if (state.errorStatusCode.toString() == tockenExpireCode) {}
            return noAddressData();
          }
          final addressList = (state as AddressSuccess).addressList;
          return addressList.isEmpty
              ? noAddressData()
              : ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: addressList.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, index) {
                    return BlocProvider(
                      create: (context) =>
                          DeleteAddressCubit(AddressRepository()),
                      child: Builder(builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {});
                          },
                          child: Container(
                            decoration: addressList[index].isDefault == "1"
                                ? DesignConfig.boxDecorationContainerBorder(
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.05),
                                    8)
                                : DesignConfig.boxDecorationContainerBorder(
                                    Theme.of(context).colorScheme.onPrimary,
                                    Theme.of(context).colorScheme.onSurface,
                                    8,
                                    status: true),
                            margin: EdgeInsetsDirectional.only(
                                bottom: height! / 50.0,
                                start: width! / 20.0,
                                end: width! / 20.0),
                            padding: EdgeInsetsDirectional.only(
                                top: height! / 60.0,
                                bottom: height! / 60.0,
                                start: width! / 20.0,
                                end: width! / 40.0),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      addressList[index].type == homeKey
                                          ? SvgPicture.asset(
                                              DesignConfig.setSvgPath(
                                                  "home_address"),
                                              fit: BoxFit.scaleDown,
                                              height: 20,
                                              width: 20,
                                            )
                                          : addressList[index].type == officeKey
                                              ? SvgPicture.asset(
                                                  DesignConfig.setSvgPath(
                                                      "work_address"),
                                                  fit: BoxFit.scaleDown,
                                                  height: 20,
                                                  width: 20,
                                                )
                                              : SvgPicture.asset(
                                                  DesignConfig.setSvgPath(
                                                      "other_address"),
                                                  fit: BoxFit.scaleDown,
                                                  height: 20,
                                                  width: 20,
                                                ),
                                      SizedBox(width: height! / 99.0),
                                      Text(
                                        addressList[index].type!,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      BlocConsumer<UpdateAddressCubit,
                                          UpdateAddressState>(
                                        bloc:
                                            context.read<UpdateAddressCubit>(),
                                        listener: (context, state) {
                                          if (state is UpdateAddressSuccess) {
                                            context
                                                .read<AddressCubit>()
                                                .updateAddress(
                                                    state.addressModel);
                                          } else if (state
                                              is UpdateAddressFailure) {
                                            if (state.errorStatusCode
                                                    .toString() ==
                                                "Token Expired") {}
                                          }
                                        },
                                        builder: (context, state) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              unselectedWidgetColor:
                                                  greayLightColor,
                                            ),
                                            child: Checkbox(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    side: BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary,
                                                      width: 0.5,
                                                      strokeAlign: 1.0,
                                                    )),
                                                value:
                                                    addressList[index].isDefault == "1"
                                                        ? true
                                                        : false,
                                                side: WidgetStateBorderSide
                                                    .resolveWith(
                                                  (states) => BorderSide(
                                                      width: 1.0,
                                                      color: addressList[index]
                                                                  .isDefault ==
                                                              "1"
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .secondary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onPrimary,
                                                      strokeAlign: 1),
                                                ),
                                                activeColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                onChanged: (val) {
                                                  context
                                                      .read<
                                                          UpdateAddressCubit>()
                                                      .fetchUpdateAddress(
                                                          addressList[index].id,
                                                          addressList[index]
                                                              .userId,
                                                          addressList[index]
                                                              .mobile,
                                                          addressList[index]
                                                              .address,
                                                          addressList[index]
                                                              .city,
                                                          addressList[index]
                                                              .latitude,
                                                          addressList[index]
                                                              .longitude,
                                                          addressList[index]
                                                              .area,
                                                          addressList[index]
                                                              .type,
                                                          addressList[index]
                                                              .name,
                                                          addressList[index]
                                                              .countryCode,
                                                          addressList[index]
                                                              .alternateCountryCode,
                                                          addressList[index]
                                                              .alternateMobile,
                                                          addressList[index]
                                                              .landmark,
                                                          addressList[index]
                                                              .pincode,
                                                          addressList[index]
                                                              .state,
                                                          addressList[index]
                                                              .country,
                                                          "1");
                                                },
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                fillColor: WidgetStatePropertyAll(
                                                    addressList[index].isDefault ==
                                                            "1"
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurface),
                                                checkColor: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                visualDensity:
                                                    const VisualDensity(
                                                        horizontal: -4,
                                                        vertical: -4)),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  SizedBox(height: height! / 60.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${addressList[index].address!}, ${addressList[index].area!}, ${addressList[index].city}, ${addressList[index].state!}, ${addressList[index].pincode!}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: height! / 60.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, Routes.address,
                                                arguments: {
                                                  'addressModel':
                                                      addressList[index],
                                                  'from': 'updateAddress',
                                                });
                                          },
                                          child: Text(
                                            UiUtils.getTranslatedLabel(
                                                context, editLabel),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontWeight: FontWeight.w600),
                                          )),
                                      SizedBox(width: width! / 20.0),
                                      BlocConsumer<DeleteAddressCubit,
                                              DeleteAddressState>(
                                          bloc: context
                                              .read<DeleteAddressCubit>(),
                                          listener: (context, state) {
                                            if (state is DeleteAddressSuccess) {
                                              context
                                                  .read<AddressCubit>()
                                                  .deleteAddress(state.id);
                                              UiUtils.setSnackBar(
                                                  StringsRes.deleteSuccessFully,
                                                  context,
                                                  false,
                                                  type: "1");
                                            }
                                          },
                                          builder: (context, state) {
                                            return GestureDetector(
                                                onTap: () {
                                                  if (addressList.length > 1) {
                                                    context
                                                        .read<
                                                            DeleteAddressCubit>()
                                                        .fetchDeleteAddress(
                                                            addressList[index]
                                                                .id!);
                                                  } else if (addressList[index]
                                                          .isDefault ==
                                                      "1") {
                                                    UiUtils.setSnackBar(
                                                        StringsRes
                                                            .addressChange,
                                                        context,
                                                        false,
                                                        type: "2");
                                                  } else {
                                                    UiUtils.setSnackBar(
                                                        StringsRes.addressOne,
                                                        context,
                                                        false,
                                                        type: "2");
                                                  }
                                                },
                                                child: Text(
                                                  UiUtils.getTranslatedLabel(
                                                      context, deleteLabel),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ));
                                          })
                                    ],
                                  ),
                                ]),
                          ),
                        );
                      }),
                    );
                  });
        });
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
            : Scaffold(
                appBar: DesignConfig.appBar(
                    context,
                    width!,
                    UiUtils.getTranslatedLabel(context, myAddressLabel),
                    const PreferredSize(
                        preferredSize: Size.zero, child: SizedBox())),
                bottomNavigationBar: ButtonContainer(
                  color: Theme.of(context).colorScheme.primary,
                  height: height,
                  width: width,
                  text: UiUtils.getTranslatedLabel(context, addNewAddressLabel),
                  start: width! / 40.0,
                  end: width! / 40.0,
                  bottom: height! / 55.0,
                  top: 0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.address, arguments: {
                      'addressModel': AddressModel(),
                      'from': 'addAddress',
                    }).then((value) {
                      if (context
                          .read<AddressCubit>()
                          .getAddressList()
                          .isEmpty) {
                        refreshList();
                      }
                    });
                  },
                ),
                body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  height: height!,
                  width: width,
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    color: Theme.of(context).colorScheme.primary,
                    child: addressData(),
                  ),
                ),
              ));
  }
}
