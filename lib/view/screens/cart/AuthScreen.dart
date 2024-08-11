import 'package:flutter/material.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:provider/provider.dart';

import '../../../helper/price_converter.dart';
import '../../../helper/responsive_helper.dart';
import '../../../helper/router_helper.dart';
import '../../../localization/language_constrants.dart';
import '../../../provider/coupon_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/splash_provider.dart';
import '../../base/custom_button.dart';
import '../../base/custom_snackbar.dart';
import '../../base/web_app_bar.dart';
import '../auth/create_account_screen.dart';
import '../auth/login_screen.dart';

class AuthScreen extends StatelessWidget {
  final double orderAmount;
  final double totalWithoutDeliveryFee;

  const AuthScreen(
      {Key? key, required this.orderAmount,
        required this.totalWithoutDeliveryFee}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Scaffold(
        appBar: (ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar())
            : CustomAppBar(context: context,
            isBackButtonExist: true,
            onBackPressed: () {
              Navigator.of(context).pop(); // Handle back press action here
            },
            title: '')) as PreferredSizeWidget?,
        body: Container(
          margin: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                  height: 250,
                  width: 250,
                  child: Image.asset('assets/image/logo.png')),
              const SizedBox(height: 36),
              CustomButton(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return  CreateAccountScreen(
                        totalWithoutDeliveryFee: totalWithoutDeliveryFee,
                        isCart: 'cart',
                      );
                    },
                  ));
                },
                backgroundColor: Theme.of(context).primaryColor,
                btnTxt: getTranslated('signup', context),
              ),
              const SizedBox(height: 16),
              CustomButton(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return  LoginScreen(
                        totalWithoutDeliveryFee: totalWithoutDeliveryFee,
                        isCart: 'cart',
                      );
                    },
                  ));
                },
                btnTxt: getTranslated('login', context),
              ),
              const SizedBox(height: 16),
              CustomButton(
                onTap: () {
                  if (orderAmount <
                      Provider.of<SplashProvider>(context,
                          listen: false).configModel!.minimumOrderValue!) {
                    // Show a snack-bar indicating that the order amount is insufficient
                    showCustomSnackBar(
                        'Minimum order amount is '
                            '${PriceConverter.convertPrice(
                            Provider.of<SplashProvider>(context, listen: false).configModel!.minimumOrderValue)}, you have '
                            '${PriceConverter.convertPrice(orderAmount)} '
                            'in your cart, please add more items.'
                    );
                  } else {
                    // Navigate to the checkout screen
                    RouterHelper.getCheckoutRoute(
                      totalWithoutDeliveryFee,
                      'cart',
                      Provider.of<OrderProvider>(context, listen: false).orderType,
                      Provider.of<CouponProvider>(context, listen: false).code,
                    );
                  }
                },
                btnTxt: '${getTranslated('continue_as_a', context)} ${getTranslated('guest', context)}',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
