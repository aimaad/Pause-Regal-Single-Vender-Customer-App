import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:erestroSingleVender/cubit/profileManagement/uploadProfileCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/buttomContainer.dart';
import 'package:erestroSingleVender/ui/widgets/keyboardOverlay.dart';
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
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UploadProfileCubit>(
            create: (context) => UploadProfileCubit(
                  ProfileManagementRepository(),
                )),
        BlocProvider<UpdateUserDetailCubit>(
            create: (_) =>
                UpdateUserDetailCubit(ProfileManagementRepository())),
      ], child: const ProfileScreen()),
    );
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController referralCodeController =
      TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  bool status = false;
  final formKey = GlobalKey<FormState>();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  File? image;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  // get image File camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // sourcePath: pickedFile!.path,
        //     aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;

    context.read<UploadProfileCubit>().uploadProfilePicture(image);
  }

//get image file from library
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // sourcePath: pickedFile!.path,
        //     aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;

    context.read<UploadProfileCubit>().uploadProfilePicture(image);
  }

  Future chooseProfile(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: true,
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                  top: height! / 80.0,
                  bottom: height! / 80.0,
                  end: width! / 20.0,
                  start: width! / 20.0),
              child: Text(
                UiUtils.getTranslatedLabel(context, profilePictureLabel),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              decoration:
                                  DesignConfig.boxDecorationContainerBorder(
                                      commentBoxBorderColor,
                                      Theme.of(context).colorScheme.onSurface,
                                      100.0),
                              child: Icon(
                                Icons.photo_library,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, galleryLabel),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _getFromCamera();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              decoration:
                                  DesignConfig.boxDecorationContainerBorder(
                                      commentBoxBorderColor,
                                      Theme.of(context).colorScheme.onSurface,
                                      100.0),
                              child: Icon(
                                Icons.photo_camera,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, cameraLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
          ],
        );
      },
    );
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
    nameController =
        TextEditingController(text: context.read<AuthCubit>().getName());
    emailController =
        TextEditingController(text: context.read<AuthCubit>().getEmail());
    phoneNumberController =
        TextEditingController(text: context.read<AuthCubit>().getMobile());
    referralCodeController = TextEditingController(
        text: context.read<AuthCubit>().getReferralCode());
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    referralCodeController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget nameField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return UiUtils.getTranslatedLabel(context, enterNameLabel);
            }
            return null;
          },
          controller: nameController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, fullNameLabel),
              UiUtils.getTranslatedLabel(context, enterNameLabel),
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

  Widget referralCodeField() {
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: TextFormField(
            enabled: false,
            controller: referralCodeController,
            decoration: DesignConfig.inputDecorationextField(
                UiUtils.getTranslatedLabel(context, referralCodeLabel),
                UiUtils.getTranslatedLabel(context, enterReferralCodeLabel),
                width!,
                context),
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )));
  }

  Widget phoneNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: IntlPhoneField(
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
          enabled:
              (context.read<AuthCubit>().getType() == "google") ? true : false,
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
              defaulIsoCountryCode = value.code;
            });
          }),
        ));
  }

  Widget emailField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          validator: (value) {
            return UiUtils.validateEmail(value!, StringsRes.enterEmail,
                UiUtils.getTranslatedLabel(context, enterValidEmailLabel));
          },
          controller: emailController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, emailIdLabel),
              StringsRes.enterEmail,
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
                  width,
                  UiUtils.getTranslatedLabel(context, profileLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Form(
                key: formKey,
                child: BlocConsumer<UploadProfileCubit, UploadProfileState>(
                    listener: (context, state) {
                  if (state is UploadProfileFailure) {
                    UiUtils.setSnackBar(state.errorMessage, context, false,
                        type: "2");
                  } else if (state is UploadProfileSuccess) {
                    context
                        .read<AuthCubit>()
                        .updateUserProfileUrl(state.imageUrl);
                  }
                }, builder: (context, state) {
                  return Container(
                      height: height,
                      margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                      decoration: DesignConfig.boxDecorationContainerHalf(
                          Theme.of(context).colorScheme.onSurface),
                      width: width,
                      child: Container(
                        margin: EdgeInsetsDirectional.only(
                            start: width! / 20.0,
                            end: width! / 20.0,
                            top: height! / 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: width! / 10.0,
                                      end: width! / 10.0,
                                      bottom: height! / 25.0),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Center(
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.50),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: ClipOval(
                                                child:
                                                    DesignConfig.imageWidgets(
                                                        context
                                                            .read<AuthCubit>()
                                                            .getProfile(),
                                                        85,
                                                        85,
                                                        "1")),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 15.0,
                                            start: width! / 5.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            chooseProfile(context);
                                          },
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            child: CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              child: Icon(Icons.edit_outlined,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                nameField(),
                                emailField(),
                                phoneNumberField(),
                                (context
                                            .read<SystemConfigCubit>()
                                            .isReferEarnOn() ==
                                        "1")
                                    ? referralCodeField()
                                    : const SizedBox.shrink(),
                                BlocConsumer<UpdateUserDetailCubit,
                                        UpdateUserDetailState>(
                                    bloc: context.read<UpdateUserDetailCubit>(),
                                    listener: (context, state) {
                                      if (state is UpdateUserDetailFailure) {
                                        status = false;
                                      }
                                      if (state is UpdateUserDetailSuccess) {
                                        context
                                            .read<AuthCubit>()
                                            .updateUserName(
                                                state.authModel.username ?? "");
                                        context
                                            .read<AuthCubit>()
                                            .updateUserEmail(
                                                state.authModel.email ?? "");
                                        context
                                            .read<AuthCubit>()
                                            .updateUserMobile(
                                                state.authModel.mobile ?? "");
                                        context
                                            .read<AuthCubit>()
                                            .updateUserReferralCode(
                                                state.authModel.referralCode ??
                                                    "");
                                        UiUtils.setSnackBar(
                                            StringsRes.updateSuccessFully,
                                            context,
                                            false,
                                            type: "1");
                                        status = false;
                                      } else if (state
                                          is UpdateUserDetailFailure) {
                                        UiUtils.setSnackBar(
                                            state.errorMessage, context, false,
                                            type: "2");
                                        status = false;
                                      }
                                    },
                                    builder: (context, state) {
                                      return SizedBox(
                                        width: width,
                                        child: ButtonContainer(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          height: height,
                                          width: width,
                                          text: UiUtils.getTranslatedLabel(
                                              context, saveProfileLabel),
                                          start: 0,
                                          end: 0,
                                          bottom: height! / 55.0,
                                          top: height! / 35.0,
                                          status: status,
                                          borderColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          onPressed: () {
                                            setState(() {
                                              status = true;
                                            });
                                            if (formKey.currentState!
                                                .validate()) {
                                              context
                                                  .read<UpdateUserDetailCubit>()
                                                  .updateProfile(
                                                      userId: context
                                                          .read<AuthCubit>()
                                                          .getId(),
                                                      name: nameController.text,
                                                      email:
                                                          emailController.text,
                                                      mobile:
                                                          phoneNumberController
                                                              .text,
                                                      referralCode:
                                                          referralCodeController
                                                              .text);
                                            } else {
                                              setState(() {
                                                status = false;
                                              });
                                            }
                                          },
                                        ),
                                      );
                                    })
                              ]),
                        ),
                      ));
                }),
              ),
            ),
    );
  }
}
