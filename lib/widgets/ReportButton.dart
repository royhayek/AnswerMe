import 'package:provider/provider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../config/SizeConfig.dart';

class ReportButton extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reportController = TextEditingController();
  final int questionId;
  final int answerId;

  ReportButton({Key key, this.questionId, this.answerId}) : super(key: key);

  _submitReport(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
      await ApiRepository.submitReport(
        context,
        userId: _auth.user != null ? _auth.user.id : 0,
        questionId: questionId,
        answerId: answerId,
        content: _reportController.text,
        type: answerId != null ? 'Answer' : 'Question',
      ).then((value) => Navigator.of(context).pop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          child: Container(
            width: SizeConfig.blockSizeHorizontal * 8,
            height: SizeConfig.blockSizeHorizontal * 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(FluentIcons.flag_16_regular, size: 16),
          ),
          onTap: () => showCustomDialogWithTitle(
            context,
            title: 'Report',
            body: Form(
              key: _formKey,
              child: CustomTextField(
                label: 'Message',
                labelSize: SizeConfig.safeBlockHorizontal * 4,
                controller: _reportController,
              ),
            ),
            onTapCancel: () => Navigator.pop(context),
            onTapSubmit: () => _submitReport(context),
          ),
        ),
      ],
    );
  }
}
