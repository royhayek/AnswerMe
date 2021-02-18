import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/config/size_config.dart';

class FeaturedImagePicker extends StatelessWidget {
  final bool askAuthor;
  final File featuredImage;
  final Function getImage;
  final bool hasPadding;

  const FeaturedImagePicker(
      {Key key,
      this.askAuthor = false,
      this.featuredImage,
      this.getImage,
      this.hasPadding = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!askAuthor)
      return Container(
        width: double.infinity,
        color: Colors.white,
        margin: EdgeInsets.only(
          top: hasPadding ? SizeConfig.blockSizeHorizontal * 1.8 : 0,
        ),
        padding: hasPadding
            ? EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 6,
              )
            : EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            Text(
              'Featured Image',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4.2,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
            InkWell(
              onTap: getImage,
              child: featuredImage == null
                  ? DottedBorder(
                      color: Colors.black54,
                      strokeWidth: 1,
                      borderType: BorderType.Circle,
                      child: Container(
                        width: SizeConfig.blockSizeHorizontal * 13,
                        height: SizeConfig.blockSizeHorizontal * 13,
                        child: Icon(
                          FluentIcons.camera_add_20_regular,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : DottedBorder(
                      color: Colors.black54,
                      strokeWidth: 1,
                      borderType: BorderType.Circle,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            SizeConfig.blockSizeHorizontal * 10,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        width: SizeConfig.blockSizeHorizontal * 13,
                        height: SizeConfig.blockSizeHorizontal * 13,
                        child: Image.file(
                          featuredImage,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
          ],
        ),
      );
    else
      return Container();
  }
}
