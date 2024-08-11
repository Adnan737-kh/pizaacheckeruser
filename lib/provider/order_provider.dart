import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/body/place_order_body.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/config_model.dart';
import 'package:flutter_restaurant/data/model/response/delivery_man_model.dart';
import 'package:flutter_restaurant/data/model/response/distance_model.dart';
import 'package:flutter_restaurant/data/model/response/offline_payment_model.dart';
import 'package:flutter_restaurant/data/model/response/order_details_model.dart';
import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/data/model/response/response_model.dart';
import 'package:flutter_restaurant/data/model/response/timeslote_model.dart';
import 'package:flutter_restaurant/data/repository/order_repo.dart';
import 'package:flutter_restaurant/helper/api_checker.dart';
import 'package:flutter_restaurant/helper/date_converter.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/auth_provider.dart';
import 'package:flutter_restaurant/provider/splash_provider.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderProvider extends ChangeNotifier {
  final OrderRepo? orderRepo;
  final SharedPreferences? sharedPreferences;

  OrderProvider({ required this.sharedPreferences,required this.orderRepo});

  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  int? _paymentMethodIndex;
  OrderModel? _trackModel;
  ResponseModel? _responseModel;
  int _addressIndex = -1;
  bool _isLoading = false;
  bool _showCancelled = false;
  DeliveryManModel? _deliveryManModel;
  String? _orderType = 'delivery';
  int _branchIndex = 0;
  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? _allTimeSlots;
  int _selectDateSlot = 0;
  int _selectTimeSlot = 0;
  double _distance = -1;
  final double _minimumAmount = 0;
  bool _isRestaurantCloseShow = true;
  PaymentMethod? _paymentMethod;
  PaymentMethod? _selectedPaymentMethod;
  double? _partialAmount;
  double? _walletUsedAmount;
  OfflinePaymentModel? _selectedOfflineMethod;
  List<Map<String, String>>? _selectedOfflineValue;
  Map<String, String> _takeAwayInfo = {};

  bool _isOfflineSelected = false;


  Map<String, TextEditingController> field  = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Map<String, String> get takeAwayInfo => _takeAwayInfo;
  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  int? get paymentMethodIndex => _paymentMethodIndex;
  OrderModel? get trackModel => _trackModel;
  ResponseModel? get responseModel => _responseModel;
  int get addressIndex => _addressIndex;
  bool get isLoading => _isLoading;
  bool get showCancelled => _showCancelled;
  DeliveryManModel? get deliveryManModel => _deliveryManModel;
  String? get orderType => _orderType;
  int get branchIndex => _branchIndex;
  List<TimeSlotModel>? get timeSlots => _timeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;
  int get selectDateSlot => _selectDateSlot;
  int get selectTimeSlot => _selectTimeSlot;
  double get minimumAmount => _minimumAmount;
  double get distance => _distance;
  bool get isRestaurantCloseShow => _isRestaurantCloseShow;
  PaymentMethod? get paymentMethod => _paymentMethod;
  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;
  double? get partialAmount => _partialAmount;
  double? get walletUsedAmount => _walletUsedAmount;
  OfflinePaymentModel? get selectedOfflineMethod => _selectedOfflineMethod;
  List<Map<String, String>>? get selectedOfflineValue => _selectedOfflineValue;
  bool get isOfflineSelected => _isOfflineSelected;
  List<PaymentMethod> paymentList = [];
  ConfigModel? configModel;
  int? onlinePayIndex;
  int? offlinePayIndex;
  set setPartialAmount(double? value)=> _partialAmount = value;


  void addTakeAwayInfo(Map<String, String> info) {
    _takeAwayInfo = info;
    notifyListeners(); // Notify listeners to update UI if necessary
  }
  void setAddressIndex(int index) async {
    _addressIndex = index;

    // Save the selected address index in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedAddressIndex', index);
    notifyListeners();
  }
  void changeStatus(bool status, {bool notify = false}) {
    _isRestaurantCloseShow = status;
    if(notify) {
      notifyListeners();
    }
  }
  Future<double> getDistanceMinimumAmount(String distance) async {
    ApiResponse apiResponse = await orderRepo!.getDistance(distance);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map<String, dynamic>? responseData = apiResponse.response?.data;
      if (responseData != null) {
        double minimumAmount = double.parse((responseData['minimum_amount'] ?? 0).toString());
        notifyListeners();
        // print('Minimum Amount: $minimumAmount');
        return minimumAmount;
      }
    }
    // Return a default value if the minimum amount couldn't be fetched
    return 0.0;
  }
  Future<void> getOrderList(BuildContext context) async {
    ApiResponse apiResponse = await orderRepo!.getOrderList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      print('order list ${apiResponse.response?.data}');
      _runningOrderList = [];
      _historyOrderList = [];
      apiResponse.response!.data.forEach((order) {
        OrderModel orderModel = OrderModel.fromJson(order);
        if(orderModel.orderStatus == 'pending' ||
            orderModel.orderStatus == 'processing' ||
            orderModel.orderStatus == 'out_for_delivery' ||
            orderModel.orderStatus == 'confirmed') {

          _runningOrderList!.add(orderModel);

        }else if(orderModel.orderStatus == 'delivered' ||
            orderModel.orderStatus == 'returned' ||
            orderModel.orderStatus == 'failed' ||
            orderModel.orderStatus == 'canceled') {
          _historyOrderList!.add(orderModel);
        }
      });
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }
  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID,
      {String? phoneNumber, bool isApiCheck = true}) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;

    ApiResponse apiResponse;
    if(phoneNumber != null){
      apiResponse = await orderRepo!.orderDetailsWithPhoneNumber(orderID, phoneNumber);
      print('order deta1 ${apiResponse.response?.data}');

    }else{
      apiResponse = await orderRepo!.getOrderDetails(orderID);
      print('order deta2 ${apiResponse.response?.data}');

    }

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _orderDetails = [];
      print('order deta3 ${apiResponse.response?.data}');

      apiResponse.response!.data.forEach((orderDetail) => _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
    } else {
      _orderDetails = [];
      print('order deta4 ${apiResponse.response?.data}');


      if(isApiCheck) {
        ApiChecker.checkApi(apiResponse);
      }
    }
    _isLoading = false;
    notifyListeners();
    return _orderDetails;
  }
  Future<void> getDeliveryManData(String? orderID) async {
    ApiResponse apiResponse = await orderRepo!.getDeliveryManData(orderID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _deliveryManModel = DeliveryManModel.fromJson(apiResponse.response!.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setPaymentIndex(int? index, {bool isUpdate = true})async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _paymentMethodIndex = index;
    _paymentMethod = null;
    onlinePayIndex = null;
    offlinePayIndex =_paymentMethodIndex;
    prefs.setInt('selectedPaymentIndex', _paymentMethodIndex!);
    prefs.remove('onlineIndex');
    onlinePayIndex = null;
    if (kDebugMode) {
      print('pay index $_paymentMethodIndex');
    }
    if(isUpdate){
      notifyListeners();
    }
  }

  void changePaymentMethod({PaymentMethod? digitalMethod,
    bool isUpdate = true, OfflinePaymentModel? offlinePaymentModel, bool isClear = false}){
    if(offlinePaymentModel != null){
      _selectedOfflineMethod = offlinePaymentModel;
    }else if(digitalMethod != null){
      _paymentMethod = digitalMethod;
      _paymentMethodIndex = null;
      _selectedOfflineMethod = null;
      _selectedOfflineValue = null;
      // offlinePayIndex = null;
    }
    if(isClear){
      _paymentMethod = null;
      _selectedPaymentMethod = null;
      clearOfflinePayment();

    }
    if(isUpdate){
      notifyListeners();
    }
    notifyListeners();
  }

  void savePaymentMethod({int? index, PaymentMethod? method, bool isUpdate = true})async{
    if(method != null){
      _selectedPaymentMethod = method.copyWith('online');
    }else if(index != null && index == 0){
      onlinePayIndex = null;
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: getTranslated('cash_on_delivery', Get.context!),
        getWay: 'cash_on_delivery',
        type: 'cash_on_delivery',
      );
    }else if(index != null && index == 1){
      onlinePayIndex = null;
      _selectedPaymentMethod = PaymentMethod(
        getWayTitle: getTranslated('wallet_payment', Get.context!),
        getWay: 'wallet_payment',
        type: 'wallet_payment',
      );
    }else{
      _selectedPaymentMethod = null;
    }

   if(isUpdate){
     notifyListeners();
   }

  }

  void clearOfflinePayment(){
    _selectedOfflineMethod = null;
    _selectedOfflineValue = null;

    _isOfflineSelected = false;
  }



  Future<ResponseModel?> trackOrder(String? orderID,
      {String? phoneNumber, bool isUpdate = false,
        OrderModel? orderModel, bool fromTracking = true}) async {
    _trackModel = null;
    _responseModel = null;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      if(isUpdate){
        notifyListeners();
      }
      ApiResponse apiResponse;
      if(phoneNumber != null){
        apiResponse = await orderRepo!.trackOrderWithPhoneNumber(orderID,phoneNumber);
      }else{
        apiResponse = await orderRepo!.trackOrder(
          orderID, guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
        );
      }

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _trackModel = OrderModel.fromJson(apiResponse.response!.data);
        _responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        _trackModel = OrderModel(id: -1);
        _responseModel = ResponseModel(false, ApiChecker.getError(apiResponse).errors![0].message);
        ApiChecker.checkApi(apiResponse);
      }
    }else {
      _trackModel = orderModel;
      _responseModel = ResponseModel(true, 'Successful');
    }
    _isLoading = false;
    notifyListeners();
    return _responseModel;
  }

  Future<void> placeOrder(PlaceOrderBody placeOrderBody, Function callback, {bool isUpdate = true}) async {
    _isLoading = true;
    if(isUpdate){
      notifyListeners();
    }
    ApiResponse apiResponse = await orderRepo!.placeOrder(
      placeOrderBody, guestId: Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId(),
    );
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      String? message = apiResponse.response!.data['message'];
      String orderID = apiResponse.response!.data['order_id'].toString();
      callback(true, message, orderID, placeOrderBody.deliveryAddressId);
    } else {
      callback(false, ApiChecker.getError(apiResponse).errors![0].message, '-1', -1);
    }

    notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }


  void clearPrevData({bool isUpdate = false}) {
    _paymentMethod = null;
    _addressIndex = -1;
    _branchIndex = 0;
    _paymentMethodIndex = null;
    _selectedPaymentMethod = null;
    _selectedOfflineMethod = null;
    clearOfflinePayment();
    _partialAmount = null;
    _walletUsedAmount = null;
    _distance = -1;
    _trackModel = null;
    if(isUpdate){
      notifyListeners();
    }
  }

  void cancelOrder(String orderID, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderRepo!.cancelOrder(orderID, Provider.of<AuthProvider>(Get.context!, listen: false).getGuestId());
    _isLoading = false;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      OrderModel? orderModel;
      for (var order in _runningOrderList ?? []) {
        if(order.id.toString() == orderID) {
          orderModel = order;
        }
      }
      _runningOrderList?.remove(orderModel);
      _showCancelled = true;
      callback(apiResponse.response!.data['message'], true, orderID);
    } else {
      callback(ApiChecker.getError(apiResponse).errors?.first.message, false, '-1');
    }
    notifyListeners();
  }


  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      notifyListeners();
    }
  }

  void setBranchIndex(int index) {
    _branchIndex = index;
    _addressIndex = -1;
    _distance = -1;
    notifyListeners();
  }

  // Future<void> initializeTimeSlot(BuildContext context) async {
  //   final scheduleTime =  Provider.of<SplashProvider>(context, listen: false).configModel!.restaurantScheduleTime!;
  //   int? duration = Provider.of<SplashProvider>(context, listen: false).configModel!.scheduleOrderSlotDuration;
  //   _timeSlots = [];
  //   _allTimeSlots = [];
  //   _selectDateSlot = 0;
  //   int minutes = 0;
  //   DateTime now = DateTime.now();
  //   for(int index = 0; index < scheduleTime.length; index++) {
  //     DateTime openTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).hour,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).minute,
  //     );
  //
  //     DateTime closeTime = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).hour,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).minute,
  //     );
  //
  //     if(closeTime.difference(openTime).isNegative) {
  //       minutes = openTime.difference(closeTime).inMinutes;
  //     }else {
  //       minutes = closeTime.difference(openTime).inMinutes;
  //     }
  //     if(duration! > 0 && minutes > duration) {
  //       DateTime time = openTime;
  //       for(;;) {
  //         if(time.isBefore(closeTime)) {
  //           DateTime start = time;
  //           DateTime end = start.add(Duration(minutes: duration));
  //           if(end.isAfter(closeTime)) {
  //             end = closeTime;
  //           }
  //           _timeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));
  //           _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));
  //           time = time.add(Duration(minutes: duration));
  //         }else {
  //           break;
  //         }
  //       }
  //     }else {
  //       _timeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: openTime, endTime: closeTime));
  //       _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: openTime, endTime: closeTime));
  //     }
  //   }
  //   validateSlot(_allTimeSlots!, 0, notify: false);
  // }
  // Future<void> initializeTimeSlot(BuildContext context) async {
  //   final scheduleTime = Provider.of<SplashProvider>(context, listen: false).configModel!.restaurantScheduleTime!;
  //   int? duration = Provider.of<SplashProvider>(context, listen: false).configModel!.scheduleOrderSlotDuration;
  //   _timeSlots = [];
  //   _allTimeSlots = [];
  //   _selectDateSlot = 0;
  //   DateTime now = DateTime.now();
  //
  //   for (int index = 0; index < scheduleTime.length; index++) {
  //     // Today's open and close times
  //     DateTime openTimeToday = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).hour,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).minute,
  //     );
  //
  //     DateTime closeTimeToday = DateTime(
  //       now.year,
  //       now.month,
  //       now.day,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).hour,
  //       DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).minute,
  //     );
  //
  //     // Tomorrow's open and close times
  //     DateTime openTimeTomorrow = openTimeToday.add(const Duration(days: 1));
  //     DateTime closeTimeTomorrow = closeTimeToday.add(const Duration(days: 1));
  //
  //     if (closeTimeToday.isBefore(openTimeToday)) {
  //       closeTimeToday = closeTimeToday.add(const Duration(days: 1)); // Handle closing time after midnight
  //     }
  //     if (closeTimeTomorrow.isBefore(openTimeTomorrow)) {
  //       closeTimeTomorrow = closeTimeTomorrow.add(const Duration(days: 1)); // Handle closing time after midnight
  //     }
  //
  //     // Handle slots for today
  //     if (duration != null && duration > 0 && now.isBefore(closeTimeToday)) {
  //       DateTime time = now;
  //       bool isFirstSlot = true;
  //
  //       while (time.isBefore(closeTimeToday)) {
  //         DateTime start;
  //         DateTime end;
  //
  //         // Set the next slot to start 50 minutes after the current time if it's today
  //         if (isFirstSlot) {
  //           start = time;
  //           isFirstSlot = false;
  //         } else {
  //           start = time.add(Duration(minutes: isFirstSlot ? 50 : duration));
  //         }
  //
  //         end = start.add(Duration(minutes: duration));
  //
  //         if (end.isAfter(closeTimeToday)) {
  //           end = closeTimeToday;
  //         }
  //
  //         if (start.isAfter(now)) { // Only add future slots
  //           _timeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));
  //           _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));
  //         }
  //
  //         time = end;
  //       }
  //     }
  //
  //     // Handle slots for tomorrow
  //     if (duration != null && duration > 0) {
  //       DateTime time = openTimeTomorrow;
  //
  //       while (time.isBefore(closeTimeTomorrow)) {
  //         DateTime start = time;
  //         DateTime end = start.add(Duration(minutes: duration));
  //
  //         if (end.isAfter(closeTimeTomorrow)) {
  //           end = closeTimeTomorrow;
  //         }
  //
  //         // Add only tomorrow's slots to _allTimeSlots
  //         _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!)! + 1, startTime: start, endTime: end));
  //
  //         time = end;
  //       }
  //     }
  //   }
  //
  //   validateSlot(_allTimeSlots!, 0, notify: false);
  //   sortTime();
  // }

  Future<void> initializeTimeSlot(BuildContext context) async {
    final scheduleTime = Provider.of<SplashProvider>(context, listen: false).configModel!.restaurantScheduleTime!;
    int? duration = Provider.of<SplashProvider>(context, listen: false).configModel!.scheduleOrderSlotDuration;
    _timeSlots = [];
    _allTimeSlots = [];
    _selectDateSlot = 0;
    DateTime now = DateTime.now();

    for (int index = 0; index < scheduleTime.length; index++) {
      DateTime openTime = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).hour,
        DateConverter.convertStringTimeToDate(scheduleTime[index].openingTime!).minute,
      );

      DateTime closeTime = DateTime(
        now.year,
        now.month,
        now.day,
        DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).hour,
        DateConverter.convertStringTimeToDate(scheduleTime[index].closingTime!).minute,
      );

      if (closeTime.isBefore(openTime)) {
        closeTime = closeTime.add(Duration(days: 1)); // Handle closing time after midnight
      }

      if (duration! > 0) {
        DateTime time = openTime; // Start from openTime
        bool isFirstSlot = true;
        bool isSecondSlot = true;

        while (time.isBefore(closeTime)) {
          DateTime start;
          DateTime end;

          if (isFirstSlot) {
            start = openTime;
            isFirstSlot = false;
          } else if (isSecondSlot) {
            start = now.add(const Duration(minutes: 50));
            if (start.isBefore(openTime)) {
              start = openTime.add(const Duration(minutes: 50)); // Ensure the second slot respects openTime
            }
            isSecondSlot = false;
          } else {
            start = time;
          }

          end = start.add(Duration(minutes: duration));
          if (end.isAfter(closeTime)) {
            end = closeTime;
          }

          if (start.isAfter(closeTime)) {
            break;
          }

          // Debugging print statements
          // print('Slot: ${start.toIso8601String()} - ${end.toIso8601String()}');

          _timeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));
          _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: start, endTime: end));

          time = end;
          // Break out of loop if we have added the last slot for the day
          if (time.isAtSameMomentAs(closeTime)) {
            break;
          }
        }
      } else {
        _timeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: openTime, endTime: closeTime));
        _allTimeSlots!.add(TimeSlotModel(day: int.tryParse(scheduleTime[index].day!), startTime: openTime, endTime: closeTime));
      }
    }

    validateSlot(_allTimeSlots!, 0, notify: false);
    sortTime();
  }



  void sortTime() {
    _timeSlots!.sort((a, b) {
      return a.startTime!.compareTo(b.startTime!);
    });

    _allTimeSlots!.sort((a, b) {
      return a.startTime!.compareTo(b.startTime!);
    });
  }


  void updateTimeSlot(int index) {
    _selectTimeSlot = index;
    notifyListeners();
  }

  void updateDateSlot(int index) {
    _selectDateSlot = index;
    if(_allTimeSlots != null) {
      validateSlot(_allTimeSlots!, index);
    }
    notifyListeners();
  }

  void validateSlot(List<TimeSlotModel> slots, int dateIndex, {bool notify = true}) {
    _timeSlots = [];
    int day = 0;
    if(dateIndex == 0) {
      day = DateTime.now().weekday;
    }else {
      day = DateTime.now().add(const Duration(days: 1)).weekday;
    }
    if(day == 7) {
      day = 0;
    }
    for (var slot in slots) {
      if (day == slot.day && (dateIndex == 0 ? slot.endTime!.isAfter(DateTime.now()) : true)) {
        _timeSlots!.add(slot);
      }
    }


    if(notify) {
      notifyListeners();
    }
  }


  Future<bool> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    bool isSuccess = false;
    ApiResponse response = await orderRepo!.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.response!.statusCode == 200 && response.response!.data['status'] == 'OK') {
        isSuccess = true;
        _distance = DistanceModel.fromJson(response.response!.data).rows![0].elements![0].distance!.value! / 1000;
      } else {
        _distance = getDistanceBetween(originLatLng, destinationLatLng) / 1000;
      }
    } catch (e) {
      _distance = getDistanceBetween(originLatLng, destinationLatLng) / 1000;
    }
    notifyListeners();
    return isSuccess;
  }

  Future<void> setPlaceOrder(String placeOrder)async{
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeOrder);
  }
  String? getPlaceOrder(){
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }
  Future<void> clearPlaceOrder()async{
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }

  double getDistanceBetween(LatLng startLatLng, LatLng endLatLng){
    return Geolocator.distanceBetween(
      startLatLng.latitude, startLatLng.longitude, endLatLng.latitude, endLatLng.longitude,
    );
  }

  void changePartialPayment({double? amount,  bool isUpdate = true}){
    _partialAmount = amount;

    if(isUpdate) {
      notifyListeners();
    }
  }
  void saveWalletPayment(double? walletAmount){
    _walletUsedAmount= walletAmount;
    notifyListeners();
    print('_walletUsedAmount $_walletUsedAmount');
  }
  void setOfflineSelectedValue(List<Map<String, String>>? data, {bool isUpdate = true}){
    _selectedOfflineValue = data;

    if(isUpdate){
      notifyListeners();
    }
  }

  bool paymentVisibility = true;

  void updatePaymentVisibility(bool vale){
    paymentVisibility = vale;
    // notifyListeners();
  }

  void setOfflineSelect(bool value){
    _isOfflineSelected = value;
    notifyListeners();
  }



}