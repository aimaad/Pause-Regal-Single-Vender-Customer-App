import 'dart:io';
import 'package:erestroSingleVender/app/appLocalization.dart';
import 'package:erestroSingleVender/cubit/address/getLocationDetailCubit.dart';
import 'package:erestroSingleVender/cubit/address/isOrderDeliverableCubit.dart';
import 'package:erestroSingleVender/cubit/address/searchLocationCubit.dart';
import 'package:erestroSingleVender/cubit/auth/resendOtpCubit.dart';
import 'package:erestroSingleVender/cubit/auth/socialSignUpCubit.dart';
import 'package:erestroSingleVender/cubit/auth/verifyOtpCubit.dart';
import 'package:erestroSingleVender/cubit/auth/verifyUserCubit.dart';
import 'package:erestroSingleVender/cubit/branch/branchCubit.dart';
import 'package:erestroSingleVender/cubit/helpAndSupport/ticketCubit.dart';
import 'package:erestroSingleVender/cubit/home/sections/sectionsDetailCubit.dart';
import 'package:erestroSingleVender/cubit/localization/appLocalizationCubit.dart';
import 'package:erestroSingleVender/cubit/notificatiion/notificationCubit.dart';
import 'package:erestroSingleVender/cubit/order/activeOrderCubit.dart';
import 'package:erestroSingleVender/cubit/order/historyOrderCubit.dart';
import 'package:erestroSingleVender/cubit/order/orderAgainCubit.dart';
import 'package:erestroSingleVender/cubit/order/orderDetailCubit.dart';
import 'package:erestroSingleVender/cubit/order/reOrderCubit.dart';
import 'package:erestroSingleVender/cubit/product/getOfflineCartCubit.dart';
import 'package:erestroSingleVender/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:erestroSingleVender/cubit/transaction/transactionCubit.dart';
import 'package:erestroSingleVender/data/repositories/address/addressRepository.dart';
import 'package:erestroSingleVender/cubit/address/addAddressCubit.dart';
import 'package:erestroSingleVender/cubit/address/addressCubit.dart';
import 'package:erestroSingleVender/cubit/address/cityDeliverableCubit.dart';
import 'package:erestroSingleVender/cubit/address/deliveryChargeCubit.dart';
import 'package:erestroSingleVender/cubit/address/updateAddressCubit.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/auth/deleteMyAccountCubit.dart';
import 'package:erestroSingleVender/cubit/auth/referAndEarnCubit.dart';
import 'package:erestroSingleVender/cubit/auth/signInCubit.dart';
import 'package:erestroSingleVender/cubit/auth/signUpCubit.dart';
import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:erestroSingleVender/cubit/cart/clearCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/manageCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/placeOrder.dart';
import 'package:erestroSingleVender/cubit/cart/removeFromCartCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/favouriteProductsCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/updateFavouriteProduct.dart';
import 'package:erestroSingleVender/data/repositories/home/bestOffer/bestOfferRepository.dart';
import 'package:erestroSingleVender/cubit/home/bestOffer/bestOfferCubit.dart';
import 'package:erestroSingleVender/cubit/home/cuisine/cuisineCubit.dart';
import 'package:erestroSingleVender/cubit/product/productCubit.dart';
import 'package:erestroSingleVender/cubit/product/topRatedProductCubit.dart';
import 'package:erestroSingleVender/cubit/home/search/searchCubit.dart';
import 'package:erestroSingleVender/cubit/home/sections/sectionsCubit.dart';
import 'package:erestroSingleVender/cubit/home/slider/sliderOfferCubit.dart';
import 'package:erestroSingleVender/data/repositories/home/slider/sliderRepository.dart';
import 'package:erestroSingleVender/cubit/order/orderCubit.dart';
import 'package:erestroSingleVender/cubit/order/updateOrderStatusCubit.dart';
import 'package:erestroSingleVender/cubit/order/orderLiveTrackingCubit.dart';
import 'package:erestroSingleVender/data/repositories/order/orderRepository.dart';
import 'package:erestroSingleVender/cubit/payment/GetWithdrawRequestCubit.dart';
import 'package:erestroSingleVender/cubit/payment/sendWithdrawRequestCubit.dart';
import 'package:erestroSingleVender/cubit/product/offlineCartCubit.dart';
import 'package:erestroSingleVender/data/repositories/payment/paymentRepository.dart';
import 'package:erestroSingleVender/data/repositories/product/productRepository.dart';
import 'package:erestroSingleVender/cubit/promoCode/promoCodeCubit.dart';
import 'package:erestroSingleVender/cubit/promoCode/validatePromoCodeCubit.dart';
import 'package:erestroSingleVender/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:erestroSingleVender/data/repositories/promoCode/promoCodeRepository.dart';
import 'package:erestroSingleVender/cubit/rating/setRiderRatingCubit.dart';
import 'package:erestroSingleVender/data/repositories/rating/ratingRepository.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/repositories/settings/settingsRepository.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/repositories/systemConfig/systemConfigRepository.dart';
import 'package:erestroSingleVender/firebase_options.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/utils/appLanguages.dart';
import 'package:erestroSingleVender/utils/hiveBoxKey.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/data/repositories/auth/authRepository.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  HttpOverrides.global = MyHttpOverrides();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));
    initializedDownload();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {}
  }

  await Hive.initFlutter();
  await Hive.openBox(
      authBox); //auth box for storing all authentication related details
  await Hive.openBox(
      settingsBox); //settings box for storing all settings details
  await Hive.openBox(
      userdetailsBox); //userDetails box for storing all userDetails details
  await Hive.openBox(addressBox); //address box for storing all address details
  await Hive.openBox(
      searchAddressBox); //searchAddress box for storing all searchAddress details
  await Hive.openBox(
      placeSearchAddressBox); //placeSearchAddress box for storing all placeSearchAddress details
  await Hive.openBox(
      searchProductKeyWordsBox); //searchAddress box for storing all searchAddress details

  return const MyApp();
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //providing global providers
      providers: [
        //Creating cubit/bloc that will be use in whole app or
        //will be use in multiple screens
        BlocProvider<AppLocalizationCubit>(
            create: (_) => AppLocalizationCubit(SettingsRepository())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<SignUpCubit>(create: (_) => SignUpCubit(AuthRepository())),
        BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository())),
        BlocProvider<SignInCubit>(create: (_) => SignInCubit(AuthRepository())),
        BlocProvider<SocialSignUpCubit>(
            create: (_) => SocialSignUpCubit(AuthRepository())),
        BlocProvider<ProductCubit>(create: (_) => ProductCubit()),
        BlocProvider<BranchCubit>(create: (_) => BranchCubit()),
        BlocProvider<TopRatedProductCubit>(
            create: (_) => TopRatedProductCubit()),
        BlocProvider<CuisineCubit>(create: (_) => CuisineCubit()),
        BlocProvider<BestOfferCubit>(
            create: (_) => BestOfferCubit(BestOfferRepository())),
        BlocProvider<SliderCubit>(
            create: (_) => SliderCubit(SliderRepository())),
        BlocProvider<SectionsCubit>(create: (_) => SectionsCubit()),
        BlocProvider<SectionsDetailCubit>(create: (_) => SectionsDetailCubit()),
        BlocProvider<AddressCubit>(
            create: (_) => AddressCubit(AddressRepository())),
        BlocProvider<AddAddressCubit>(
            create: (_) => AddAddressCubit(AddressRepository())),
        BlocProvider<CityDeliverableCubit>(
            create: (_) => CityDeliverableCubit(AddressRepository())),
        BlocProvider<IsOrderDeliverableCubit>(
            create: (_) => IsOrderDeliverableCubit(AddressRepository())),
        BlocProvider<PromoCodeCubit>(create: (_) => PromoCodeCubit()),
        BlocProvider<ValidatePromoCodeCubit>(
            create: (_) => ValidatePromoCodeCubit(PromoCodeRepository())),
        BlocProvider<GetCartCubit>(
            create: (_) => GetCartCubit(CartRepository())),
        BlocProvider<ManageCartCubit>(
            create: (_) => ManageCartCubit(CartRepository())),
        BlocProvider<RemoveFromCartCubit>(
            create: (_) => RemoveFromCartCubit(CartRepository())),
        BlocProvider<OrderCubit>(create: (_) => OrderCubit()),
        BlocProvider<OrderAgainCubit>(create: (_) => OrderAgainCubit()),
        BlocProvider<PlaceOrderCubit>(
            create: (_) => PlaceOrderCubit(CartRepository())),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit()),
        BlocProvider<SystemConfigCubit>(
            create: (_) => SystemConfigCubit(SystemConfigRepository())),
        BlocProvider<UpdateOrderStatusCubit>(
            create: (_) => UpdateOrderStatusCubit(OrderRepository())),
        BlocProvider<OrderLiveTrackingCubit>(
            create: (_) => OrderLiveTrackingCubit(OrderRepository())),
        BlocProvider<UpdateAddressCubit>(
            create: (_) => UpdateAddressCubit(AddressRepository())),
        BlocProvider<DeliveryChargeCubit>(
            create: (_) => DeliveryChargeCubit(AddressRepository())),
        BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(SettingsRepository())),
        BlocProvider<SetRiderRatingCubit>(
            create: (_) => SetRiderRatingCubit(RatingRepository())),
        BlocProvider<FavoriteProductsCubit>(
            create: (_) => FavoriteProductsCubit()),
        BlocProvider<UpdateProductFavoriteStatusCubit>(
            create: (_) => UpdateProductFavoriteStatusCubit()),
        BlocProvider<DeleteMyAccountCubit>(
            create: (_) => DeleteMyAccountCubit(AuthRepository())),
        BlocProvider<ClearCartCubit>(
            create: (_) => ClearCartCubit(CartRepository())),
        BlocProvider<OfflineCartCubit>(
            create: (_) => OfflineCartCubit(ProductRepository())),
        BlocProvider<SendWithdrawRequestCubit>(
            create: (_) => SendWithdrawRequestCubit(PaymentRepository())),
        BlocProvider<GetWithdrawRequestCubit>(
            create: (_) => GetWithdrawRequestCubit()),
        BlocProvider<TicketCubit>(create: (_) => TicketCubit()),
        BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit(),
        ),
        BlocProvider<ActiveOrderCubit>(create: (_) => ActiveOrderCubit()),
        BlocProvider<HistoryOrderCubit>(create: (_) => HistoryOrderCubit()),
        BlocProvider<ReOrderCubit>(
            create: (_) => ReOrderCubit(OrderRepository())),
        BlocProvider<UpdateUserDetailCubit>(
            create: (_) =>
                UpdateUserDetailCubit(ProfileManagementRepository())),
        BlocProvider<TransactionCubit>(create: (_) => TransactionCubit()),
        BlocProvider<VerifyUserCubit>(
            create: (_) => VerifyUserCubit(AuthRepository())),
        BlocProvider<VerifyOtpCubit>(
            create: (_) => VerifyOtpCubit(AuthRepository())),
        BlocProvider<ResendOtpCubit>(
            create: (_) => ResendOtpCubit(AuthRepository())),
        BlocProvider<GetOfflineCartCubit>(create: (_) => GetOfflineCartCubit()),
        BlocProvider<OrderDetailCubit>(create: (_) => OrderDetailCubit()),
        BlocProvider<SearchLocationCubit>(
          create: (_) => SearchLocationCubit(
            AddressRepository(),
          ),
        ),
        BlocProvider<GetLoactionDetailCubit>(
          create: (_) => GetLoactionDetailCubit(
            AddressRepository(),
          ),
        )
      ],
      child: Builder(
        builder: (context) {
          final currentLanguage =
              context.watch<AppLocalizationCubit>().state.language;
          return MaterialApp(
            navigatorKey: navigatorKey,
            builder: (context, widget) {
              return ScrollConfiguration(
                  behavior: GlobalScrollBehavior(), child: widget!);
            },
            theme: ThemeData(
                useMaterial3: false,
                scaffoldBackgroundColor: onBackgroundColor,
                fontFamily: 'Quicksand',
                iconTheme: const IconThemeData(
                  color: black,
                ),
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryColor,
                      secondary: secondaryColor,
                      surface: backgroundColor,
                      error: errorColor,
                      onPrimary: onPrimaryColor,
                      onSecondary: onSecondaryColor,
                      onSurface: onBackgroundColor,
                    )),
            locale: currentLanguage,
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((appLanguage) {
              return UiUtils.getLocaleFromLanguageCode(
                  appLanguage.languageCode);
            }).toList(),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
