import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:zapytaj/models/Option.dart';
import 'package:zapytaj/models/question.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/providers/AuthProvider.dart';
import 'package:zapytaj/screens/other/Information.dart';
import 'package:zapytaj/screens/other/QuestionPosted.dart';
import 'package:zapytaj/services/ApiRepository.dart';
import 'package:zapytaj/utils/utils.dart';
import 'package:zapytaj/widgets/CheckboxListTile.dart';
import 'package:zapytaj/widgets/DynamicQuestionImageField.dart';
import 'package:zapytaj/widgets/DynamicQuestionField.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:http/http.dart' as http;

import 'package:zapytaj/config/SizeConfig.dart';
import 'package:zapytaj/widgets/AppBarLeadingButton.dart';
import 'package:zapytaj/widgets/CustomTextField.dart';
import 'package:zapytaj/widgets/DefaultButton.dart';
import 'package:zapytaj/widgets/FeaturedImagePicker.dart';

class AskQuestionScreen extends StatefulWidget {
  final bool askAuthor;
  final int authorId;
  final int questionId;

  const AskQuestionScreen(
      {Key key, this.askAuthor = false, this.authorId, this.questionId})
      : super(key: key);

  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _videoURLController = TextEditingController();

  AuthProvider _authProvider;
  AppProvider _appProvider;

  List<DynamicQuestionField> _listOfQuestions = [];
  List<DynamicImageQuestionField> _listOfImageQuestions = [];
  List<String> _selectedTags = [];
  // List<String> _options = [];
  List<AskOption> _options = [];
  List<AskOption> _imageOptions = [];
  int _selectedCategoryId;

  bool _isLoading = false;
  bool isPoll = false;
  bool isImagePoll = false;
  bool showVideoUrl = false;
  bool isAnonymous = false;
  bool isPrivate = false;
  bool getNotification = false;
  bool agreeOnTerms = false;

  Question _question;
  List<ChoiceCategory> categories = [];
  File _featuredImage;
  String _networkFeaturedImage;

  final picker = ImagePicker();
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _populateCategories().then((value) async {
      if (widget.questionId != null) await _getQuestion();
      setState(() {
        _isLoading = false;
      });
    });

