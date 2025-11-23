import 'package:flutter/material.dart';

class SmallButtonContainer extends StatefulWidget {
  final double? width, height, start, end, top, bottom, radius;
  final String? text;
  final VoidCallback? onTap;
  final Color? color, borderColor, textColor;
  final bool? status;
  final Widget? icon;
  const SmallButtonContainer(
      {Key? key,
      this.width,
      this.height,
      this.text,
      this.onTap,
      this.color,
      this.start,
      this.end,
      this.top,
      this.bottom,
      this.status,
      this.borderColor,
      this.textColor,
      this.radius,
      this.icon = const SizedBox.shrink()})
      : super(key: key);

  @override
  State<SmallButtonContainer> createState() => _SmallButtonContainerState();
}

class _SmallButtonContainerState extends State<SmallButtonContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          start: widget.start!,
          end: widget.end!,
          top: widget.top!,
          bottom: widget.bottom!),
      child: SizedBox(
        height: widget.height! / 25,
        width: widget.width! / 3.6,
        child: TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(
                widget.textColor!.withValues(alpha: 0.10)),
            backgroundColor: WidgetStateProperty.all(widget.color),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: widget.borderColor!)),
            ),
          ),
          onPressed: widget.onTap,
          child: widget.status == true
              ? CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onSurface)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.text!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: widget.textColor!,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    widget.icon!
                  ],
                ),
        ),
      ),
    );
  }
}
