import 'package:flutter/material.dart';

class HomeCardButton extends StatelessWidget {
  final String titleText;
  final IconData cardIcon;
  final double height;
  // var isAccent = false;
  final bool? isAccent;
  final VoidCallback onTap;

  const HomeCardButton(
      {super.key,
      required this.titleText,
      required this.cardIcon,
      required this.height,
      this.isAccent = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25.0),
      child: Ink(
        width: MediaQuery.of(context).size.width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: isAccent!
              ? Theme.of(context).colorScheme.secondary
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: titleText.contains('\n')
                    ? const EdgeInsets.fromLTRB(25, 0, 0, 30)
                    : const EdgeInsets.fromLTRB(25, 0, 0, 40),
                child: Text(
                  titleText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: isAccent!
                      ? textTheme.displaySmall?.copyWith(
                          height: titleText.contains('\n') ? 1.0 : 1.5,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)
                      : textTheme.bodySmall?.copyWith(
                          height: titleText.contains('\n') ? 1.0 : 1.5,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
            Padding(
              padding: isAccent!
                  ? const EdgeInsets.fromLTRB(0, 75, 5, 0)
                  : const EdgeInsets.fromLTRB(0, 30, 5, 0),
              child: Icon(
                cardIcon,
                color: isAccent!
                    ? Colors.white
                    : Theme.of(context).colorScheme.secondary,
                size: isAccent! ? 50 : 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
