import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/category_model.dart';
import 'package:flutter_restaurant/data/model/response/language_model.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/provider/category_provider.dart';
import 'package:flutter_restaurant/provider/language_provider.dart';
import 'package:flutter_restaurant/provider/localization_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/provider/product_provider.dart';
import 'package:flutter_restaurant/provider/search_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/branch_button_view.dart';
import 'package:flutter_restaurant/view/base/custom_image.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/on_hover.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/cetegory_hover_widget.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/language_hover_widget.dart';
import 'package:flutter_restaurant/view/screens/home/web/widget/status_widget.dart';
import 'package:flutter_restaurant/view/screens/menu/widget/sign_out_confirmation_dialog.dart';
import 'package:flutter_restaurant/view/screens/menu/web/menu_item_web.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/model/response/menu_model.dart';
import '../../main.dart';
import '../../provider/profile_provider.dart';
import '../../provider/wallet_provider.dart';
import 'custom_directionality.dart';

class WebAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBar({Key? key}) : super(key: key);

  @override
  State<WebAppBar> createState() => _WebAppBarState();

  @override
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarState extends State<WebAppBar> {
  final bool _isLoggedIn =
      Provider.of<AuthProvider>(Get.context!, listen: false).isLoggedIn();

  List<PopupMenuEntry<Object>> popUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> list = <PopupMenuEntry<Object>>[];
    List<CategoryModel>? categoryList =
        Provider.of<CategoryProvider>(context, listen: false).categoryList;
    list.add(PopupMenuItem(
      padding: EdgeInsets.zero,
      value: categoryList,
      child: MouseRegion(
        onExit: (_) => context.pop(),
        child: CategoryHoverWidget(categoryList: categoryList),
      ),
    ));
    return list;
  }

  List<PopupMenuEntry<Object>> popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList =
        <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList = AppConstants.languages;
    languagePopupMenuEntryList.add(PopupMenuItem(
      padding: EdgeInsets.zero,
      value: languageList,
      child: MouseRegion(
        onExit: (_) => context.pop(),
        child: LanguageHoverWidget(languageList: languageList),
      ),
    ));
    return languagePopupMenuEntryList;
  }

  _showPopupMenu(Offset offset, BuildContext context, bool isCategory) async {
    double left = offset.dx;
    double top = offset.dy;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          left, top, overlay.size.width, overlay.size.height),
      items: isCategory ? popUpMenuList(context) : popUpLanguageList(context),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context, listen: false)
        .initializeAllLanguages(context);
    final LanguageModel currentLanguage = AppConstants.languages.firstWhere(
        (language) =>
            language.languageCode ==
            Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [
        BoxShadow(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 10))
      ]),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Center(
              child: SizedBox(
                width: 1170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      !Provider.of<SplashProvider>(context, listen: false)
                              .isRestaurantOpenNow(context)
                          ? Consumer<OrderProvider>(
                              builder: (context, orderProvider, child) {
                              return Text(
                                '${getTranslated('restaurant_is_close_now', context)}',
                                style: rubikRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Colors.white),
                              );
                            })
                          : Consumer<LocationProvider>(
                              builder: (context, locationProvider, _) {
                              return locationProvider.address!.isNotEmpty
                                  ? InkWell(
                                      onTap: () =>
                                          RouterHelper.getAddressRoute(),
                                      child: locationProvider.isLoading
                                          ? const SizedBox()
                                          : Row(
                                              children: [
                                                Text(
                                                  locationProvider.address!,
                                                  style: robotoRegular.copyWith(fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Colors.white),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    )
                                  : const SizedBox();
                            }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const BranchButtonView(
                              isRow: true, color: Colors.white),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall),
                            child: Text(getTranslated('dark_theme', context)!,
                                style: poppinsRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeExtraSmall)),
                          ),
                          const StatusWidget(),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraLarge),

                          if (AppConstants.languages.length > 1)
                            SizedBox(
                              height: Dimensions.paddingSizeLarge,
                              child: OnHover(builder: (isHovered) {
                                final color =
                                    isHovered ? Colors.black : Colors.white;
                                return MouseRegion(
                                  onHover: (details) {
                                    _showPopupMenu(
                                        details.position, context, false);
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        currentLanguage.imageUrl!,
                                        height: Dimensions.paddingSizeLarge,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSmall),
                                      Text('${currentLanguage.languageName}',
                                          style: poppinsRegular.copyWith(
                                              color: color,
                                              fontSize: Dimensions
                                                  .fontSizeExtraSmall)),
                                      const SizedBox(
                                          width:
                                              Dimensions.paddingSizeExtraSmall),
                                      Icon(Icons.expand_more,
                                          color: color,
                                          size: Dimensions.paddingSizeLarge)
                                    ],
                                  ),
                                );
                              }),
                            ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          // Consumer<AuthProvider>(
                          //   builder: (context, authProvider, _) {
                          //     return InkWell(
                          //       onTap: () {
                          //         if(authProvider.isLoggedIn()) {
                          //           showDialog(context: context, barrierDismissible: false, builder: (context) => const SignOutConfirmationDialog());
                          //         }else {
                          //           RouterHelper.getLoginRoute();
                          //         }
                          //       },
                          //       child: OnHover(
                          //         builder: (isHover) {
                          //           return Row(children: [
                          //             const Icon(Icons.lock_outlined, color: Colors.white, size: Dimensions.paddingSizeDefault),
                          //             const SizedBox(width: Dimensions.paddingSizeSmall),
                          //             Text(getTranslated(authProvider.isLoggedIn() ? 'logout' : 'login', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white))
                          //           ],
                          //           );
                          //         }
                          //       ),
                          //     );
                          //   }
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                  width: 1170,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Provider.of<ProductProvider>(context, listen: false)
                              .latestOffset = 1;
                          RouterHelper.getMainRoute(
                              action: RouteAction.pushReplacement);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                              Provider.of<SplashProvider>(context).baseUrls !=
                                      null
                                  ? Consumer<SplashProvider>(
                                      builder: (context, splash, child) =>
                                          CustomImage(
                                            image:
                                                '${splash.baseUrls!.restaurantImageUrl}/${splash.configModel!.restaurantLogo}',
                                            placeholder: Images.webAppBarLogo,
                                            fit: BoxFit.contain,
                                            width: 120,
                                            height: 80,
                                          ))
                                  : const SizedBox(),
                        ),
                      ),
                      OnHover(builder: (isHover) {
                        return InkWell(
                          onTap: () {
                            RouterHelper.getHomeRoute(fromAppBar: 'true');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault),
                            child: Text(
                              getTranslated('home', context)!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: rubikRegular.copyWith(
                                  color: isHover
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall),
                        child: MouseRegion(
                          onHover: (details) {
                            if (Provider.of<CategoryProvider>(context,
                                        listen: false)
                                    .categoryList !=
                                null) {
                              _showPopupMenu(details.position, context, true);
                            }
                          },
                          child: OnHover(builder: (isHover) {
                            return Text(getTranslated('category', context)!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: rubikRegular.copyWith(
                                    color: isHover
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontSize: Dimensions.fontSizeLarge));
                          }),
                        ),
                      ),
                      OnHover(

                        builder: (isHover) {
                          return InkWell(
                              onTap: () =>
                                  RouterHelper.getDashboardRoute('favourite'),
                              child: SizedBox(
                                width: 120,
                                child: Text(
                                    getTranslated('favourite', context)!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: rubikRegular.copyWith(
                                        color: isHover
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                        fontSize: Dimensions.fontSizeLarge)),
                              ));
                        },
                      ),
                      // _isLoggedIn
                      Consumer<ProfileProvider>(
                        builder: (context, profileProvider, _) {
                          return _isLoggedIn
                              ? (!profileProvider.isLoading &&
                                      profileProvider.userInfoModel != null)
                                  ? Consumer<WalletProvider>(
                                      builder: (context, walletProvider, _) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(Images.loyal,
                                                width: 28, height: 28 ),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeSmall),
                                            profileProvider.isLoading
                                                ? const SizedBox()
                                                : CustomDirectionality(
                                                    child: Text(
                                                      '${profileProvider.userInfoModel?.point ?? 0}',
                                                      style: rubikBold.copyWith(
                                                        fontSize: Dimensions.fontSizeOverLarge,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        );
                                      },
                                    )
                                  : const SizedBox()
                              : const SizedBox();
                        },
                      ),

                      const Spacer(),
                      Container(
                        width: 450,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: Consumer<SearchProvider>(
                            builder: (context, search, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: CustomTextField(
                              hintText:
                                  getTranslated('search_items_here', context),
                              isShowBorder: true,
                              fillColor: Theme.of(context).canvasColor,
                              isShowSuffixIcon: true,
                              suffixIconUrl:
                                  search.searchController.text.isNotEmpty
                                      ? Images.close
                                      : Images.search,
                              onChanged: (str) {
                                str.length = 0;
                                search.getSearchText(str);
                              },
                              onSuffixTap: () {
                                if (search.searchController.text.isNotEmpty &&
                                    search.isSearch == true) {
                                  RouterHelper.getSearchResultRoute(
                                      search.searchController.text);

                                  search.searchDone();
                                } else if (search
                                        .searchController.text.isNotEmpty &&
                                    search.isSearch == false) {
                                  search.searchController.clear();
                                  search.getSearchText('');

                                  search.searchDone();
                                }
                              },
                              controller: search.searchController,
                              inputAction: TextInputAction.search,
                              isIcon: true,
                              onSubmit: (text) {
                                if (search.searchController.text.isNotEmpty) {
                                  // Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(search.searchController.text);
                                  // Provider.of<SearchProvider>(context,listen: false).searchProduct(search.searchController.text, context);
                                  RouterHelper.getSearchResultRoute(
                                      search.searchController.text);
                                  // RouterHelper.getSearchResultRoute(_searchController.text.replaceAll(' ', '-')));

                                  search.searchDone();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      InkWell(onTap: () {
                        RouterHelper.getDashboardRoute('cart');
                      }, child: OnHover(builder: (isHover) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraLarge),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Icon(Icons.shopping_cart,
                                size: Dimensions.paddingSizeExtraLarge,
                                color: isHover
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                            Positioned(
                              top: -7,
                              right: -7,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor),
                                child: Center(
                                  child: Text(
                                    Provider.of<CartProvider>(context)
                                        .cartList
                                        .length
                                        .toString(),
                                    style: rubikMedium.copyWith(
                                        color: Colors.white, fontSize: 8),
                                  ),
                                ),
                              ),
                            )
                          ]),
                        );
                      })),
                      OnHover(builder: (isHover) {
                        return InkWell(
                          onTap: () {
                            RouterHelper.getDashboardRoute('menu');
                          },
                          child: Icon(Icons.menu,
                              size: Dimensions.paddingSizeExtraLarge,
                              color: isHover
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color),
                        );
                      }),
                      OnHover(builder: (isHover) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeExtraLarge),
                          child: InkWell(
                            onTap: () {
                              RouterHelper.getProfileRoute();
                            },
                            child: Icon(Icons.account_circle,
                                size: Dimensions.paddingSizeExtraLarge,
                                color: isHover
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color),
                          ),
                        );
                      }),

                      // MenuModel(icon: Images.profile, title: getTranslated('profile', context), route:()=>  RouterHelper.getProfileRoute()),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // ignore: override_on_non_overriding_member
  Size get preferredSize => const Size(double.maxFinite, 50);
}
