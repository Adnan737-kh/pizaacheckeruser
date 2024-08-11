import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/price_converter.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/order_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_divider.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:provider/provider.dart';

class CostSummeryView extends StatelessWidget {
  final bool kmWiseCharge;
  final bool takeAway;
  final double? deliveryCharge;
  final double? subtotal;
  final double? walletPay;
  final double? remainingPay;
  final double distanceMinimumAmount;
  const CostSummeryView({
    Key? key, required
    this.kmWiseCharge,
    required this.takeAway,
    this.deliveryCharge,
    this.subtotal,
    this.walletPay,
    this.remainingPay,
    required this.distanceMinimumAmount,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider =  Provider.of<OrderProvider>(context, listen: false);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Column(children: [

          if(ResponsiveHelper.isDesktop(context)) Text(
            getTranslated('cost_summery', context)!,
            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          ItemView(
            title: getTranslated('subtotal', context)!,
            subTitle: PriceConverter.convertPrice(subtotal),
            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: 10),

         if(!takeAway) ItemView(
            title: getTranslated('delivery_fee', context)!,
            subTitle: (!takeAway || orderProvider.distance != -1) ?
            '(+) ${PriceConverter.convertPrice( takeAway ? 0 : deliveryCharge)}'
                : getTranslated('not_found', context)!,
          ),



          const Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: CustomDivider(),
          ),


          if ( subtotal! < distanceMinimumAmount)
            if(ResponsiveHelper.isDesktop(context))
              Center(
              child: Text('Minimum order amount should be ${PriceConverter.convertPrice(distanceMinimumAmount)} '
                ,style: rubikMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),),
            ),
          ItemView(
            title: getTranslated('total_amount', context)!,
            subTitle: PriceConverter.convertPrice(subtotal! + deliveryCharge!),
            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
          ),

          const SizedBox(height: 10),
          if(walletPay != null)
          ItemView(
            title: getTranslated('wallet_pay', context)!,
            subTitle: '(-) ${PriceConverter.convertPrice(walletPay ?? 0.0)}',
          ),

          const SizedBox(height: 10),
          if(walletPay != null)
          ItemView(
            title: getTranslated('remaining_Pay', context)!,
            subTitle: PriceConverter.convertPrice(remainingPay ?? subtotal),
          ),

          const SizedBox(height: 10),
          if(walletPay != null)
          ItemView(
            title: getTranslated('Total', context)!,
            subTitle: PriceConverter.convertPrice(remainingPay ?? subtotal),
            style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
          ),
        ]),
      ),

    ]);
  }
}
