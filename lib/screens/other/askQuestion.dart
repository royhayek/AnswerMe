import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/providers/auth_provider.dart';
import 'package:zapytaj/screens/other/information.dart';
import 'package:zapytaj/services/api_repository.dart';
import 'package:zapytaj/widgets/checkbox_list_tile.dart';
import 'package:zapytaj/widgets/dynamic_image_question_field.dart';
import 'package:zapytaj/widgets/dynamic_question_field.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

import 'package:zapytaj/config/size_config.dart';
import 'package:zapytaj/widgets/appbar_leading_button.dart';
import 'package:zapytaj/widgets/custom_text_field.dart';
import 'package:zapytaj/widgets/default_button.dart';
import 'package:zapytaj/widgets/featured_image_picker.dart';

class AskQuestionScreen extends StatefulWidget {
  final bool askAuthor;
  final int authorId;

  const AskQuestionScreen({Key key, this.askAuthor = false, this.authorId})
      : super(key: key);

  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _videoURLController = TextEditingController();

  AuthProvider authProvider;

  List<DynamicQuestionField> _listOfQuestions = [];
  List<DynamicImageQuestionField> _listOfImageQuestions = [];
  List<String> _selectedTags = [];
  List<String> _options = [];
  List<Option> _imageOptions = [];
  int _selectedCategoryId;

  bool isPoll = false;
  bool isImagePoll = false;
  bool showVideoUrl = false;
  bool isAnonymous = false;
  bool isPrivate = false;
  bool getNotification = false;
  bool agreeOnTerms = false;

