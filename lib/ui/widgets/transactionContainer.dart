import 'package:erestroSingleVender/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestroSingleVender/data/model/transactionModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class TransactionContainer extends StatelessWidget {
  final TransactionModel transactionModel;
  final double? width, height;
  final int? index;
  const TransactionContainer(
      {Key? key,
      required this.transactionModel,
      this.width,
      this.height,
      this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return Container(
      padding: EdgeInsetsDirectional.only(
          start: width! / 25.0,
          top: height! / 80.0,
          end: width! / 25.0,
          bottom: height! / 80.0),
      width: width!,
      margin:
          EdgeInsetsDirectional.only(top: index == 0 ? 0.0 : height! / 52.0),
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.onSurface, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: width! / 60.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          UiUtils.getTranslatedLabel(context, idLabel)
                              .toUpperCase(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0)),
                      Text(" #${transactionModel.id!}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.0)),
                    ],
                  ),
                  transactionModel.status == ""
                      ? const SizedBox()
                      : Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsetsDirectional.only(
                                top: 5.0, bottom: 5.0, start: 5.0, end: 5.0),
                            margin:
                                const EdgeInsetsDirectional.only(start: 4.5),
                            decoration:
                                DesignConfig.boxDecorationContainerBorder(
                                    DesignConfig.walletStatusCartColor(
                                        transactionModel.status!.toLowerCase()),
                                    DesignConfig.walletStatusCartColor(
                                            transactionModel.status!
                                                .toLowerCase())
                                        .withValues(alpha: 0.10),
                                    4.0),
                            child: Text(
                              transactionModel.status!,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: DesignConfig.walletStatusCartColor(
                                      transactionModel.status!.toLowerCase())),
                            ),
                          ),
                        ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    top: height! / 80.0, bottom: height! / 80.0),
                child: DesignConfig.divider(),
              ),
              Text("${UiUtils.getTranslatedLabel(context, dateLabel)}",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0)),
              Text(
                  formatter.format(
                      DateTime.parse(transactionModel.transactionDate!)),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0)),
              SizedBox(height: height! / 60.0),
              Text("${UiUtils.getTranslatedLabel(context, typeLabel)}",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0)),
              Text(transactionModel.type!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0),
                  maxLines: 2),
              SizedBox(height: height! / 60.0),
              Text("${UiUtils.getTranslatedLabel(context, messageLabel)}",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0)),
              SizedBox(
                  width: width! / 1.1,
                  child: Text(transactionModel.message!,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.76),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    top: height! / 80.0, bottom: height! / 80.0),
                child: DesignConfig.divider(),
              ),
              Row(children: [
                SvgPicture.asset(DesignConfig.setSvgPath("amout_icon"),
                    fit: BoxFit.scaleDown,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onPrimary,
                        BlendMode.srcIn),
                    width: 7.0,
                    height: 12.3),
                SizedBox(width: width! / 80.0),
                Text("${UiUtils.getTranslatedLabel(context, amountLabel)}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0)),
                const Spacer(),
                Text(
                    "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(transactionModel.amount!).toStringAsFixed(2)}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0)),
              ]),
            ]),
      ),
    );
  }
}
