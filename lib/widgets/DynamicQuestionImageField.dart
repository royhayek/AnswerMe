import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zapytaj/models/Option.dart';
import 'package:zapytaj/services/ApiRepository.dart';

// ignore: must_be_immutable
class DynamicImageQuestionField extends StatefulWidget {
  final int index;
  final String label;
  final Function remove;
  final Function add;
  final File image;
  final Option option;

  DynamicImageQuestionField(
      {Key key,
      this.index,
      this.label,
      this.remove,
      this.add,
      this.image,
      this.option})
      : super(key: key);

  final TextEditingController idController = new TextEditingController();
  final TextEditingController controller = new TextEditingController();
  String optionImageString;
  File optionimage;

  set setOptionImage(File value) {
    optionimage = value;
    print(optionimage);
  }

  @override
  _DynamicImageQuestionFieldState createState() =>
      _DynamicImageQuestionFieldState();
}

class _DynamicImageQuestionFieldState extends State<DynamicImageQuestionField> {
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // setState(() {
        widget.setOptionImage = File(pickedFile.path);
        // widget.add(widget.index, image);
        // });
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.option != null) {
      widget.controller.text = widget.option.option;
      widget.idController.text = widget.option.id.toString();
      widget.optionImageString = widget.option.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
        vertical: SizeConfig.blockSizeVertical,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => getImage(),
            child: widget.optionImageString == null
                ? widget.optionimage == null
                    ? DottedBorder(
                        color: Colors.black54,
                        strokeWidth: 1,
                        borderType: BorderType.Circle,
                        child: Container(
                          width: SizeConfig.blockSizeHorizontal * 12,
                          height: SizeConfig.blockSizeHorizontal * 12,
                          child: Icon(
                            FluentIcons.camera_add_20_regular,
                            size: SizeConfig.blockSizeHorizontal * 4.5,
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
                          width: SizeConfig.blockSizeHorizontal * 12,
                          height: SizeConfig.blockSizeHorizontal * 12,
                          child: Image.file(
                            widget.optionimage,
                            width: double.infinity,
                            fit: BoxFit.fill,
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
                      width: SizeConfig.blockSizeHorizontal * 12,
                      height: SizeConfig.blockSizeHorizontal * 12,
                      child: Image.network(
                        '${ApiRepository.OPTION_IMAGES_PATH}${widget.optionImageString}',
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 6,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: FocusNode(canRequestFocus: false),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 4,
                        color: Colors.black54,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 4),
          InkWell(
            onTap: () => widget.remove(widget.index),
            child: Container(
              width: SizeConfig.blockSizeHorizontal * 8,
              height: SizeConfig.blockSizeHorizontal * 8,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: SizeConfig.blockSizeHorizontal * 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
