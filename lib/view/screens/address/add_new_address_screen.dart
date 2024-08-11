import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/address_model.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/helper/responsive_helper.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/location_provider.dart';
import 'package:flutter_restaurant/provider/profile_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/color_resources.dart';
import 'package:flutter_restaurant/utill/dimensions.dart';
import 'package:flutter_restaurant/utill/images.dart';
import 'package:flutter_restaurant/utill/styles.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:flutter_restaurant/view/base/custom_button.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter_restaurant/view/base/custom_text_field.dart';
import 'package:flutter_restaurant/view/base/footer_view.dart';
import 'package:flutter_restaurant/view/base/web_app_bar.dart';
import 'package:flutter_restaurant/view/screens/address/select_location_screen.dart';
import 'package:flutter_restaurant/view/screens/auth/widget/code_picker_widget.dart';
import 'package:flutter_restaurant/view/screens/order/order_search_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/model/response/userinfo_model.dart';

class AddNewAddressScreen extends StatefulWidget {
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  const AddNewAddressScreen({Key? key, this.isEnableUpdate =
  false, this.address, this.fromCheckout = false}) : super(key: key);

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _florNumberController = TextEditingController();
  final TextEditingController _postelCodeController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationTextController = TextEditingController();


  final FocusNode _nameNode = FocusNode();
  final FocusNode _stateNode = FocusNode();
  // final FocusNode _houseNode = FocusNode();
  // final FocusNode _floorNode = FocusNode();
  // final FocusNode _postNode = FocusNode();
  // final FocusNode _cityNameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _emailNode = FocusNode();

  final List<Branches?> _branches = [];
  final List<String> _suggestions = [];
  late bool _isLoggedIn;
  GoogleMapController? _controller;
  CameraPosition? _cameraPosition;
  bool _updateAddress = true;
  String? countryCode;



