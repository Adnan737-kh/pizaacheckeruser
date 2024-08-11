import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';

import '../../../../../utill/styles.dart';
import '../../../../base/on_hover.dart';

class CategoryPageNamesView extends StatefulWidget {
  final CategoryProvider categoryProvider;
  final PageController pageController;
  const CategoryPageNamesView({Key? key, required this.categoryProvider,
    required this.pageController}) : super(key: key);

  @override
  State<CategoryPageNamesView> createState() => _CategoryPageNamesViewState();
}

class _CategoryPageNamesViewState extends State<CategoryPageNamesView> {

  @override
  void initState() {
    super.initState();
    int totalPage = (widget.categoryProvider.categoryList!.length / 12).ceil();

    widget.categoryProvider.updateProductCurrentIndex(0, totalPage);

  }
  @override
  Widget build(BuildContext context) {
    int totalPage = (widget.categoryProvider.categoryList!.length / 12).ceil();

    return PageView.builder(
      controller: widget.pageController,
      itemCount: totalPage,
      onPageChanged: (index) {
        widget.categoryProvider.updateProductCurrentIndex(index, totalPage);
      },
      itemBuilder: (context, index) {
        int initialLength = 12;
        int currentIndex = 12 * index;

        // ignore: unnecessary_statements
        // Adjust initialLength for the last page
        if (index + 1 == totalPage) {
          initialLength = widget.categoryProvider.categoryList!.length - (index * 12);
        }
        return ListView.builder(
            itemCount: initialLength,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, item) {
              int currentIndex0 = item  + currentIndex;
              String? name = '';
              widget.categoryProvider.categoryList![currentIndex0].name!.length > 15
                  ? name = '${widget.categoryProvider.categoryList![currentIndex0].name!.substring(0, 15)}...'
                  : name = widget.categoryProvider.categoryList![currentIndex0].name;
              return OnHover(
                  builder: (isHover) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => RouterHelper.getCategoryRoute(widget.categoryProvider.categoryList![currentIndex0]),// arguments:  category.categoryList[index].name),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FittedBox(
                            child: Text(
                                name!, style: rubikMedium.copyWith(color: isHover ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    );
                  }
              );
            }
        );
      },
    );
  }
}
