import 'package:provider/provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../config/size_config.dart';

class ReportButton extends StatelessWidget {
  final TextEditingController _reportController = TextEditingController();
  final int questionId;
  final int answerId;

  ReportButton({Key key, this.questionId, this.answerId}) : super(key: key);

  _submitReport(BuildContext context) async {
    AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.submitReport(
      context,
      userId: _auth.user.id,
      questionId: questionId,
      answerId: answerId,
      content: _reportController.text,
      type: answerId != null ? 'Answer' : 'Question',
    ).then((value) => Navigator.of(context).pop());
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
            body: CustomTextField(
              label: 'Message',
              labelSize: SizeConfig.safeBlockHorizontal * 4,
              controller: _reportController,
            ),
            onTapCancel: () => Navigator.pop(context),
            onTapSubmit: () => _submitReport(context),
          ),
        ),
      ],
    );
  }
}
