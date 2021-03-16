import 'package:provider/provider.dart';
import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/widgets/AppBarLeadingButton.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:zapytaj/widgets/QuestionListItem.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthProvider _authProvider;
  TextEditingController _searchController = TextEditingController();
  List<Question> _questions = [];
  bool _startedSearching = false;

  _searchQuestions(String value) async {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _startedSearching = true;
    await ApiRepository.searchQuestions(context,
            userId: _authProvider.user.id, title: value)
        .then((questions) {
      setState(() {
        _questions = questions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      leading: AppBarLeadingButton(),
      title: Text('Search', style: TextStyle(color: Colors.black)),
    );
  }

  _body(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 6,
            right: SizeConfig.blockSizeHorizontal * 6,
            top: SizeConfig.blockSizeVertical * 2,
          ),
          child: CustomTextField(
            hint: 'Type to search',
            controller: _searchController,
            onChanged: _searchQuestions,
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical),
        Divider(thickness: 1, color: Colors.grey.shade200),
        Expanded(
          child: Container(
            color: _questions.length != 0
                ? Theme.of(context).scaffoldBackgroundColor
                : Colors.white,
            child: _startedSearching
                ? _questions.isNotEmpty
                    ? ListView.builder(
                        itemCount: _questions.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) => QuestionListItem(
                          question: _questions[i],
                        ),
                      )
                    : _infoScreen('No questions found')
                : _infoScreen('Type to search'),
          ),
        ),
      ],
    );
  }

  _infoScreen(String text) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.grey.shade300,
              size: SizeConfig.blockSizeHorizontal * 11,
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
