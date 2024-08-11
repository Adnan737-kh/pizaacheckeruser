import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/screens/cart/cart_screen.dart';
import 'package:provider/provider.dart';
import '../../../data/model/response/order_details_model.dart';
import '../../../helper/responsive_helper.dart';
import '../../../localization/language_constrants.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/splash_provider.dart';
import '../../../utill/dimensions.dart';
import '../../base/custom_app_bar.dart';
import '../../base/custom_text_field.dart';
import '../../base/web_app_bar.dart';
import '../order/order_search_screen.dart';

class TakeAwayInfo extends StatefulWidget {
  const TakeAwayInfo({Key? key}) : super(key: key);

  @override
  State<TakeAwayInfo> createState() => _TakeAwayInfoState();
}

class _TakeAwayInfoState extends State<TakeAwayInfo> {
  String? countryCode;
  late OrderDetailsModel orderDetailsModel;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();

  final FocusNode _stateNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _nameNode = FocusNode();

  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form

  @override
  void initState() {
    countryCode = CountryCode.fromCountryCode(
      Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!,
    ).code;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactPersonNumberController.dispose();
    _contactPersonNameController.dispose();
    _stateNode.dispose();
    _emailNode.dispose();
    _numberNode.dispose();
    _nameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: WebAppBar(),
      )
          : CustomAppBar(
        context: context,
        onBackPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ),
          );
        },
        title: getTranslated('take_away', context),
        isBackButtonExist: true,
      )) as PreferredSizeWidget?,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            children: [
              const SizedBox(height: Dimensions.fontSizeExtraLarge),
              CustomTextField(
                hintText: getTranslated('enter_contact_person_name', context),
                isShowBorder: true,
                inputType: TextInputType.name,
                controller: _contactPersonNameController,
                focusNode: _nameNode,
                nextFocus: _stateNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact person name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.fontSizeLarge),
              CustomTextField(
                hintText: 'Email',
                isShowBorder: true,
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                focusNode: _emailNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  } else if (!isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.fontSizeLarge),
              PhoneNumberFieldView(
                onValueChange: (code) {
                  countryCode = code;
                  Provider.of<OrderProvider>(context, listen: false).addTakeAwayInfo({
                    'countryCode': countryCode!,
                  });
                },
                countryCode: countryCode,
                phoneNumberTextController: _contactPersonNumberController,
                phoneFocusNode: _numberNode,
                onValidate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(
                  btnTxt: getTranslated('save', context),
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

                      Map<String, String> takeAwayInfo = {
                        'name': _contactPersonNameController.text,
                        'email': _emailController.text,
                        'phone': (countryCode ?? '') + _contactPersonNumberController.text
                      };

                      orderProvider.addTakeAwayInfo(takeAwayInfo);

                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String value) {
    // Simple email validation
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }
}