  _initLoading() async {
    countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.countryCode!).code;
    final userModel =  Provider.of<ProfileProvider>(context, listen: false).userInfoModel;

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    _branches.addAll(Provider.of<SplashProvider>(context, listen: false).configModel!.branches!);
    Provider.of<LocationProvider>(context, listen: false).initializeAllAddressType(context: context);
    Provider.of<LocationProvider>(context, listen: false).updateAddressStatusMessage(message: '');
    Provider.of<LocationProvider>(context, listen: false).updateErrorMessage(message: '');
    if (widget.isEnableUpdate && widget.address != null) {
      String? code = CountryPick.getCountryCode('${widget.address!.contactPersonNumber}');
      if(code != null){
        countryCode =  CountryCode.fromDialCode(code).code;
      }
      _updateAddress = false;
      Provider.of<LocationProvider>(context, listen: false).
      updatePosition(CameraPosition(target: LatLng(double.parse(widget.address!.latitude!),
          double.parse(widget.address!.longitude!))), true, widget.address!.address, context, false);

      _contactPersonNameController.text = '${widget.address!.contactPersonName}';
      _contactPersonNumberController.text = code != null
          ? '${widget.address!.contactPersonNumber}'.replaceAll(code, '') :
      '${widget.address!.contactPersonNumber}';
      _streetNumberController.text = widget.address!.streetNumber ?? '';
      _houseNumberController.text = widget.address!.houseNumber ?? '';
      _florNumberController.text = widget.address!.floorNumber ?? '';
      _postelCodeController.text = widget.address!.postalCode ?? '';
      _cityNameController.text = widget.address!.cityName ?? '';
      if (widget.address!.addressType == 'Home') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(0, false);
      } else if (widget.address!.addressType == 'Workplace') {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(1, false);
      } else {
        Provider.of<LocationProvider>(context, listen: false).updateAddressIndex(2, false);
      }
    }else {
      if(authProvider.isLoggedIn()){
        String? code = CountryPick.getCountryCode(userModel?.phone);

        if(code != null){
          countryCode = CountryCode.fromDialCode(code).code;
        }

        _contactPersonNameController.text = '${userModel!.fName ?? ''}  ${userModel.lName ?? ''}';
        _contactPersonNumberController.text = (code != null ? (userModel.phone ?? '').replaceAll(code, '') : userModel.phone ?? '');
        _streetNumberController.text = widget.address!.streetNumber ?? '';
        _houseNumberController.text = widget.address!.houseNumber ?? '';
        _florNumberController.text = widget.address!.floorNumber ?? '';
        _postelCodeController.text = widget.address!.postalCode ?? '';
        _cityNameController.text = widget.address!.cityName ?? '';

      }


    }
  }

  @override
  void initState() {
    super.initState();
    _initLoading();

    if(widget.address != null && !widget.fromCheckout) {
      _locationTextController.text = widget.address!.address!;
    }

    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);

    _isLoggedIn = authProvider.isLoggedIn();
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    if(_isLoggedIn) {
      profileProvider.getUserInfo(true).then((_) {

        UserInfoModel? userInfoModel = profileProvider.userInfoModel;
        if(userInfoModel != null){
          _emailController.text = userInfoModel.email ?? '';
        }
      });
    }
  }

  Future<List<String>> fetchAddressSuggestions(String query) async {
    try {

      Map<String, dynamic> response = await fetchAddressSuggestionsFromLambda(query);

      if (response.containsKey('statusCode') && response['statusCode'] == 200) {
        List<String> suggestions = List<String>.from(response['body']);
        return suggestions;
      } else {
        throw Exception('Failed to fetch address suggestions: ${response['body']}');
      }
    } catch (e) {
      throw Exception('Failed to fetch address suggestions: $e');
    }
  }
  Future<Map<String, dynamic>> fetchAddressSuggestionsFromLambda(String query) async {
    try {
      final places = GoogleMapsPlaces(apiKey: 'AIzaSyDG2zq9-F7tw-lS1mr2i9fhoCagnZXMneo');

      PlacesAutocompleteResponse response = await places.autocomplete(
        query,
        language: 'de',
        components: [Component(Component.country, 'de')],
      );

      if (response.isOkay) {
        List<String> suggestions = response.predictions
            .where((prediction) => prediction.description != null)
            .map((prediction) => prediction.description!)
            .toList();

        // Construct the response with CORS headers
        return {
          'statusCode': 200,

          'headers': {
            "Access-Control-Allow-Origin": "*", // Required for CORS support to work
            "Access-Control-Allow-Credentials": true, // Required for cookies, authorization headers with HTTPS
            "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "POST, OPTIONS"
          },
          'body': suggestions,
        };
      } else {
        // Construct error response
        return {
          'statusCode': 500,
          'body': 'Failed to fetch address suggestions: ${response.errorMessage}',
        };
      }
    } catch (e) {
      // Construct error response
      return {
        'statusCode': 500,
        'body': 'Failed to fetch address suggestions: $e',
      };
    }
  }

  Future<Map<String, String>> getAddressDetails(String address) async {
    _cityNameController.clear();
    _streetNumberController.clear();
    _postelCodeController.clear();
    _houseNumberController.clear();
    String apiKey = 'AIzaSyDG2zq9-F7tw-lS1mr2i9fhoCagnZXMneo';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';
    // String url = 'https://backend.pizzachecker.xyz/api/v1/mapapi/place-api-autocomplete?search_text=$text';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List<dynamic> results = data['results'];
        if (results.isNotEmpty) {
          Map<String, dynamic> firstResult = results[0];
          List<dynamic> addressComponents = firstResult['address_components'];

          String city = '';
          String street = '';
          String postcode = '';
          String streetNumber = '';
          String house = '';
          double latitude = 0.0;
          double longitude = 0.0;

          for (var component in addressComponents) {

            List<dynamic> types = component['types'];
            String longName = component['long_name'];

            if (types.contains('locality')) {
              city = longName;
              _cityNameController.text = city;
            } else if (types.contains('route')) {
              street = address;
              _streetNumberController.text = street;
            } else if (types.contains('postal_code')) {
              postcode = longName;
              _postelCodeController.text = postcode;
            } else if (types.contains('street_number')) {
              streetNumber = longName;
              _houseNumberController.text = streetNumber;
            }
          }

          // Extract latitude and longitude
          Map<String, dynamic> geometry = firstResult['geometry'];
          Map<String, dynamic> location = geometry['location'];
          latitude = location['lat'];
          longitude = location['lng'];

          return {
            'city': city,
            'street': street,
            'postcode': postcode,
            'streetNumber': streetNumber,
            'house': house,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
          };
        }
      }
    }

    // Return empty values if address details couldn't be fetched
    return {
      'city': '',
      'street': '',
      'postcode': '',
      'streetNumber': '',
      'house': '',
      'latitude': '0.0',
      'longitude': '0.0',
    };
  }
  Future<String> getAddressFromLatLng(LatLng latLng) async {
    print('streetNumberController${_streetNumberController.text}');

    List<Placemark> placeMarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placeMarks.isNotEmpty) {
      Placemark place = placeMarks[0];
      String address = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";


      _streetNumberController.text = address;
      print('streetNumberController${_streetNumberController.text}');
      return address;
    } else {
      return "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar:(ResponsiveHelper.isDesktop(context) ?
      const PreferredSize(preferredSize:
      Size.fromHeight(100), child: WebAppBar())
          : CustomAppBar(context: context, title: widget.isEnableUpdate
          ? getTranslated('update_address', context) :
      getTranslated('add_new_address', context))) as PreferredSizeWidget?,
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(children: [
            Expanded(child: SingleChildScrollView(child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: !ResponsiveHelper.isDesktop(context) && height < 600 ? height : height - 400),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Center(
                      child: SizedBox(
                        width: 1170,
                        child: Column(
                          children: [
                            if(!ResponsiveHelper.isDesktop(context)) mapWidget(context),
                            // for label us
                            if(!ResponsiveHelper.isDesktop(context)) detailsWidget(context),
                            if(ResponsiveHelper.isDesktop(context))IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex : 6,
                                    child: mapWidget(
                                        context),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    flex: 4,
                                    child: detailsWidget(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if(ResponsiveHelper.isDesktop(context)) const FooterView(),
              ],
            ))),

            if(!ResponsiveHelper.isDesktop(context)) Column(children: [
              locationProvider.addressStatusMessage != null ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  locationProvider.addressStatusMessage!.isNotEmpty ? const CircleAvatar(backgroundColor: Colors.green, radius: 5) : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationProvider.addressStatusMessage ?? "",
                      style:
                      Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green, height: 1),
                    ),
                  )
                ],
              )
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  locationProvider.errorMessage!.isNotEmpty
                      ? CircleAvatar(backgroundColor: Theme.of(context).primaryColor, radius: 5)
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationProvider.errorMessage ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor, height: 1),
                    ),
                  )
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              if(!ResponsiveHelper.isDesktop(context)) saveButtonWidget(context),
            ],)

          ]);
        },
      ),
    );
  }

  Widget saveButtonWidget(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeExtraSmall),
          child: SizedBox(
            height: 50.0,
            width: 1170,
            child: !locationProvider.isLoading ? CustomButton(
              btnTxt: widget.isEnableUpdate ?
              getTranslated('update_address', context)
                  : getTranslated('save_location', context),

              onTap: locationProvider.loading ? null : () {
                List<Branches?> branches = Provider.of<SplashProvider>(context, listen: false)
                    .configModel!.branches!;
                bool isAvailable = branches.length == 1 &&
                    (branches[0]!.latitude == null || branches[0]!.latitude!.isEmpty);
                if(!isAvailable) {
                  for (Branches? branch in branches) {
                    double distance = Geolocator.distanceBetween(
                      double.parse(branch!.latitude!), double.parse(branch.longitude!),
                      locationProvider.position.latitude, locationProvider.position.longitude,
                    ) / 1000;
                    if (distance < branch.coverage!) {
                      isAvailable = true;
                      break;
                    }
                  }
                }
                if(!isAvailable) {
                  showCustomSnackBar(getTranslated('service_is_not_available', context));
                }else {
                  print('email is ${_emailController.text}');
                  AddressModel addressModel = AddressModel(
                    addressType: locationProvider.getAllAddressType[locationProvider.selectAddressIndex],
                    contactPersonName: _contactPersonNameController.text,
                    contactPersonNumber: _contactPersonNumberController.text.trim().isEmpty ? ''
                        : '${CountryCode.fromCountryCode(countryCode!).dialCode}${_contactPersonNumberController.text.trim()}',
                    address: _locationTextController.text,
                    latitude: widget.isEnableUpdate ? locationProvider.position.latitude.toString()
                        : locationProvider.position.latitude.toString(),
                    longitude: locationProvider.position.longitude.toString(),
                    floorNumber: _florNumberController.text,
                    houseNumber: _houseNumberController.text,
                    streetNumber: _streetNumberController.text,
                    cityName: _cityNameController.text,
                    email: _emailController.text,
                    postalCode: _postelCodeController.text);

                  if (widget.isEnableUpdate) {
                    addressModel.id = widget.address!.id;
                    addressModel.userId = widget.address!.userId;
                    addressModel.method = 'put';
                    locationProvider.updateAddress(context, addressModel: addressModel, addressId: addressModel.id).then((value) {
                      if(value.isSuccess){
                        context.pop();
                      }

                    });
                  } else {
                    locationProvider.addAddress(addressModel).then((value) {
                      if (value.isSuccess) {
                        context.pop();
                        if (widget.fromCheckout) {
                          Provider.of<LocationProvider>(context, listen: false).initAddressList();
                          // Provider.of<OrderProvider>(context, listen: false).setAddressIndex(-1);
                        } else {
                          showCustomSnackBar(value.message, isError: false);
                        }

                      } else {
                        showCustomSnackBar(value.message);
                      }
                    });
                  }
                }

              },
            ) : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                )),
          ),
        );
      }
    );
  }

  Container mapWidget(BuildContext context) {
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ?  BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:ColorResources.cardShadowColor.withOpacity(0.2),
              blurRadius: 10,
            )
          ]
      ) : const BoxDecoration(),
      //margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeLarge),
      padding: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: ResponsiveHelper.isMobile() ? 130 : 250,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  child: Stack(
                    clipBehavior: Clip.none, children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: widget.isEnableUpdate
                            ? LatLng(double.parse(widget.address!.latitude!), double.parse(widget.address!.longitude!))
                            : LatLng(locationProvider.position.latitude  == 0.0 ? double.parse(_branches[0]!.latitude!)
                            : locationProvider.position.latitude, locationProvider.position.longitude == 0.0? double.parse(_branches[0]!.longitude!)
                            : locationProvider.position.longitude),
                        zoom: 8,
                      ),
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: false,
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      onCameraIdle: () {
                        if(widget.address != null && !widget.fromCheckout) {
                          locationProvider.updatePosition(_cameraPosition, true, null, context, true);
                          _updateAddress = true;
                        }else {
                          if(_updateAddress) {
                            locationProvider.updatePosition(_cameraPosition, true, null, context, true);
                          }else {
                            _updateAddress = true;
                          }
                        }
                      },
                      onCameraMove: ((position) => _cameraPosition = position),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        if (!widget.isEnableUpdate && _controller != null) {
                          // locationProvider.checkPermission(() {
                          //   locationProvider.getCurrentLocation(context, true, mapController: _controller);
                          // }, context);
                        }
                      },
                    ),
                    locationProvider.loading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme
                        .of(context).primaryColor))) : const SizedBox(),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height,
                        child: Image.asset(
                          Images.marker,
                          width: 25,
                          height: 35,
                        )),
                    Positioned(
                      bottom: 10,
                      right: 0,
                      child: InkWell(
                        onTap: () => locationProvider.checkPermission(() async{
                          locationProvider.getCurrentLocation(context, true, mapController: _controller);
                          LatLng currentLatLng = LatLng(locationProvider.position.latitude,
                              locationProvider.position.longitude);
                         await getAddressFromLatLng(currentLatLng);
                        }, context),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 0,
                      child: InkWell(
                         onTap:()=> Navigator.of(context).push(MaterialPageRoute(
                           builder: (context) => SelectLocationScreen(googleMapController: _controller),
                         )),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                    child: Text(
                      getTranslated('add_the_location_correctly', context)!,
                      style:
                      Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.fontSizeSmall),
                    )),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  getTranslated('label_us', context)!,
                  style:
                  Theme.of(context).textTheme.displaySmall!.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  // physics: BouncingScrollPhysics(),
                  itemCount: locationProvider.getAllAddressType.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      locationProvider.updateAddressIndex(index, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeLarge),
                      margin: const EdgeInsets.only(right: 17),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeSmall,
                          ),
                          border: Border.all(
                              color:
                              locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : ColorResources.borderColor),
                          color: locationProvider.selectAddressIndex == index ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.8)),
                      child: Text(
                        getTranslated(locationProvider.getAllAddressType[index].toLowerCase(), context)!,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: locationProvider.selectAddressIndex == index ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget detailsWidget(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        _locationTextController.text = locationProvider.address!;
        return Container(
          decoration: ResponsiveHelper.isDesktop(context) ?  BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color:ColorResources.cardShadowColor.withOpacity(0.2),
                  blurRadius: 10,
                )
              ]
          ) : const BoxDecoration(),

          padding: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall,
          ) : EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                child: Text(
                  getTranslated('delivery_address', context)!,
                  style:
                  Theme.of(context).textTheme.displaySmall!.copyWith(color: ColorResources.getGreyBunkerColor(context), fontSize: Dimensions.fontSizeLarge),
                ),
              ),

              // for Contact Person Name
              Text(
                getTranslated('contact_person_name', context)!,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                hintText: getTranslated('enter_contact_person_name', context),
                isShowBorder: true,
                inputType: TextInputType.name,
                controller: _contactPersonNameController,
                focusNode: _nameNode,
                nextFocus: _stateNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
              ),
              // const SizedBox(height: Dimensions.paddingSizeLarge),
              //
              // const SizedBox(height: Dimensions.paddingSizeSmall),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              // Text(
              //   '${getTranslated('house', context)} / ${
              //       getTranslated('floor', context)} ${
              //       getTranslated('number', context)}',
              //   style: poppinsRegular.copyWith(color: ColorResources.getHintColor(context)),
              // ),
              Row(
                children: [
                  Text(
                    '${getTranslated('address_title', context)} ',
                    style: poppinsRegular.copyWith(color: ColorResources.getHintColor(context)),
                  ),
                  // const Spacer(),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 8.0),
                  //   child: Text(
                  //     '${getTranslated('house', context)} ${getTranslated('number', context)}',
                  //     style: poppinsRegular.copyWith(color: ColorResources.getHintColor(context)),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: Scrollable(viewportBuilder: (context, _)=>
                      Container(
                        alignment: Alignment.topCenter,
                        child: Material(

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                              )
                          ),
                          child: SizedBox(width: 1170, child: TypeAheadField(
                            textFieldConfiguration: TextFieldConfiguration(
                              cursorColor:Theme.of(context).primaryColor,
                              controller: _streetNumberController,
                              textInputAction: TextInputAction.search,
                              autofocus: true,
                              textAlign: TextAlign.start,
                              textCapitalization: TextCapitalization.words,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                hintText: getTranslated('address1', context),

                                hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                                  fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16,horizontal: 22),

                              ),
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                            suggestionsCallback: (pattern) async {
                              return await Provider.of<LocationProvider>(context,
                                  listen: false).searchLocation(context, pattern);
                            },
                            itemBuilder: (context, Prediction suggestion) {
                              return Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Row(children: [
                                  const Icon(Icons.location_on),
                                  Expanded(
                                    child: Text(suggestion.description!, maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                          color: Theme.of(context).textTheme.bodyLarge!.color, fontSize
                                            : Dimensions.fontSizeSmall,
                                        )),
                                  ),
                                ]),
                              );
                            },
                            onSuggestionSelected: (Prediction suggestion) async{
                              await getAddressDetails(suggestion.description!);
                              Map<String, String> addressDetails = await getAddressDetails(suggestion.description!);

                              // Check if address details are available and the map controller is not null
                              if (addressDetails.isNotEmpty && _controller != null) {
                                _streetNumberController.clear();
                                // Extract latitude and longitude from address details
                                double latitude = double.parse(addressDetails['latitude'] ?? '0.0');
                                double longitude = double.parse(addressDetails['longitude'] ?? '0.0');

                                // Update the Google Map with the new address details
                                _controller?.animateCamera(
                                  CameraUpdate.newLatLng(
                                    LatLng(latitude, longitude),
                                  ),
                                );
                                _streetNumberController.text =suggestion.description!;

                                _suggestions.clear();
                              }
                            },
                          )),
                        ),
                      )),
                ),

                // const SizedBox(width: Dimensions.paddingSizeLarge),
                //
                // Expanded(
                //   child: CustomTextField(
                //     hintText: getTranslated('ex_2', context),
                //     isShowBorder: true,
                //     inputType: TextInputType.streetAddress,
                //     inputAction: TextInputAction.next,
                //     focusNode: _houseNode,
                //     nextFocus: _floorNode,
                //     controller: _houseNumberController,
                //   ),
                // ),
              ],),
              // const SizedBox(height: Dimensions.paddingSizeLarge),

              // Row(
              //   children: [
              //     Text(
              //       '${getTranslated('postel_Code', context)} ',
              //       style: poppinsRegular.copyWith(color: ColorResources.getHintColor(context)),
              //     ),
              //     const Spacer(),
              //     Padding(
              //       padding: const EdgeInsets.only(right: 25.0),
              //       child: Text(
              //         '${getTranslated('name_of_city', context)} ',
              //         style: poppinsRegular.copyWith(color: ColorResources.getHintColor(context)),
              //       ),
              //     ),
              //   ],
              // ),
              //
              // const SizedBox(height: Dimensions.paddingSizeSmall),
              // Row(children: [
              //   Expanded(
              //     child: CustomTextField(
              //       hintText: getTranslated('ex_2', context),
              //       isShowBorder: true,
              //       inputType: TextInputType.streetAddress,
              //       inputAction: TextInputAction.next,
              //       focusNode: _postNode,
              //       nextFocus: _cityNameNode,
              //       controller: _postelCodeController,
              //     ),
              //   ),
              //
              //   const SizedBox(width: Dimensions.paddingSizeLarge),
              //
              //   Expanded(
              //     child: CustomTextField(
              //       hintText: getTranslated('ex_2b', context),
              //       isShowBorder: true,
              //       inputType: TextInputType.streetAddress,
              //       inputAction: TextInputAction.next,
              //       focusNode: _cityNameNode,
              //       nextFocus: _numberNode,
              //       controller: _cityNameController,
              //     ),
              //   ),
              //
              // ],),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // for Contact Person Number
              Text(
                getTranslated('contact_person_number', context)!,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: ColorResources.getHintColor(context)),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              PhoneNumberFieldView(
                onValueChange: (code){
                  countryCode = code;
                },
                countryCode: countryCode,
                phoneNumberTextController: _contactPersonNumberController,
                phoneFocusNode: _numberNode,
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // for Email Person Contact
              Text(
                getTranslated('Email', context)!,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                hintText: 'Email',
                isShowBorder: true,
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                focusNode: _emailNode,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.words,
              ),

              // for Address Field
              // Text(
              //   getTranslated('address_line_01', context)!,
              //   style: Theme.of(context).textTheme.displayMedium!.copyWith(color: ColorResources.getHintColor(context)),
              // ),
              // const SizedBox(height: Dimensions.paddingSizeSmall),
              // CustomTextField(
              //   hintText: getTranslated('address_line_02', context),
              //   isShowBorder: true,
              //   inputType: TextInputType.streetAddress,
              //   inputAction: TextInputAction.next,
              //   focusNode: _addressNode,
              //   nextFocus: _nameNode,
              //   controller: _locationTextController,
              // ),
              // const SizedBox(height: Dimensions.paddingSizeLarge),


              const SizedBox(height: Dimensions.paddingSizeLarge),

              const SizedBox(
                height: Dimensions.paddingSizeDefault,
              ),
              if(ResponsiveHelper.isDesktop(context)) saveButtonWidget(context),
            ],
          ),
        );
      }
    );
  }
}
