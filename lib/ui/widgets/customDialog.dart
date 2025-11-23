import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/auth/deleteMyAccountCubit.dart';
import 'package:erestroSingleVender/cubit/cart/clearCartCubit.dart';
import 'package:erestroSingleVender/cubit/cart/getCartCubit.dart';
import 'package:erestroSingleVender/cubit/home/cuisine/cuisineCubit.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/repositories/cart/cartRepository.dart';
import 'package:erestroSingleVender/ui/screen/home/menu/menu_view_screen.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/ui/widgets/smallButtomContainer.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDialog extends StatefulWidget {
  final String title, subtitle, from;
  final double? width, height;
  final void Function()? onTap;
  const CustomDialog(
      {Key? key,
      required this.width,
      required this.height,
      required this.title,
      required this.subtitle,
      required this.from,
      this.onTap})
      : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  void initState() {
    super.initState();
    print("onTap:${widget.onTap}");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: DesignConfig.setRounded(16.0),
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.height! / 40.0),
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.onSurface, 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              widget.from == UiUtils.getTranslatedLabel(context, deleteLabel)
                  ? UiUtils.getTranslatedLabel(context, deleteAccountLabel)
                  : widget.from ==
                          UiUtils.getTranslatedLabel(context, clearCartLabel)
                      ? UiUtils.getTranslatedLabel(
                          context, deleteAllItemsTitleLabel)
                      : UiUtils.getTranslatedLabel(context, logoutLabel),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontSize: 14.0),
              textAlign: TextAlign.left),
          Padding(
            padding: EdgeInsetsDirectional.only(
                start: widget.width! / 40.0,
                top: widget.height! / 80.0,
                end: widget.width! / 40.0),
            child: Text(widget.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.76),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                )),
          ),
          SizedBox(
            height: widget.height! / 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SmallButtonContainer(
                  color: Theme.of(context).colorScheme.surface,
                  height: widget.height,
                  width: widget.width,
                  text: UiUtils.getTranslatedLabel(context, cancelLabel),
                  start: widget.width! / 20.0,
                  end: widget.width! / 40.0,
                  bottom: widget.height! / 60.0,
                  top: widget.height! / 99.0,
                  radius: 5.0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.onSurface,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                ),
              ),
              widget.from == UiUtils.getTranslatedLabel(context, logoutLabel)
                  ? Expanded(
                      child: SmallButtonContainer(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        height: widget.height,
                        width: widget.width,
                        text: UiUtils.getTranslatedLabel(context, logoutLabel),
                        start: widget.width! / 40.0,
                        end: widget.width! / 20.0,
                        bottom: widget.height! / 60.0,
                        top: widget.height! / 99.0,
                        radius: 5.0,
                        status: false,
                        borderColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        textColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          clearOffLineCart(context);
                          Navigator.of(context, rootNavigator: true).pop(true);
                          if (context.read<AuthCubit>().getType() == "google") {
                            context
                                .read<AuthCubit>()
                                .signOut(AuthProviders.google);
                          } else {
                            context
                                .read<AuthCubit>()
                                .signOut(AuthProviders.apple);
                          }
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.login, (Route<dynamic> route) => false,
                              arguments: {'from': 'logout'});
                        },
                      ),
                    )
                  : widget.from ==
                          UiUtils.getTranslatedLabel(context, clearCartLabel)
                      ? Expanded(
                          child: BlocProvider<ClearCartCubit>(
                            create: (_) => ClearCartCubit(CartRepository()),
                            child: Builder(builder: (context) {
                              return BlocConsumer<ClearCartCubit,
                                  ClearCartState>(
                                bloc: context.read<ClearCartCubit>(),
                                listener: (context, state) {
                                  if (state is ClearCartSuccess) {
                                    if (context.read<AuthCubit>().state
                                            is AuthInitial ||
                                        context.read<AuthCubit>().state
                                            is Unauthenticated) {
                                    } else {
                                      UiUtils.setSnackBar(
                                          UiUtils.getTranslatedLabel(
                                              context, clearCartLabel),
                                          context,
                                          false,
                                          type: "1");
                                      context
                                          .read<GetCartCubit>()
                                          .clearCartModel();
                                      List.generate(
                                          context
                                              .read<CuisineCubit>()
                                              .cuisineList()
                                              .length,
                                          (index) => globalKey?[index]
                                              .currentState
                                              ?.productApi());
                                      context.read<GetCartCubit>().getCartUser(
                                          branchId: context
                                              .read<SettingsCubit>()
                                              .getSettings()
                                              .branchId);
                                      setState(() {});
                                      Navigator.pop(context);
                                    }
                                  } else if (state is ClearCartFailure) {
                                    if (context.read<AuthCubit>().state
                                            is AuthInitial ||
                                        context.read<AuthCubit>().state
                                            is Unauthenticated) {
                                    } else {
                                      UiUtils.setSnackBar(
                                          state.errorMessage, context, false,
                                          type: "2");
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  return SmallButtonContainer(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.10),
                                    height: widget.height,
                                    width: widget.width,
                                    text: UiUtils.getTranslatedLabel(
                                        context, deleteAllLabel),
                                    start: widget.width! / 40.0,
                                    end: widget.width! / 20.0,
                                    bottom: widget.height! / 60.0,
                                    top: widget.height! / 99.0,
                                    radius: 5.0,
                                    status: false,
                                    borderColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.10),
                                    textColor:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: widget.onTap != null
                                        ? () => widget.onTap!()
                                        : () {
                                            context
                                                .read<ClearCartCubit>()
                                                .clearCart(
                                                    branchId: context
                                                        .read<SettingsCubit>()
                                                        .getSettings()
                                                        .branchId);
                                          },
                                  );
                                },
                              );
                            }),
                          ),
                        )
                      : Expanded(
                          child: BlocConsumer<DeleteMyAccountCubit,
                                  DeleteMyAccountState>(
                              bloc: context.read<DeleteMyAccountCubit>(),
                              listener: (context, state) {
                                if (state is DeleteMyAccountFailure) {
                                  Center(
                                      child: SizedBox(
                                    width: widget.width! / 2,
                                    child: Text(state.errorMessage.toString(),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis)),
                                  ));
                                }
                                if (state is DeleteMyAccountSuccess) {
                                  clearOffLineCart(context);
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(true);
                                  if (context.read<AuthCubit>().getType() ==
                                      "google") {
                                    context
                                        .read<AuthCubit>()
                                        .signOut(AuthProviders.google);
                                  } else {
                                    context
                                        .read<AuthCubit>()
                                        .signOut(AuthProviders.apple);
                                  }
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.login,
                                      (Route<dynamic> route) => false,
                                      arguments: {'from': 'delete'});
                                }
                              },
                              builder: (context, state) {
                                return SmallButtonContainer(
                                    color: Theme.of(context).colorScheme.error,
                                    height: widget.height,
                                    width: widget.width,
                                    text: UiUtils.getTranslatedLabel(
                                        context, deleteLabel),
                                    start: widget.width! / 40.0,
                                    end: widget.width! / 20.0,
                                    bottom: widget.height! / 60.0,
                                    top: widget.height! / 99.0,
                                    radius: 5.0,
                                    status: false,
                                    borderColor:
                                        Theme.of(context).colorScheme.error,
                                    textColor: white,
                                    onTap: () async {
                                      if (context
                                              .read<SystemConfigCubit>()
                                              .getAuthenticationMethod() ==
                                          "0") {
                                        User? currentUser =
                                            FirebaseAuth.instance.currentUser;
                                        print("currentUser is:$currentUser");
                                        if (currentUser != null) {
                                          try {
                                            await currentUser
                                                .delete()
                                                .then((value) async {
                                              context
                                                  .read<DeleteMyAccountCubit>()
                                                  .deleteMyAccount();
                                            }).catchError((err) {
                                              print(
                                                  'Error: $err'); // Prints 401.
                                            }, test: (error) {
                                              return error is int &&
                                                  error >= 400;
                                            });
                                          } on FirebaseAuthException catch (error) {
                                            if (error.code ==
                                                "requires-recent-login") {
                                              for (int i = 0;
                                                  i <
                                                      AuthProviders
                                                          .values.length;
                                                  i++) {
                                                // ignore: sdk_version_since
                                                if (AuthProviders
                                                        .values[i].name ==
                                                    context
                                                        .read<AuthCubit>()
                                                        .getType()) {
                                                  clearOffLineCart(context);
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop(true);
                                                  if (context
                                                          .read<AuthCubit>()
                                                          .getType() ==
                                                      "google") {
                                                    context
                                                        .read<AuthCubit>()
                                                        .signOut(AuthProviders
                                                            .google);
                                                  } else {
                                                    context
                                                        .read<AuthCubit>()
                                                        .signOut(AuthProviders
                                                            .apple);
                                                  }
                                                  Navigator.of(context)
                                                      .pushNamedAndRemoveUntil(
                                                          Routes.login,
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false,
                                                          arguments: {
                                                        'from': 'delete'
                                                      });
                                                }
                                              }
                                            } else {
                                              UiUtils.setSnackBar(
                                                  error.message!,
                                                  context,
                                                  false,
                                                  type: "2");
                                            }
                                          } catch (e) {
                                            debugPrint(
                                                'unable to delete user - ${e.toString()}');
                                          }
                                        } else {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(true);
                                          UiUtils.setSnackBar(
                                              StringsRes.messageReLogin,
                                              context,
                                              false,
                                              type: "2");
                                        }
                                      } else {
                                        context
                                            .read<DeleteMyAccountCubit>()
                                            .deleteMyAccount();
                                      }
                                    });
                              }),
                        )
            ],
          ),
        ],
      ),
    );
  }
}
