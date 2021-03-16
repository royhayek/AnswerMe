import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/config/AdmobConfig.dart';
import 'package:zapytaj/providers/AppProvider.dart';
import 'package:zapytaj/widgets/CategoryListItem.dart';
import 'package:flutter/material.dart';

import '../../config/SizeConfig.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  AppProvider appProvider;
  bool isLoading = true;
  double _bottomPadding = 0;

  @override
  void initState() {
    super.initState();
    appProvider = Provider.of<AppProvider>(context, listen: false);
    _getCategories();
  }

  Future _getCategories() async {
    if (appProvider.categories.isEmpty)
      await appProvider.getCategories(context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: _buildCategoriesList(),
    );
  }

  _appBar() {
    return AppBar(
      title: Text('Categories', style: TextStyle(color: Colors.black)),
    );
  }

  _buildCategoriesList() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: _bottomPadding),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Consumer<AppProvider>(
                  builder: (context, app, _) {
                    if (app.categories.isEmpty) {
                      return Center(child: Text('No Categories Found'));
                    } else {
                      return StaggeredGridView.countBuilder(
                        crossAxisCount: 4,
                        itemCount: app.categories.length,
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal * 4,
                          vertical: SizeConfig.blockSizeVertical,
                        ),
                        itemBuilder: (BuildContext context, int i) =>
                            CategoriesListItem(
                          category: app.categories[i],
                          getCategories: _getCategories,
                        ),
                        staggeredTileBuilder: (int index) =>
                            new StaggeredTile.fit(2),
                        crossAxisSpacing: SizeConfig.blockSizeHorizontal * 4,
                      );
                    }
                  },
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: AdmobBanner(
              adUnitId: AdmobConfig.bannerAdUnitId,
              adSize: AdmobBannerSize.BANNER,
              onBannerCreated: (_) {
                setState(() {
                  _bottomPadding = 48.0;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}
