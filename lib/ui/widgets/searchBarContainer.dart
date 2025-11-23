import 'dart:async';

import 'package:erestroSingleVender/cubit/home/cuisine/cuisineCubit.dart';
import 'package:erestroSingleVender/data/model/cuisineModel.dart';
import 'package:erestroSingleVender/ui/styles/color.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBarContainer extends StatefulWidget {
  final double? width, height;
  final String? title;
  const SearchBarContainer({Key? key, this.width, this.height, this.title})
      : super(key: key);

  @override
  State<SearchBarContainer> createState() => _SearchBarContainerState();
}

class _SearchBarContainerState extends State<SearchBarContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2500));

  late final Animation<double> _bottomToCenterTextAnimation =
      Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.25)));

  late final Animation<double> _centerToTopTextAnimation =
      Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _animationController, curve: const Interval(0.75, 1.0)));

  late int counter = 0, index = 0;

  late Timer? _timer;
  String? dishName = "";
  List<CuisineModel> cuisineList = [];

  @override
  void initState() {
    super.initState();
    cuisineList = context.read<CuisineCubit>().cuisineList();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      setState(() {
        counter++;
        if (index < cuisineList.length - 1) {
          index++;
        } else {
          index = 0;
        }
      });
      _animationController.forward(from: 0.0);
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CuisineCubit, CuisineState>(
      listener: (context, state) {
        if (state is CuisineInitial || state is CuisineProgress) {
          cuisineList = [];
        } else if (state is CuisineSuccess) {
          cuisineList = state.cuisineList;
        } else if (state is CuisineFailure) {
          cuisineList = [];
        }
      },
      child: AnimatedBuilder(
          animation: _bottomToCenterTextAnimation,
          builder: (context, child) {
            final dy = _bottomToCenterTextAnimation.value -
                _centerToTopTextAnimation.value;

            final opacity = (1 -
                _bottomToCenterTextAnimation.value -
                _centerToTopTextAnimation.value);

            return Container(
                height: widget.height! / 20.0,
                alignment: Alignment(-1.0, dy),
                decoration: DesignConfig.boxDecorationContainerBorder(
                    textFieldBorder, textFieldBackground, 4.0),
                padding:
                    EdgeInsetsDirectional.only(start: widget.width! / 35.0),
                child: Opacity(
                    opacity: opacity,
                    child: RichText(
                      text: TextSpan(
                        text: cuisineList.isNotEmpty
                            ? UiUtils.getTranslatedLabel(context, searchLabel)
                            : widget.title!,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.76),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Quicksand'),
                        children: [
                          TextSpan(
                              text:
                                  " ${cuisineList.isNotEmpty ? cuisineList[index].name : ""}",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.76),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Quicksand')),
                        ],
                      ),
                    )));
          }),
    );
  }
}
