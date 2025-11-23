import 'package:erestroSingleVender/app/routes.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/favouriteProductsCubit.dart';
import 'package:erestroSingleVender/cubit/favourite/updateFavouriteProduct.dart';
import 'package:erestroSingleVender/cubit/settings/settingsCubit.dart';
import 'package:erestroSingleVender/data/model/sectionsModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoriteContainer extends StatefulWidget {
  final ProductDetails? productDetails;
  final String? from;
  const FavoriteContainer({Key? key, this.productDetails, this.from});

  @override
  State<FavoriteContainer> createState() => _FavoriteContainerState();
}

class _FavoriteContainerState extends State<FavoriteContainer> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
          bloc: context.read<FavoriteProductsCubit>(),
          builder: (context, favoriteProductState) {
            if (favoriteProductState is FavoriteProductsFetchSuccess) {
              //check if restaurant is favorite or not
              bool isProductFavorite = context
                  .read<FavoriteProductsCubit>()
                  .isProductFavorite(widget.productDetails!.id!);
              return BlocConsumer<UpdateProductFavoriteStatusCubit,
                  UpdateProductFavoriteStatusState>(
                bloc: context.read<UpdateProductFavoriteStatusCubit>(),
                listener: ((context, state) {
                  if (state is UpdateProductFavoriteStatusSuccess) {
                    if (state.wasFavoriteProductProcess) {
                      context
                          .read<FavoriteProductsCubit>()
                          .addFavoriteProduct(state.product);
                    } else {
                      context
                          .read<FavoriteProductsCubit>()
                          .removeFavoriteProduct(state.product);
                    }
                  }
                }),
                builder: (context, state) {
                  if (state is UpdateProductFavoriteStatusInProgress) {
                    return SizedBox(
                      width: 20.0,
                      height: 20,
                      child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.error)),
                    );
                  }
                  return InkWell(
                      onTap: () {
                        HapticFeedback.vibrate();
                        if (state is UpdateProductFavoriteStatusInProgress) {
                          return;
                        }
                        if (isProductFavorite) {
                          context
                              .read<UpdateProductFavoriteStatusCubit>()
                              .unFavoriteProduct(
                                  type: productsKey,
                                  product: widget.productDetails!,
                                  branchId: context
                                      .read<SettingsCubit>()
                                      .getSettings()
                                      .branchId);
                        } else {
                          context
                              .read<UpdateProductFavoriteStatusCubit>()
                              .favoriteProduct(
                                  type: productsKey,
                                  product: widget.productDetails!,
                                  branchId: context
                                      .read<SettingsCubit>()
                                      .getSettings()
                                      .branchId);
                        }
                      },
                      child: isProductFavorite
                          ? Container(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                  DesignConfig.setSvgPath("wishlist-filled"),
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.error,
                                      BlendMode.srcIn),
                                  width: 20.0,
                                  height: 20))
                          : Container(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                  DesignConfig.setSvgPath("wishlist"),
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).colorScheme.onPrimary,
                                      BlendMode.srcIn),
                                  width: 20.0,
                                  height: 20)));
                },
              );
            }
            //if some how failed to fetch favorite products or still fetching the products
            return InkWell(
                onTap: () {
                  HapticFeedback.vibrate();
                  if (context.read<AuthCubit>().state is AuthInitial ||
                      context.read<AuthCubit>().state is Unauthenticated) {
                    Navigator.of(context).pushNamed(Routes.login,
                        arguments: {'from': 'product'}).then((value) {
                      appDataRefresh(context);
                    });
                    return;
                  }
                },
                child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(DesignConfig.setSvgPath("wishlist"),
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn),
                        width: 20.0,
                        height: 20)));
          });
    });
  }
}
