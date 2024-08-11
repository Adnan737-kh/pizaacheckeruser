import 'package:flutter_restaurant/data/model/response/order_model.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';

class OrderDetailsModel {
  int? _id;
  int? _productId;
  int? _orderId;
  double? _price;
  Product? _productDetails;
  List<Variation>? _variations;
  List<OldVariation>? _oldVariations;
  double? _discountOnProduct;
  String? _discountType;
  int? _quantity;
  double? _taxAmount;
  String? _createdAt;
  String? _updatedAt;
  List<int>? _addOnIds;
  List<double>? _addOnPrices;
  List<int>? _addOnQtys;
  double? _addOnTaxAmount;
  OrderModel? _orderModel;
  List<String>? _takeAwayInfo;
  List<Dropdown>? _dropdowns;
  List<DropdownValues> _dropdownsValues = [];


  OrderDetailsModel(
      {int? id,
        int? productId,
        int? orderId,
        double? price,
        Product? productDetails,
        List<Variation>? variations,
        List<OldVariation>? oldVariations,
        double? discountOnProduct,
        String? discountType,
        int? quantity,
        double? taxAmount,
        String? createdAt,
        String? updatedAt,
        List<int>? addOnIds,
        List<int>? addOnQtys,
        double? addOnTaxAmount,
        List<double>? addOnPrices,
        OrderModel? orderModel,
        List<String>? takeAwayInfo,
        List<Dropdown>? dropdowns,
        List<DropdownValues>? dropdownsValues,
      }) {
    _id = id;
    _productId = productId;
    _orderId = orderId;
    _price = price;
    _productDetails = productDetails;
    _oldVariations = oldVariations;
    _variations = variations;
    _discountOnProduct = discountOnProduct;
    _discountType = discountType;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _addOnIds = addOnIds;
    _addOnQtys = addOnQtys;
    _addOnTaxAmount = addOnTaxAmount;
    _addOnPrices = addOnPrices;
    _orderModel = orderModel;
    _takeAwayInfo = takeAwayInfo;
    _dropdowns = dropdowns;
    _dropdownsValues = dropdownsValues!;

  }

  int? get id => _id;
  int? get productId => _productId;
  int? get orderId => _orderId;
  double? get price => _price;
  Product? get productDetails => _productDetails;
  List<Variation>? get variations => _variations;
  List<OldVariation>? get oldVariations => _oldVariations;
  double? get discountOnProduct => _discountOnProduct;
  String? get discountType => _discountType;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  List<int>? get addOnIds => _addOnIds;
  List<int>? get addOnQtys => _addOnQtys;
  double? get addOnTaxAmount => _addOnTaxAmount;
  List<double>? get addOnPrices => _addOnPrices;
  List<String>? get takeAwayInfo => _takeAwayInfo;
  OrderModel? get orderModel => _orderModel;
  List<Dropdown>? get dropdowns => _dropdowns;

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _productId = json['product_id'];
    _orderId = json['order_id'];
    _price = json['price'].toDouble();
    _productDetails = Product.fromJson(json['product_details']);

    if (json['variation'] != null && json['variation'].isNotEmpty) {
      if(json['variation'][0]['values'] != null) {
        _variations = [];
        json['variation'].forEach((v) {
          _variations!.add(Variation.fromJson(v));
        });
      } else {
        _oldVariations = [];
        json['variation'].forEach((v) {
          _oldVariations!.add(OldVariation.fromJson(v));
        });
      }
    }

    if (json['dropdowns'] != null) {
      _dropdowns = [];
      json['dropdowns'].forEach((v) {
        _dropdowns!.add(Dropdown.fromJson(v));
      });
    }

    _discountOnProduct = json['discount_on_product'].toDouble();
    _discountType = json['discount_type'];
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'].toDouble();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _addOnIds = json['add_on_ids'].cast<int>();
    if(json['add_on_qtys'] != null) {
      _addOnQtys = [];
      json['add_on_qtys'].forEach((qun) {
        try {
          _addOnQtys!.add(int.parse(qun));
        } catch(e) {
          _addOnQtys!.add(qun);
        }
      });
    }

    if (json['dropdown_values'] != null) {
      print('_dropdownsValueEm $_dropdownsValues');
      _dropdownsValues = [];
      json['dropdown_values'].forEach((v) {
        _dropdownsValues.add(DropdownValues.fromJson(v));
        print('_dropdownsValue $_dropdownsValues');
      });
    }

    if(json['add_on_prices'] != null) {
      _addOnPrices = [];
      json['add_on_prices'].forEach((qun) {
        try {
          _addOnPrices?.add(double.parse('$qun'));
        } catch(e) {
          _addOnPrices?.add(qun);
        }
      });
    }


    _addOnTaxAmount = double.tryParse('${json['add_on_tax_amount']}');
    _orderModel = OrderModel.fromJson(json['order']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['product_id'] = _productId;
    data['order_id'] = _orderId;
    data['price'] = _price;
    data['product_details'] = _productDetails?.toJson();
    data['discount_on_product'] = _discountOnProduct;
    data['discount_type'] = _discountType;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['add_on_ids'] = _addOnIds;
    data['add_on_qtys'] = _addOnQtys;
    data['add_on_tax_amount'] = _addOnTaxAmount;
    data['add_on_prices'] = _addOnPrices;
    if (_variations != null) {
      data['variation'] = _variations!.map((v) => v.toJson()).toList();
    }
    if (_dropdowns != null) {
      data['dropdowns'] = _dropdowns!.map((v) => v.toJson()).toList();
    }
    data['order'] = _orderModel?.toJson();
    data['take_away_info'] = _takeAwayInfo;
    return data;
  }
}

class OldVariation {
  String? type;
  double? price;

  OldVariation({this.type, this.price});

  OldVariation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = double.tryParse('${json['price']}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    return data;
  }
}

class Dropdown {
  String? name;
  List<SubValue>? subValues;

  Dropdown({this.name, this.subValues});

  Dropdown.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['sub_values'] != null) {
      subValues = <SubValue>[];
      json['sub_values'].forEach((v) {
        subValues!.add(SubValue.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (subValues != null) {
      data['sub_values'] = subValues!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubValue {
  String? value;

  SubValue({this.value});

  SubValue.fromJson(Map<String, dynamic> json) {
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    return data;
  }
}
