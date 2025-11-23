import 'dart:io';
import 'dart:math';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/data/localDataStore/authLocalDataSource.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/apiMessageAndCodeException.dart';
import 'package:erestroSingleVender/utils/apiMessageException.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRemoteDataSource {
  int count = 1;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

//to addUser
  Future<dynamic> addUser(
      {String? name,
      String? email,
      String? mobile,
      String? countryCode,
      String? fcmId,
      String? friendCode,
      String? referCode}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        nameKey: name,
        emailKey: email,
        mobileKey: mobile,
        countryCodeKey: countryCode ?? "",
        referralCodeKey: referCode ?? "",
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? "",
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.registerUserUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to addUser
  Future<dynamic> socialLogIn(
      {String? name,
      String? email,
      String? mobile,
      String? countryCode,
      String? fcmId,
      String? friendCode,
      String? referCode,
      String? type}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        nameKey: name!.trim() == "" ? "User" : name,
        emailKey: email,
        mobileKey: mobile,
        countryCodeKey: countryCode ?? "",
        referralCodeKey: referCode ?? "",
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? "",
        typeKey: type ?? "",
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.signUpUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  final chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  //to referEarn
  Future referEarn(String? referCode) async {
    try {
      //body of post request
      final body = {referralCodeKey: referCode};
      final result = await Api.post(
          body: body,
          url: Api.validateReferCodeUrl,
          token: false,
          errorCode: false);
      if (!result[errorKey]) {
        referCode = referCode;
      } else {
        if (count < 5) referEarn(referCode);
        count++;
      }

      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to loginUser
  Future<dynamic> signInUser({String? mobile}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        mobileKey: mobile,
        fcmIdKey: fcmToken,
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.loginUrl, token: false, errorCode: false);
      if (result[errorKey] == true) {
        throw ApiMessageException(errorMessage: result[messageKey]);
      }
      AuthLocalDataSource.setJwtTocken(result['token']);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isUserExist(String mobile) async {
    try {
      final body = {mobileKey: mobile, isForgotPasswordKey: "0"};
      final result = await Api.post(
          body: body, url: Api.verifyUserUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to verify otp user's exist
  Future<bool> isVerifyOtp(String mobile, String otp) async {
    try {
      final body = {mobileKey: mobile, otpKey: otp};
      final result = await Api.post(
          body: body, url: Api.verifyOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isResendOtp(String mobile) async {
    try {
      final body = {mobileKey: mobile};
      final result = await Api.post(
          body: body, url: Api.resendOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to delete my account
  Future<bool> deleteMyAccount() async {
    try {
      final body = {};
      final result = await Api.post(
          body: body,
          url: Api.deleteMyAccountUrl,
          token: true,
          errorCode: true);
      if (result[errorKey]) {
        //if user does not exist means
        if (result['message'] == tockenExpireCode) {
          return false;
        }
        throw ApiMessageAndCodeException(
            errorMessage: result[messageKey],
            errorStatusCode: result[statusCodeKey].toString());
      }
      return true;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to update fcmId of user's
  Future<dynamic> updateFcmId({String? fcmId}) async {
    try {
      //body of post request
      final body = {
        fcmIdKey: fcmId,
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.updateFcmUrl, token: true, errorCode: false);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  //SignIn user will accept AuthProvider (enum)
  Future<Map<String, dynamic>> socialSignInUser(
      AuthProviders authProvider) async {
    //user creadential contains information of signin user and is user new or not
    Map<String, dynamic> result = {};

    try {
      if (authProvider == AuthProviders.google) {
        UserCredential userCredential = await signInWithGoogle();

        result['user'] = userCredential.user!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      } else if (authProvider == AuthProviders.phone) {
      } else if (authProvider == AuthProviders.apple) {
        UserCredential userCredential = await signInWithApple();
        result['user'] = _firebaseAuth.currentUser!;
        result['isNewUser'] = userCredential.additionalUserInfo!.isNewUser;
      }
      return result;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    }
    //firebase auht errors
    on FirebaseAuthException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //signIn using google account
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw ApiMessageException(errorMessage: defaultErrorMessage);
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        final user = userCredential.user!;
        final String givenName = appleCredential.givenName ?? "";
        final String familyName = appleCredential.familyName ?? "";

        await user.updateDisplayName("$givenName $familyName");
        await user.reload();
      }

      return userCredential;
    } catch (error) {
      throw ApiMessageException(errorMessage: error.toString());
    }
  }

  Future<void> signOut(AuthProviders? authProvider) async {
    _firebaseAuth.signOut();
    if (authProvider == AuthProviders.google) {
      _googleSignIn.signOut();
    } else if (AuthProviders.apple == AuthProviders.apple) {}
  }
}
