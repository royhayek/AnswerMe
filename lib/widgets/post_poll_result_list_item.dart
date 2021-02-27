import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/models/option.dart';

class PostPollResultListItem extends StatelessWidget {
  final Option option;
  final int count;
  final bool selected;
  final Function onOptionSelected;

  const PostPollResultListItem(
      {Key key, this.option, this.count, this.selected, this.onOptionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 0.5,
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: SizedBox(
        height: SizeConfig.blockSizeVertical * 6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 2,
              ),
              child: Text(
                '${option.option} (${option.votes} voters)',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical),
            LinearPercentIndicator(
              // width: 140.0,
              lineHeight: 10.0,
              percent: option.votes / count,
              center: Text(
                '${option.votes / count * 100}%', //"50.0%",
                style: new TextStyle(fontSize: 10.0, color: Colors.white),
              ),
              // trailing: Icon(Icons.mood),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
