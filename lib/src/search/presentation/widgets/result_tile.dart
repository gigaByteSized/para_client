import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

class ResultTile extends StatelessWidget {
  final Feature? feature;
  final void Function(Feature feature)? onRemove;
  final void Function(Feature feature)? onFeaturePressed;

  const ResultTile({
    super.key,
    this.feature,
    this.onFeaturePressed,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        height: 70,
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                child: _buildLeadingIcon()),
            _buildName(context),
            // Padding(
            //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            //     child: _buildTrailingIcon()),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Icon(
          Icons.location_on_outlined,
          color: Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildName(context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Stack(
          // mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.start,
          alignment: Alignment.centerLeft,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                feature!.properties!.name ?? '',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey[900],
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                    ),
                // maxLines: 3,
                overflow: TextOverflow.ellipsis,
                // style: const TextStyle(
                //   fontFamily: 'Butler',
                //   fontWeight: FontWeight.w900,
                //   fontSize: 18,
                //   color: Colors.black87,
                // ),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                feature!.properties!.city == null ||
                        feature!.properties!.state == null
                    ? ''
                    : "${feature!.properties!.city}, ${feature!.properties!.state}",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.grey[700],
                      // fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // // Datetime
            // Row(
            //   children: [
            //     const Icon(Icons.timeline_outlined, size: 16),
            //     const SizedBox(width: 4),
            //     Text(
            //       feature!.publishedAt!,
            //       style: const TextStyle(
            //         fontSize: 12,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTrailingIcon() {
  //   return Container(
  //     width: 32,
  //     height: 32,
  //     // decoration: BoxDecoration(
  //     //   color: Colors.grey[300],
  //     //   borderRadius: BorderRadius.circular(100),
  //     // ),
  //     child: Center(
  //       child: Icon(
  //         CupertinoIcons.arrow_up_left,
  //         color: Colors.grey[600],
  //         size: 24,
  //       ),
  //     ),
  //   );
  // }

  void _onTap() {
    if (onFeaturePressed != null) {
      onFeaturePressed!(feature!);
    }
  }
}