    _addDynamicQuestion();
    _addDynamicQuestion();
    _addDynamicImageQuestion();
    _addDynamicImageQuestion();
  }

  Future _getQuestion() async {
    await ApiRepository.getQuestion(
      context,
      widget.questionId,
      _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((question) {
      setState(() {
        _question = question;
      });
      if (mounted) _titleController.text = question.title;
      if (categories.isNotEmpty)
        categories.where((c) => c.id == question.categoryId).first.selected =
            true;
      _detailsController.text = question.content;
      if (question.polled == 1) isPoll = true;
      if (question.imagePolled == 1) isImagePoll = true;
      if (question.videoURL != null) {
        showVideoUrl = true;
        _videoURLController.text = question.videoURL;
      }
      _selectedCategoryId = question.categoryId;
      if (question.featuredImage != null)
        _networkFeaturedImage = question.featuredImage;
      _question.tags.forEach((tag) {
        // setState(() {
        _selectedTags.add(tag.tag);
        // });
      });
      if (question.options.isNotEmpty) {
        _listOfQuestions = [];
        _listOfImageQuestions = [];
        question.options.forEach((o) {
          _addDynamicQuestion(o: o);
          _addDynamicImageQuestion(o: o);
        });
      }
    });
  }

  _addDynamicQuestion({Option o}) {
    _listOfQuestions.add(new DynamicQuestionField(
      index: _listOfQuestions.length,
      label: 'Add Answer #${_listOfQuestions.length + 1}',
      remove: _removeDynamicQuestion,
      option: o,
    ));
    setState(() {});
  }

  _removeDynamicQuestion(index) {
    setState(() {
      _listOfQuestions.removeWhere((q) => q.index == index);
    });
  }

  _getDynamicQuestions() {
    _options.clear();
    _listOfQuestions.forEach((question) {
      _options.add(
        AskOption(
          option: question.inputController.text,
          id: question.option != null ? question.option.id.toString() : null,
        ),
      );
    });
  }

  _addDynamicImageQuestion({Option o}) {
    _listOfImageQuestions.add(new DynamicImageQuestionField(
      index: _listOfImageQuestions.length,
      label: 'Add Answer #${_listOfImageQuestions.length + 1}',
      remove: _removeDynamicImageQuestion,
      image: _imageOptions.isNotEmpty
          ? _imageOptions[_listOfImageQuestions.length].image
          : null,
      option: o,
    ));
    setState(() {});
  }

  _removeDynamicImageQuestion(index) {
    setState(() {
      _listOfImageQuestions.removeAt(index);
    });
  }

  Future _getDynamicImageQuestions() async {
    _options.clear();
    File image;
    _listOfImageQuestions.forEach((question) async {
      if (question.controller.text.isNotEmpty &&
          question.controller.text != null &&
          question.controller.text != '') {
        if (question.optionImageString != null) {
          image = await urlToFile(
              '${ApiRepository.OPTION_IMAGES_PATH}${question.optionImageString}');
          setState(() {
            _options.add(
              AskOption(
                option: question.controller.text,
                id: question.idController.text.isNotEmpty
                    ? question.idController.text.toString()
                    : null,
                image: image,
              ),
            );
          });
        } else {
          setState(() {
            _options.add(
              AskOption(
                option: question.controller.text,
                id: question.idController.text.isNotEmpty
                    ? question.idController.text.toString()
                    : null,
                image:
                    question.optionimage != null ? question.optionimage : null,
              ),
            );
          });
        }
      }
    });
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future _populateCategories() async {
    setState(() {
      _isLoading = true;
    });
    if (_appProvider.categories != null)
      await _appProvider.getCategories(context);
    _appProvider.categories.forEach((category) {
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

      showLoadingDialog(context, 'Asking Question...');

      String title = _titleController.text;
      String details = _detailsController.text;
      String videoURL = _videoURLController.text;

      if (widget.askAuthor) {
        Question _question = new Question();
        _question.authorId = isAnonymous
            ? 0
            : _authProvider.user != null
                ? _authProvider.user.id
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
        ).then((value) => Navigator.pop(context));
      } else {
        if (_selectedCategoryId == null) {
          Toast.show('Please check one category', context);
          return;
        }

        if (isPoll) {
          if (isImagePoll)
            await _getDynamicImageQuestions();
          else
            _getDynamicQuestions();
        }

        String _imageName;
        if (_featuredImage != null)
          _imageName = _featuredImage.path.split('/').last;

        Question _question = new Question();
        _question.authorId = isAnonymous
            ? 0
            : _authProvider.user != null
                ? _authProvider.user.id
                : 0;
        _question.title = title;
        _question.content = details;
        _question.categoryId = _selectedCategoryId;
        _question.polled = isPoll ? 1 : 0;
        _question.pollTitle = title;
        _question.imagePolled = isImagePoll ? 1 : 0;
        _question.createdAt = DateTime.now().toString();
        _question.videoURL = videoURL;

        if (_usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty) {
          _question.username = _usernameController.text;
          _question.email = _usernameController.text;
        }
        await ApiRepository.addQuestion(
          context,
          question: _question,
          tags: _selectedTags,
          options: _options,
          featuredImage: _featuredImage,
          featuredImageName: _imageName,
        ).then((value) {
          _appProvider.clearAllQuestions();
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => QuestionPostedScreen(type: SubmitType.store),
            ),
          );
        });
      }
    }
  }

  _updateQuestion() async {
    if (_formKey.currentState.validate()) {
      if (!agreeOnTerms) {
        Toast.show('Please check terms and privacy policy', context);
        return;
      }

      showLoadingDialog(context, 'Updating Question...');

      String title = _titleController.text;
      String details = _detailsController.text;
      String videoURL = _videoURLController.text;

      if (widget.askAuthor) {
        Question _question = new Question();
        _question.id = widget.questionId;
        _question.authorId = isAnonymous
            ? 0
            : _authProvider.user != null
                ? _authProvider.user.id
                : 0;
        _question.title = title;
        _question.content = details;
        // _question.createdAt = DateTime.now().toString();
        _question.updatedAt = DateTime.now().toString();
        _question.videoURL = '';
        _question.asking = widget.authorId;

        await ApiRepository.updateQuestion(
          context,
          question: _question,
          options: [],
        ).then((value) => Navigator.pop(context));
      } else {
        print('we are hereeeeeeeee');
        if (_selectedCategoryId == null) {
          Toast.show('Please check one category', context);
          return;
        }

        if (isPoll) {
          if (isImagePoll)
            await _getDynamicImageQuestions();
          else
            _getDynamicQuestions();
        }

        String _imageName;
        if (_featuredImage != null)
          _imageName = _featuredImage.path.split('/').last;

        Question _question = new Question();
        _question.id = widget.questionId;
        _question.authorId = isAnonymous
            ? 0
            : _authProvider.user != null
                ? _authProvider.user.id
                : 0;
        _question.title = title;
        _question.content = details;
        _question.categoryId = _selectedCategoryId;
        _question.polled = isPoll ? 1 : 0;
        _question.pollTitle = title;
        _question.imagePolled = isImagePoll ? 1 : 0;
        _question.updatedAt = DateTime.now().toString();
        _question.videoURL = videoURL;

        if (_usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty) {
          _question.username = _usernameController.text;
          _question.email = _usernameController.text;
        }

        await ApiRepository.updateQuestion(
          context,
          question: _question,
          tags: _selectedTags,
          options: _options,
          featuredImage: _featuredImage,
          featuredImageName: _imageName,
        ).then((value) {
          _appProvider.clearAllQuestions();
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => QuestionPostedScreen(
                type: SubmitType.update,
                questionId: _question.id,
              ),
            ),
          );
        });
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

  _removeFeaturedImage() async {
    await ApiRepository.removeFeaturedImage(
      context,
      questionId: widget.questionId,
    ).then((value) {
      setState(() {
        _networkFeaturedImage = null;
      });
    });
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
      title: Text(
        widget.questionId != null ? 'Edit Question' : 'Ask Question',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
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
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _authProvider.user == null ||
                            _authProvider.user.username == null
                        ? _buildInformationContainer(
                            title: 'Username *',
                            body: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  hint: 'Username',
                                  controller: _usernameController,
                                ),
                                SizedBox(
                                    height: SizeConfig.blockSizeVertical * 2),
                                Text(
                                  'Email *',
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 4.2,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                                CustomTextField(
                                  hint: 'Email',
                                  controller: _emailController,
                                ),
                                SizedBox(height: SizeConfig.blockSizeVertical),
                              ],
                            ),
                          )
                        : Container(),
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
                      networkedFeaturedImage: _networkFeaturedImage,
                      removeFeaturedImage: _removeFeaturedImage,
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
                      description:
                          'Type the description thoroughly and in details.',
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
            description != null
                ? Text(
                    description,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                      color: Colors.black54,
                    ),
                  )
                : Container(),
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
        initialTags: _selectedTags.isNotEmpty ? _selectedTags : [],
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
          _selectedTags.add(tag);
        },
        onDelete: (tag) {
          setState(() {
            _selectedTags.remove(tag);
          });
          print(_selectedTags);
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
              autofocus: false,
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
                        autofocus: false,
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
          // CheckBoxListTile(
          //   title: 'This question is a private question?',
          //   value: isPrivate,
          //   onPressed: (value) {
          //     setState(() {
          //       isPrivate = value;
          //     });
          //   },
          // ),
          // CheckBoxListTile(
          //   title:
          //       'Get notification by email when someone answers this question',
          //   value: getNotification,
          //   onPressed: (value) {
          //     setState(() {
          //       getNotification = value;
          //     });
          //   },
          // ),
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
      text: widget.questionId != null
          ? 'Update Your Question'
          : 'Publish Your Question',
      onPressed: () =>
          widget.questionId != null ? _updateQuestion() : _addQuestion(),
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

class AskOption {
  String id;
  String option;
  File image;

  AskOption({this.id, this.option, this.image});

  Map<String, dynamic> toJson() => {
        'id': id,
        'option': option,
      };
}