  List<ChoiceCategory> categories = [];
  File _featuredImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _populateCategories();
    _addDynamicQuestion();
    _addDynamicQuestion();
    _addDynamicImageQuestion();
    _addDynamicImageQuestion();
  }

  _addDynamicQuestion() {
    _listOfQuestions.add(new DynamicQuestionField(
      index: _listOfQuestions.length,
      label: 'Add Answer #${_listOfQuestions.length + 1}',
      remove: _removeDynamicQuestion,
    ));
    setState(() {});
  }

  _removeDynamicQuestion(index) {
    setState(() {
      _listOfQuestions.removeAt(index);
    });
  }

  _getDynamicQuestions() {
    _options.clear();
    _listOfQuestions.forEach((question) {
      _options.add(question.controller.text);
    });
  }

  _addDynamicImageQuestion() {
    _listOfImageQuestions.add(new DynamicImageQuestionField(
      index: _listOfImageQuestions.length,
      label: 'Add Answer #${_listOfImageQuestions.length + 1}',
      remove: _removeDynamicImageQuestion,
      image: _imageOptions.isNotEmpty
          ? _imageOptions[_listOfImageQuestions.length].image
          : null,
      add: _addImageToOptionsList,
    ));
    setState(() {});
  }

  _addImageToOptionsList(int index, File image) {
    if (image != null)
      setState(() {
        _imageOptions.insert(index, Option(id: index, image: image));
      });
  }

  _removeDynamicImageQuestion(index) {
    setState(() {
      _listOfImageQuestions.removeAt(index);
    });
  }

  _getDynamicImageQuestions() {
    _listOfImageQuestions.forEach((question) {
      if (question.controller.text.isNotEmpty)
        _imageOptions
            .firstWhere((option) => option.id == question.index)
            .option = question.controller.text;
    });
  }

  _populateCategories() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.categories != null)
      await appProvider.getCategories(context);
    appProvider.categories.forEach((category) {
      setState(() {
        categories.add(ChoiceCategory(id: category.id, name: category.name));
      });
    });
  }

  _addQuestion() async {
    if (_formKey.currentState.validate()) {
      if (!agreeOnTerms) {
        Toast.show('Please check terms and privacy policy', context);
        return;
      }

      String title = _titleController.text;
      String details = _detailsController.text;
      String videoURL = _videoURLController.text;

      if (widget.askAuthor) {
        Question _question = new Question();
        _question.authorId = isAnonymous
            ? 0
            : authProvider.user != null
                ? authProvider.user.id
                : 0;
        _question.title = title;
        _question.content = details;
        _question.createdAt = DateTime.now().toString();
        _question.videoURL = '';
        _question.asking = widget.authorId;

        await ApiRepository.addQuestion(
          context,
          question: _question,
          options: [],
          imageOptions: [],
        );
      } else {
        if (_selectedCategoryId == null) {
          Toast.show('Please check one category', context);
          return;
        }

        _getDynamicImageQuestions();
        _getDynamicQuestions();

        String _imageName;
        if (_featuredImage != null)
          _imageName = _featuredImage.path.split('/').last;

        Question _question = new Question();
        _question.authorId = isAnonymous
            ? 0
            : authProvider.user != null
                ? authProvider.user.id
                : 0;
        _question.title = title;
        _question.content = details;
        _question.categoryId = _selectedCategoryId;
        _question.polled = isPoll ? 1 : 0;
        _question.pollTitle = title;
        _question.imagePolled = isImagePoll ? 1 : 0;
        _question.createdAt = DateTime.now().toString();
        _question.videoURL = videoURL;

        await ApiRepository.addQuestion(
          context,
          question: _question,
          tags: _selectedTags,
          options: _options,
          featuredImage: _featuredImage,
          featuredImageName: _imageName,
          imageOptions: _imageOptions,
        );
      }
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _featuredImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _navigateToInformationScreen(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformationScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      leading: AppBarLeadingButton(),
      title: Text('Ask Question', style: TextStyle(color: Colors.black)),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInformationContainer(
                title: 'Question Title *',
                body: Column(
                  children: [
                    CustomTextField(
                      hint: 'Question Title',
                      controller: _titleController,
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
                  ],
                ),
                description:
                    'Please choose an appropriate title for the question so it can be answered easier.',
              ),
              _buildInformationContainer(
                title: 'Category *',
                askAuthor: widget.askAuthor,
                body: Column(
                  children: [
                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
                    _buildCategoryList(),
                  ],
                ),
                description:
                    'Please choose the appropriate section so that question can be searched easier.',
              ),
              _buildInformationContainer(
                title: 'Tags',
                askAuthor: widget.askAuthor,
                body: Column(
                  children: [
                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
                    _buildTagsTextField(context),
                  ],
                ),
                description:
                    'Please choose the appropriate section so that question can be searched easier.',
              ),
              _buildPollContainer(askAuthor: widget.askAuthor),
              FeaturedImagePicker(
                askAuthor: widget.askAuthor,
                getImage: getImage,
                featuredImage: _featuredImage,
              ),
              _buildInformationContainer(
                title: 'Details *',
                body: Column(
                  children: [
                    CustomTextField(
                      hint: 'Details',
                      maxLines: 4,
                      controller: _detailsController,
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
                  ],
                ),
                description: 'Type the description thoroughly and in details.',
              ),
              _buildCheckBoxList(),
            ],
          ),
        ),
      ),
    );
  }

  _buildInformationContainer({
    String title,
    bool askAuthor = false,
    Widget body,
    String description,
  }) {
    if (!askAuthor)
      return Container(
        margin: EdgeInsets.only(
          top: SizeConfig.blockSizeHorizontal * 1.8,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4.2,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            body,
            Text(
              description,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
          ],
        ),
      );
    else
      return Container();
  }

  _buildCategoryList() {
    return Container(
      height: SizeConfig.blockSizeVertical * 6,
      child: ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 2,
          ),
          child: InkWell(
            onTap: () {
              categories.forEach((c) {
                c.selected = false;
              });
              setState(() {
                categories[i].selected = true;
                _selectedCategoryId = categories[i].id;
              });
            },
            child: Text(
              categories[i].name,
              style: TextStyle(
                color: categories[i].selected
                    ? Theme.of(context).primaryColor
                    : Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 3.6,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildTagsTextField(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 10,
      child: TextFieldTags(
        initialTags: [],
        tagsStyler: TagsStyler(
            tagTextPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal,
            ),
            tagTextStyle: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            ),
            tagDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(3.0),
            ),
            tagCancelIcon: Icon(
              Icons.cancel_outlined,
              size: SizeConfig.blockSizeHorizontal * 4,
              color: Colors.white,
            ),
            tagPadding: EdgeInsets.all(6.0)),
        textFieldStyler: TextFieldStyler(
          hintText: 'Tags',
          helperText: '',
          textFieldFilledColor: Colors.grey.shade100,
          textFieldFilled: true,
          textFieldBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              style: BorderStyle.solid,
            ),
          ),
          textFieldEnabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              style: BorderStyle.solid,
            ),
          ),
          textFieldFocusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
              style: BorderStyle.solid,
            ),
          ),
        ),
        onTag: (tag) {
          if (!_selectedTags.contains(tag)) _selectedTags.add(tag);
        },
        onDelete: (tag) {
          _selectedTags.remove(tag);
        },
      ),
    );
  }

  _buildPollContainer({bool askAuthor}) {
    if (!askAuthor)
      return Container(
        margin: EdgeInsets.only(
          top: SizeConfig.blockSizeHorizontal * 1.8,
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical),
            CheckboxListTile(
              value: isPoll,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'This Question is a poll?',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              subtitle: Text(
                'If you want to be doing a poll click here.',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isPoll = !isPoll;
                });
              },
            ),
            SizedBox(height: SizeConfig.blockSizeVertical),
            isPoll
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        value: isImagePoll,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Image Poll?',
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isImagePoll = !isImagePoll;
                          });
                        },
                      ),
                      isPoll
                          ? !isImagePoll
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _listOfQuestions.length,
                                  itemBuilder: (ctx, i) => _listOfQuestions[i],
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _listOfImageQuestions.length,
                                  itemBuilder: (ctx, i) =>
                                      _listOfImageQuestions[i],
                                )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal * 6,
                          vertical: SizeConfig.blockSizeVertical * 3,
                        ),
                        child: GestureDetector(
                          onTap: () => !isImagePoll
                              ? _addDynamicQuestion()
                              : _addDynamicImageQuestion(),
                          child: Container(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Add More +',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      );
    else
      return Container();
  }

  _buildCheckBoxList() {
    return Container(
      margin: EdgeInsets.only(
        top: SizeConfig.blockSizeHorizontal * 1.8,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          CheckBoxListTile(
            title: 'Ask Anonymously',
            value: isAnonymous,
            onPressed: (value) {
              setState(() {
                isAnonymous = value;
              });
            },
            body: isAnonymous
                ? Padding(
                    padding: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal * 5,
                      bottom: SizeConfig.blockSizeVertical * 1.5,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: SizeConfig.blockSizeHorizontal * 4.5,
                          backgroundImage: AssetImage(
                            'assets/images/user_icon.png',
                          ),
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 2.5),
                        Text(
                          'Anonymous Asks',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
          ),
          CheckBoxListTile(
            title: 'Add a video to describe the problem better.',
            value: showVideoUrl,
            askAuthor: widget.askAuthor,
            onPressed: (value) {
              setState(() {
                showVideoUrl = value;
              });
            },
            body: showVideoUrl
                ? _buildInformationContainer(
                    title: 'Video URL *',
                    body: Column(
                      children: [
                        CustomTextField(controller: _videoURLController),
                        SizedBox(height: SizeConfig.blockSizeVertical * 1),
                      ],
                    ),
                    description: 'Put here the video URL',
                  )
                : Container(),
          ),
          CheckBoxListTile(
            title: 'This question is a private question?',
            value: isPrivate,
            onPressed: (value) {
              setState(() {
                isPrivate = value;
              });
            },
          ),
          CheckBoxListTile(
            title:
                'Get notification by email when someone answers this question',
            value: getNotification,
            onPressed: (value) {
              setState(() {
                getNotification = value;
              });
            },
          ),
          CheckBoxListTile(
            last: true,
            content: Wrap(
              children: [
                _buildWrappedText(
                  'By asking your question, you agreed to the',
                  false,
                ),
                GestureDetector(
                  onTap: () =>
                      _navigateToInformationScreen('Terms and Conditions'),
                  child: _buildWrappedText('Terms of Service', true),
                ),
                _buildWrappedText(' and ', false),
                GestureDetector(
                  onTap: () => _navigateToInformationScreen('Privacy Policy'),
                  child: _buildWrappedText('Privacy Policy.*', true),
                ),
              ],
            ),
            value: agreeOnTerms,
            onPressed: (value) {
              setState(() {
                agreeOnTerms = value;
              });
            },
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildPublishButton(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
        ],
      ),
    );
  }

  _buildPublishButton() {
    return DefaultButton(
      text: 'Publish Your Question',
      onPressed: () => _addQuestion(),
    );
  }

  _buildWrappedText(String text, bool hyperlink) {
    return Text(
      text,
      style: hyperlink
          ? TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
            )
          : TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
            ),
    );
  }
}

class ChoiceCategory {
  int id;
  String name;
  bool selected;

  ChoiceCategory({
    this.id,
    this.name,
    this.selected = false,
  });
}

class Option {
  int id;
  String option;
  File image;

  Option({this.id, this.option, this.image});
}
