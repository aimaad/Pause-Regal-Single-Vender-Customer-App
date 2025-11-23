import 'dart:io';

import 'package:erestroSingleVender/data/model/rattingModel.dart';
import 'package:erestroSingleVender/ui/screen/rating/product_rating_screen.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RatingConatiner extends StatefulWidget {
  final int index;
  final double? width, height;
  final String? productId;
  const RatingConatiner(
      {Key? key, required this.index, this.width, this.height, this.productId})
      : super(key: key);

  @override
  RatingConatinerState createState() => RatingConatinerState();
}

class RatingConatinerState extends State<RatingConatiner> {
  final TextEditingController commentController = TextEditingController();
  bool isDataAvailable = false;
  int? selectedIndex = 4;
  List<File> reviewPhotos = [];
  List<RatingModel> ratingList = [];
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(microseconds: 1000), () {
      ratingData();
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (commentList.isNotEmpty) {
        commentController.text = commentList[widget.index]['comment'] ?? '';
      }
    });
  }

  ratingData() {
    ratingList = [
      RatingModel(
          id: 1,
          title: UiUtils.getTranslatedLabel(context, terribleLabel),
          image: "terrible_inactive",
          rating: "1.0",
          status: "0",
          imageActive: "terrible_active"),
      RatingModel(
          id: 2,
          title: UiUtils.getTranslatedLabel(context, badLabel),
          image: "bad_inactive",
          rating: "2.0",
          status: "0",
          imageActive: "bad_active"),
      RatingModel(
          id: 3,
          title: UiUtils.getTranslatedLabel(context, okayLabel),
          image: "okay_inactive",
          rating: "3.0",
          status: "0",
          imageActive: "okay_active"),
      RatingModel(
          id: 4,
          title: UiUtils.getTranslatedLabel(context, goodLabel),
          image: "good_inactive",
          rating: "4.0",
          status: "0",
          imageActive: "good_active"),
      RatingModel(
          id: 5,
          title: UiUtils.getTranslatedLabel(context, greatLabel),
          image: "great_inactive",
          rating: "5.0",
          status: "1",
          imageActive: "great_active"),
    ];
    setState(() {});
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Widget getImageField() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(top: 5),
        margin: EdgeInsetsDirectional.only(top: widget.height! / 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
                onTap: () {
                  _reviewImgFromGallery(setModalState);
                },
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("add_photo"),
                              fit: BoxFit.scaleDown,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.secondary,
                                  BlendMode.srcIn),
                              width: 18.0,
                              height: 18.0),
                          SizedBox(width: widget.width! / 80.0),
                          Text(
                              UiUtils.getTranslatedLabel(
                                  context, addPhotosLabel),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600))
                        ]))),
            reviewPhotos.isEmpty
                ? const SizedBox.shrink()
                : Container(
                    alignment: Alignment.topLeft,
                    height: widget.height! / 10.0,
                    margin:
                        EdgeInsetsDirectional.only(top: widget.height! / 60.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: reviewPhotos.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        return InkWell(
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                    end: widget.width! / 40.0),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  child: Image.file(
                                    reviewPhotos[i],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.directional(
                                  end: 15.0,
                                  top: 5.0,
                                  textDirection: Directionality.of(context),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary),
                                      padding:
                                          const EdgeInsetsDirectional.all(5.0),
                                      child: Icon(Icons.delete,
                                          size: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface)))
                            ],
                          ),
                          onTap: () {
                            if (mounted) {
                              setModalState(() {
                                reviewPhotos.removeAt(i);
                              });
                            }
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      );
    });
  }

  void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
      commentList[widget.index]['images'] = reviewPhotos;
    } else {
      // User canceled the picker
    }
  }

  Widget rating() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(ratingList.length, (m) {
          return Padding(
            padding: EdgeInsetsDirectional.only(top: widget.height! / 80.0),
            child: InkWell(
                splashFactory: NoSplash.splashFactory,
                onTap: () {
                  if (selectedIndex == m) {
                    setState(() {
                      ratingList[m].status = "0";
                      selectedIndex = 4;
                    });
                  } else {
                    setState(() {
                      ratingList[m].status = "1";
                      selectedIndex = m;
                    });
                    commentList[widget.index]['rating'] = ratingList[m].rating;
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                        DesignConfig.setSvgPath(selectedIndex == m
                            ? ratingList[m].imageActive!
                            : ratingList[m].image!),
                        height: selectedIndex == m ? 40.0 : 40),
                    SizedBox(height: widget.height! / 99.0),
                    ratingList.isEmpty
                        ? const SizedBox.shrink()
                        : Text(ratingList[m].title.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selectedIndex == m
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.66),
                                fontSize: 12,
                                fontWeight: FontWeight.w600))
                  ],
                )),
          );
        }));
  }

  Widget comment() {
    return Container(
      padding: EdgeInsetsDirectional.only(end: widget.width! / 99.0),
      margin: EdgeInsetsDirectional.only(top: widget.height! / 40.0),
      child: TextField(
        controller: commentController,
        cursorColor:
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        decoration: DesignConfig.inputDecorationextField(
            UiUtils.getTranslatedLabel(context, writeCommentLabel),
            UiUtils.getTranslatedLabel(context, writeCommentLabel),
            widget.width!,
            context),
        onChanged: (v) => commentList[widget.index]['comment'] = v,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        rating(),
        comment(),
        getImageField(),
        Padding(
          padding: EdgeInsetsDirectional.only(
              top: widget.height! / 40.0, bottom: widget.height! / 80.0),
          child: DesignConfig.divider(),
        ),
      ],
    );
  }
}
