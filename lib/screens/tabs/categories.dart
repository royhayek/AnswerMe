import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:zapytaj/providers/app_provider.dart';
import 'package:zapytaj/widgets/category_list_item.dart';
import 'package:flutter/material.dart';

import '../../config/size_config.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  AppProvider appProvider;
  bool isLoading = true;

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
    return isLoading
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
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                  crossAxisSpacing: SizeConfig.blockSizeHorizontal * 4,
                );
              }
            },
          );
  }
}
