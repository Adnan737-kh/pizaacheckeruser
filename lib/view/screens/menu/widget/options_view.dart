import 'package:flutter/material.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/provider/theme_provider.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/screens/menu/widget/sign_out_confirmation_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../base/custom_dialog.dart';

class OptionsView extends StatelessWidget {
  final Function? onTap;
  const OptionsView({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final policyModel = Provider.of<SplashProvider>(context, listen: false).policyModel;
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Consumer<AuthProvider>(builder: (context, authProvider, _)=> SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: SizedBox(
          width: ResponsiveHelper.isTab(context) ? null : 1170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: ResponsiveHelper.isTab(context) ? 50 : 0),

              SwitchListTile(
                value: Provider.of<ThemeProvider>(context).darkTheme,
                onChanged: (bool isActive) =>Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                title: Text(getTranslated('dark_theme', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                activeColor: Theme.of(context).primaryColor,
              ),

              ResponsiveHelper.isTab(context) ? ListTile(
                onTap: () => RouterHelper.getDashboardRoute('home'),
                leading: Image.asset(Images.home, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('home', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ) : const SizedBox(),

              ListTile(
                onTap: () => ResponsiveHelper.isMobilePhone() ? onTap!(2) : RouterHelper.getDashboardRoute('order'),
                leading: Image.asset(Images.order, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('my_order', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              ListTile(
                onTap: () => RouterHelper.getOrderSearchScreen(),
                leading: Image.asset(Images.trackOrder, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('order_details', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              ListTile(
                onTap: () => RouterHelper.getNotificationRoute(),
                leading: Image.asset(Images.notification, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('notification', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),


              // if(!kIsWeb) ListTile(
              //   onTap: () => Get.navigator!.push(MaterialPageRoute(builder: (context) => const ScannerScreen())),
              //   leading: Image.asset(Images.scanner, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
              //   title: Text(getTranslated('qr_scan', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              // ),

              ListTile(
                onTap: () => RouterHelper.getProfileRoute(),
                leading: Image.asset(Images.profile, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('profile', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getAddressRoute(),
                leading: Image.asset(Images.location, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('address', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getChatRoute(orderModel: null),
                leading: Image.asset(Images.message, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('message', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getCouponRoute(),
                leading: Image.asset(Images.coupon, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('coupon', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ResponsiveHelper.isDesktop(context) ? ListTile(
                onTap: () => RouterHelper.getNotificationRoute(),
                leading: Image.asset(Images.notification, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('notifications', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ) : const SizedBox(),
              ListTile(
                onTap: () => RouterHelper.getLanguageRoute(true),
                leading: Image.asset(Images.language, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('language', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getSupportRoute(),
                leading: SizedBox(width:20,height: 20,child: Image.asset(Images.helpSupport,color: Theme.of(context).textTheme.bodyLarge?.color)),
                title: Text(getTranslated('help_and_support', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getPolicyRoute(),
                leading: SizedBox(width:20,height: 20,child: Image.asset(Images.privacyPolicy,color: Theme.of(context).textTheme.bodyLarge?.color,)),
                title: Text(getTranslated('privacy_policy', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              ListTile(
                onTap: () => RouterHelper.getTermsRoute(),
                leading: SizedBox(width:20,height: 20,child: Image.asset(Images.termsAndCondition,color: Theme.of(context).textTheme.bodyLarge?.color,)),
                title: Text(getTranslated('terms_and_condition', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              if(policyModel != null && policyModel.returnPage != null && policyModel.returnPage!.status!) ListTile(
                onTap: () =>  RouterHelper.getReturnPolicyRoute(),
                leading: Image.asset(Images.returnPolicy, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('return_policy', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              if(policyModel != null && policyModel.refundPage != null  && policyModel.refundPage!.status!) ListTile(
                onTap: () => RouterHelper.getRefundPolicyRoute(),
                leading: Image.asset(Images.refundPolicy, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('refund_policy', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
              if(policyModel != null && policyModel.cancellationPage != null  && policyModel.cancellationPage!.status!) ListTile(
                onTap: () => RouterHelper.getCancellationPolicyRoute(),
                leading: Image.asset(Images.cancellationPolicy, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('cancellation_policy', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              ListTile(
                onTap: () => RouterHelper.getAboutUsRoute(),
                leading: SizedBox(width:20,height: 20,child: Image.asset(Images.aboutUs,color: Theme.of(context).textTheme.bodyLarge!.color)),
                title: Text(getTranslated('about_us', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              if(configModel.referEarnStatus! && authProvider.isLoggedIn()) Consumer<ProfileProvider>(
                  builder: (context, profileProvider, _) {
                    return profileProvider.userInfoModel != null && profileProvider.userInfoModel!.referCode != null ? ListTile(
                      onTap: () => RouterHelper.getReferAndEarnRoute(),
                      leading: Image.asset(Images.referralIcon, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                      title: Text(getTranslated('refer_and_earn', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ) : const SizedBox() ;
                  }
              ),

              if(configModel.walletStatus!) ListTile(
                onTap: () => RouterHelper.getWalletRoute(true),
                leading: Image.asset(Images.wallet, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('wallet', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              if(configModel.loyaltyPointStatus!) ListTile(
                onTap: () => RouterHelper.getLoyaltyScreen(),
                leading: Image.asset(Images.loyaltyIcon, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
                title: Text(getTranslated('loyalty_point', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

              // ListTile(
              //   leading: Image.asset(Images.version, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
              //   title: Text('${getTranslated('version', context)}', style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              //   trailing: Text(Provider.of<SplashProvider>(context, listen: false).configModel!.softwareVersion ?? AppConstants.appVersion, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              //   //
              // ),

              authProvider.isLoggedIn() ? ListTile(
                onTap: () {
                  showAnimatedDialog(context,
                      Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return WillPopScope(
                                onWillPop: () async => !authProvider.isLoading,
                                child: authProvider.isLoading ? const Center(child: CircularProgressIndicator()) : CustomDialog(
                                  icon: Icons.question_mark_sharp,
                                  title: getTranslated('are_you_sure_to_delete_account', context),
                                  description: getTranslated('it_will_remove_your_all_information', context),
                                  buttonTextTrue: getTranslated('yes', context),
                                  buttonTextFalse: getTranslated('no', context),
                                  onTapTrue: () => Provider.of<AuthProvider>(context, listen: false).deleteUser(),
                                  onTapFalse: () => context.pop(),
                                )
                            );
                          }
                      ),
                      dismissible: false,
                      isFlip: true);
                },
                leading: Icon(Icons.delete_outline, size: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated('delete_account', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ) : const SizedBox(),

              ListTile(
                onTap: () {
                  if(authProvider.isLoggedIn()) {
                    showDialog(context: context, barrierDismissible: false, builder: (context) => const SignOutConfirmationDialog());
                  }else {
                    RouterHelper.getLoginRoute();
                  }
                },
                leading: Image.asset(Images.login, width: 20, height: 20, color: Theme.of(context).textTheme.bodyLarge!.color),
                title: Text(getTranslated(authProvider.isLoggedIn() ? 'logout' : 'login', context)!, style: rubikMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),

            ],
          ),
        ),
      ),
    ));
  }
}
