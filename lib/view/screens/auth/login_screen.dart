import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/user_log_data.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/code_picker_widget.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/social_login_widget.dart';
import 'package:provider/provider.dart';

import '../../../provider/coupon_provider.dart';
import '../../../provider/order_provider.dart';
import '../../base/custom_app_bar.dart';

class LoginScreen extends StatefulWidget {
  final double? totalWithoutDeliveryFee;
  final String? isCart;

  const LoginScreen({Key? key, this.totalWithoutDeliveryFee,this.isCart}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FocusNode _emailNumberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  String? countryCode;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // print('my cart value is here${widget.isCart}');

    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    final AuthProvider authProvider =  Provider.of<AuthProvider>(context, listen: false);

    authProvider.setIsLoading = false;
    authProvider.setIsPhoneVerificationButttonLoading = false;
    UserLogData? userData = authProvider.getUserData();

    if(userData != null) {
      if(configModel.emailVerification!){
        _emailController!.text = userData.email ?? '';
      }else if(userData.phoneNumber != null){
        _emailController!.text = userData.phoneNumber!;
      }
      if(countryCode != null){
        countryCode = userData.countryCode;
      }
      _passwordController!.text = userData.password ?? '';
    }

    countryCode ??= CountryCode.fromCountryCode(configModel.countryCode!).dialCode;

  }

  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final double width = MediaQuery.of(context).size.width;
   final configModel = Provider.of<SplashProvider>(context,listen: false).configModel!;

   final socialStatus = configModel.socialLoginStatus;

