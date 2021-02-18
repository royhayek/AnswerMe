import 'package:zapytaj/config/size_config.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool hasPadding;
  final bool loading;

  const DefaultButton({
    Key key,
    this.text,
    this.onPressed,
    this.hasPadding,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: SizeConfig.blockSizeVertical * 6,
      padding: EdgeInsets.symmetric(
        horizontal: hasPadding != null ? 0 : SizeConfig.blockSizeHorizontal * 6,
      ),
      child: FlatButton(
        color: Theme.of(context).primaryColor,
        onPressed: () => onPressed(),
        child: loading
            ? SizedBox(
                width: SizeConfig.blockSizeVertical * 3,
                height: SizeConfig.blockSizeVertical * 3,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
