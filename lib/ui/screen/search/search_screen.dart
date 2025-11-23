import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getQuantityCubit.dart';
import 'package:erestroSingleVender/cubit/home/search/searchCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/ui/widgets/productContainer.dart';
import 'package:erestroSingleVender/ui/widgets/simmer/productSimmer.dart';
import 'package:erestroSingleVender/ui/widgets/voiceSearchContainer.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/hiveBoxKey.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SearchCubit>(
              create: (_) => SearchCubit(),
              child: const SearchScreen(),
            ));
  }
}

final searchProductKeyWordsBoxData = Hive.box(searchProductKeyWordsBox);
List<Map<String, dynamic>> searchProductKeyWordsData = [];

class SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String searchText = '';
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  List<ProductDetails> searchList = [];
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  bool _hasSpeech = false,
      isLoading = true,
      freeLoading = true,
      paidLoading = true;
  String lastWords = '';
  String _currentLocaleId = '';
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastStatus = '';

  SpeechListenOptions options = SpeechListenOptions(
    cancelOnError: true, // New way to set cancelOnError
    partialResults: true,
    listenMode: ListenMode.dictation,
  );

  @override
  void initState() {
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
    controller.addListener(scrollListener);
    searchController.addListener(() {
      String sText = searchController.text;

      if (searchText != sText) {
        searchText = sText;

        Future.delayed(Duration.zero, () {
          searchApi();
        });
      }
    });

    super.initState();
  }

  searchApi() {
    context.read<SearchCubit>().fetchSearch(
        perPage,
        searchText,
        context.read<AuthCubit>().getId(),
        context.read<SettingsCubit>().getSettings().branchId);
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<SearchCubit>().hasMoreData()) {
        if (searchList.length > int.parse(perPage)) {
          context.read<SearchCubit>().fetchMoreSearchData(
              perPage,
              searchController.text.trim(),
              context.read<AuthCubit>().getId(),
              context.read<SettingsCubit>().getSettings().branchId);
        }
      }
    }
  }

  // Get all items from the database
  void loadSearchProductKeyWordsData() {
    final data = searchProductKeyWordsBoxData.keys.map((key) {
      final value = searchProductKeyWordsBoxData.get(key);
      return {"key": key, "keyWords": value["keyWords"]};
    }).toList();

    setState(() {
      searchProductKeyWordsData = data.reversed.toList();
      // we use "reversed" to sort items in order from the latest to the oldest
    });
    print(searchProductKeyWordsBoxData.length);
  }

  // add Search Products Key Words in Database
  Future<void> addSearchProductKeyWords(Map<String, dynamic> newItem) async {
    await searchProductKeyWordsBoxData.add(newItem);
    loadSearchProductKeyWordsData(); // update the UI
  }

  // Retrieve a single item from the database by using its key
  // Our app won't use this function but I put it here for your reference
  Map<String, dynamic> getSearchProductKeyWords(int key) {
    final item = searchProductKeyWordsBoxData.get(key);
    return item;
  }

  Widget searchDataList() {
    return BlocConsumer<SearchCubit, SearchState>(
        bloc: context.read<SearchCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SearchProgress) {
            return ProductSimmer(length: 5, width: width!, height: height!);
          }
          if (state is SearchInitial) {
            return const Center(
                child: Text(
              "",
              textAlign: TextAlign.center,
            ));
          }
          if (state is SearchFailure) {
            return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height! / 20.0),
                    Text(
                        UiUtils.getTranslatedLabel(
                            context, noSearchFoundTitleLabel),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 28)),
                    const SizedBox(height: 5.0),
                    Text(
                        UiUtils.getTranslatedLabel(
                            context, noSearchFoundSubTitleLabel),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(color: lightFont, fontSize: 14)),
                  ]),
            );
          }
          searchList = (state as SearchSuccess).searchList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.3,
              child: searchText == ""
                  ? const SizedBox()
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: searchList.length,
                      itemBuilder: (BuildContext context, index) {
                        ProductDetails dataItem = searchList[index];
                        double price =
                            double.parse(dataItem.variants![0].specialPrice!);
                        if (price == 0) {
                          price = double.parse(dataItem.variants![0].price!);
                        }
                        double off = 0;
                        if (dataItem.variants![0].specialPrice! != "0") {
                          off = (double.parse(dataItem.variants![0].price!) -
                                  double.parse(
                                      dataItem.variants![0].specialPrice!))
                              .toDouble();
                          off = off *
                              100 /
                              double.parse(dataItem.variants![0].price!)
                                  .toDouble();
                        }
                        return hasMore &&
                                searchList.isEmpty &&
                                index == (searchList.length - 1)
                            ? Center(
                                child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary))
                            : BlocProvider(
                                create: (context) => GetQuantityCubit(),
                                child: ProductContainer(
                                    productDetails: searchList[index],
                                    height: height!,
                                    width: width!,
                                    price: price,
                                    off: off,
                                    productList: searchList,
                                    index: index),
                              );
                      }));
        });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      searchText = lastWords.replaceAll(' ', '');
      print(searchText);
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        setState(() {
          searchController.text = lastWords;
          searchText = lastWords;
          searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: searchController.text.length));
        });
        searchApi();

        Navigator.of(context).pop();
      });
    }
  }

  void startListening() {
    lastWords = '';
    speech.listen(
      onResult: resultListener,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: (val) => print("onError:$val"),
        onStatus: (val) => print('onState: $val'),
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));

    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
      print("_currentLocaleId$_currentLocaleId");
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) bottoSheetVoiceReconization();
  }

  bottoSheetVoiceReconization() {
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater1) {
            setStater = setStater1;
            return Container(
              height: (MediaQuery.of(context).size.height) / 3.0,
              padding: EdgeInsets.only(
                  left: width! / 15.0,
                  right: width! / 15.0,
                  top: height! / 25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    speech.isListening
                        ? Text(
                            UiUtils.getTranslatedLabel(context, listeningLabel),
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold),
                          )
                        : speech.hasRecognized
                            ? Text(
                                UiUtils.getTranslatedLabel(
                                    context, successLabel),
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold),
                              )
                            : speech.hasError
                                ? Text(
                                    UiUtils.getTranslatedLabel(
                                        context, sorryDidnthearthatLabel),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const SizedBox(),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: height! / 30.0),
                      child: GestureDetector(
                          onTap: () {
                            if (!_hasSpeech) {
                              initSpeechState();
                            } else {
                              !_hasSpeech || speech.isListening
                                  ? null
                                  : startListening();
                            }
                          },
                          child: CircleAvatar(
                              radius: 35,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: SvgPicture.asset(
                                  DesignConfig.setSvgPath("voice_search_icon"),
                                  fit: BoxFit.scaleDown))),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 99.0, bottom: height! / 99.0),
                      child: lastWords.isEmpty
                          ? const SizedBox()
                          : Text(
                              lastWords,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.normal),
                            ),
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.only(top: width! / 30),
                      child: Center(
                          child: speech.isListening
                              ? const SizedBox()
                              : Text(
                                  UiUtils.getTranslatedLabel(
                                      context, tapTheMicroPhoneToTryAgainLabel),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontWeight: FontWeight.bold),
                                )),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void errorListener(SpeechRecognitionError error) {
    print("error:${error.errorMsg}");
    if (mounted) {
      setState(() {
        UiUtils.setSnackBar(error.errorMsg, context, false, type: "2");
      });
    }
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
      print("Status...................:$status");
    });
  }

  Widget searchBar() {
    return Container(
        decoration: DesignConfig.boxDecorationContainerBorder(
            textFieldBorder, textFieldBackground, 4.0),
        padding: EdgeInsetsDirectional.only(start: width! / 99.0),
        margin: EdgeInsetsDirectional.only(
            start: width! / 20.0, end: width! / 99.0),
        child: TextField(
          controller: searchController,
          cursorColor: lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsetsDirectional.only(
                start: width! / 40.0, top: 0, bottom: 0, end: width! / 40.0),
            border: InputBorder.none,
            suffixIcon: searchController.text.trim().isEmpty
                ? const SizedBox(height: 10)
                : IconButton(
                    icon: Icon(Icons.cancel,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        searchText = searchController.text;
                        searchList.clear();
                      });
                    },
                  ),
            hintText: UiUtils.getTranslatedLabel(context, searchDishLabel),
            labelStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.76),
                fontSize: 16.0,
                fontWeight: FontWeight.w500),
            hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.76),
                fontSize: 16.0,
                fontWeight: FontWeight.w500),
          ),
          onSubmitted: (value) {
            if (searchProductKeyWordsData.any((element) =>
                element["keyWords"] == value.toString().toLowerCase())) {
            } else {
              if (value.toString() != "") {
                addSearchProductKeyWords({
                  "keyWords": value.toString(),
                });
              }
            }
          },
          keyboardType: TextInputType.text,
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500),
        ));
  }

  searchProductKeyWords() {
    return List.generate(
        // the list of items
        searchProductKeyWordsData.length, (index) {
      final currentItem = searchProductKeyWordsData[index];
      return GestureDetector(
        onTap: () {
          setState(() {
            searchText = currentItem["keyWords"].toString().toLowerCase();
            searchController.text =
                currentItem["keyWords"].toString().toLowerCase();
            searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: searchController.text.length));
          });
          searchApi();
        },
        child: Container(
            padding: EdgeInsetsDirectional.only(
                start: 8.0, end: 8.0, top: 5.0, bottom: 5.0),
            margin: EdgeInsetsDirectional.only(
                end: width! / 40.0,
                bottom: height! / 80.0,
                start: index == 0 ? width! / 20.0 : 0.0),
            decoration: DesignConfig.boxDecorationContainerBorder(
                textFieldBorder,
                Theme.of(context).colorScheme.onSurface,
                100.0),
            child: Text(currentItem['keyWords'].toString(),
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.76),
                    fontWeight: FontWeight.w500))),
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
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
                  UiUtils.getTranslatedLabel(context, searchLabel),
                  PreferredSize(
                    preferredSize: Size(width!, height! / 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                              end: width! / 20.0, bottom: height! / 99.0),
                          child: Row(
                            children: [
                              Expanded(child: searchBar()),
                              GestureDetector(
                                onTap: () async {
                                  final permissionMicrophone =
                                      Permission.microphone;
                                  final status =
                                      await permissionMicrophone.request();
                                  if (status.isGranted) {
                                    if (!_hasSpeech) {
                                      initSpeechState();
                                    } else {
                                      if (!_hasSpeech) {
                                        initSpeechState();
                                      } else {
                                        !_hasSpeech || speech.isListening
                                            ? null
                                            : startListening();
                                      }
                                      bottoSheetVoiceReconization();
                                    }
                                  }
                                  if (status.isPermanentlyDenied) {
                                    openAppSettings();
                                  } else {
                                    permissionMicrophone.request();
                                    print('microphone permission denied.');
                                  }
                                },
                                child: VoiceSearchContainer(
                                    width: width!,
                                    height: height!,
                                    from: "search"),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  preferSize: height! / 6.2),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(
                    Theme.of(context).colorScheme.onSurface),
                width: width,
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      searchProductKeyWordsData.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: searchProductKeyWords()))
                          : const SizedBox.shrink(),
                      Container(
                        child: searchDataList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