    return Scaffold(
      appBar:(ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(100), child: WebAppBar())
          : CustomAppBar(context: context,
          isBackButtonExist: (widget.isCart == 'cart')? true : false,
          onBackPressed: () {
            Navigator.of(context).pop(); // Handle back press action here
          },
          title: '')) as PreferredSizeWidget?,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Center(
                  child: Container(
                    width: width > 700 ? 700 : width,
                    padding: width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
                    decoration: width > 700 ? BoxDecoration(
                      color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Theme.of(context).shadowColor, blurRadius: 5, spreadRadius: 1)],
                    ) : null,
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) => Form(
                        key: _formKeyLogin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.asset(
                                  Images.logo,
                                  height: MediaQuery.of(context).size.height / 4.5,
                                  fit: BoxFit.scaleDown,
                                  matchTextDirection: true,
                                ),
                              ),
                            ),
                            Center(
                                child: Text(
                              getTranslated('login', context)!,
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 24, color: ColorResources.getGreyBunkerColor(context)),
                            )),
                            const SizedBox(height: 35),
                            Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!?
                            Text(
                              getTranslated('email', context)!,
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                            ):Text(
                              getTranslated('mobile_number', context)!,
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!?
                            CustomTextField(
                              hintText: getTranslated('demo_gmail', context),
                              isShowBorder: true,
                              focusNode: _emailNumberFocus,
                              nextFocus: _passwordFocus,
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                            ):
                            Row(children: [
                              CodePickerWidget(
                                onChanged: (CountryCode value) {
                                  countryCode = value.dialCode;
                                  },
                                initialSelection: countryCode,
                                favorite: [countryCode ?? ''],
                                showDropDownButton: true,
                                padding: EdgeInsets.zero,
                                showFlagMain: true,
                                textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),

                              ),
                              Expanded(child: CustomTextField(
                                hintText: getTranslated('number_hint', context),
                                isShowBorder: true,
                                focusNode: _emailNumberFocus,
                                nextFocus: _passwordFocus,
                                controller: _emailController,
                                inputType: TextInputType.phone,
                              )),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Text(
                              getTranslated('password', context)!,
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            CustomTextField(
                              hintText: getTranslated('password_hint', context),
                              isShowBorder: true,
                              isPassword: true,
                              isShowSuffixIcon: true,
                              focusNode: _passwordFocus,
                              controller: _passwordController,
                              inputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 22),

                            // for remember me section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: ()=> authProvider.toggleRememberMe(),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                            color: authProvider.isActiveRememberMe ? Theme.of(context).primaryColor : Colors.white,
                                            border:
                                            Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : Theme.of(context).primaryColor),
                                            borderRadius: BorderRadius.circular(3)),
                                        child: authProvider.isActiveRememberMe
                                            ? const Icon(Icons.done, color: Colors.white, size: 17)
                                            : const SizedBox.shrink(),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      Text(
                                        getTranslated('remember_me', context)!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: ColorResources.getHintColor(context)),
                                      )
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                     RouterHelper.getForgetPassRoute();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getTranslated('forgot_password', context)!,
                                      style:
                                          Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: Dimensions.fontSizeSmall, color: ColorResources.getHintColor(context)),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(height: 22),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                authProvider.loginErrorMessage!.isNotEmpty
                                    ? CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 5)
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.loginErrorMessage ?? "",
                                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                  ),
                                )
                              ],
                            ),

                            // for login button
                            const SizedBox(height: 10),
                            !authProvider.isLoading && !authProvider.isPhoneNumberVerificationButtonLoading                                ? CustomButton(
                              btnTxt: getTranslated('login', context),
                              onTap: () async {

                                String email = _emailController!.text.trim();

                                if(!Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!){
                                  email = countryCode! + _emailController!.text.trim();
                                }


                                String password = _passwordController!.text.trim();
                                if (_emailController!.text.isEmpty) {
                                  if(Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!){
                                    showCustomSnackBar(getTranslated('enter_email_address', context));
                                  }else {
                                    showCustomSnackBar(getTranslated('enter_phone_number', context));
                                  }
                                }else if (password.isEmpty) {
                                  showCustomSnackBar(getTranslated('enter_password', context));
                                }else if (password.length < 6) {
                                  showCustomSnackBar(getTranslated('password_should_be', context));
                                }else {

                                  await authProvider.login(email, password).then((status) async {
                                    if (status.isSuccess) {


                                      if (authProvider.isActiveRememberMe) {
                                        authProvider.saveUserNumberAndPassword(UserLogData(
                                          countryCode:  countryCode,
                                          phoneNumber: configModel.emailVerification! ? null : _emailController!.text,
                                          email: configModel.emailVerification! ? _emailController!.text : null,
                                          password: password,
                                        ));

                                      } else {
                                        authProvider.clearUserLogData();
                                      }
                                      if(widget.isCart != null && widget.isCart == 'cart'){

                                        RouterHelper.getCheckoutRoute(
                                          widget.totalWithoutDeliveryFee,
                                          'cart',
                                          Provider.of<OrderProvider>(context, listen: false).orderType,
                                          Provider.of<CouponProvider>(context, listen: false).code,

                                        );
                                      }else{
                                        RouterHelper.getMainRoute(action: RouteAction.pushNamedAndRemoveUntil);

                                      }

                                    }
                                  });
                                }
                              },
                            )
                                : Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                )),
                            const SizedBox(height: 20),

                            InkWell(
                              onTap: ()=> RouterHelper.getCreateAccountRoute(),
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      getTranslated('create_an_account', context)!,
                                      style:
                                      Theme.of(context).textTheme.displayMedium!.copyWith(fontSize:
                                      Dimensions.fontSizeSmall, color: Theme.of(context).hintColor.withOpacity(0.7)),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                    Text(
                                      getTranslated('signup', context)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(fontSize: Dimensions.fontSizeSmall, color: ColorResources.getGreyBunkerColor(context)),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if(socialStatus!.isFacebook! || socialStatus.isGoogle!)
                              const Center(child: SocialLoginWidget()),

                            Center(child: Text(getTranslated('OR', context)!, style: poppinsRegular.copyWith(fontSize: 12))),

                            Center(
                              child: InkWell(
                                onTap: () {
                                  RouterHelper.getDashboardRoute('home', );
                                },
                                child: RichText(text: TextSpan(children: [
                                  TextSpan(text: '${getTranslated('continue_as_a', context)} ',
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                          color: ColorResources.getHintColor(context))),
                                  TextSpan(text: getTranslated('guest', context),
                                      style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                                ])),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if(ResponsiveHelper.isDesktop(context)) const FooterView(),
            ],
          ),
        ),
      ),
    );
  }
}
