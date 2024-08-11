import 'package:flutter_restaurant/data/model/response/product_model.dart';

class CartModel {
  double? _price;
  double? _discountedPrice;
  List<Variation>? _variation;
  double? _discountAmount;
  int? _quantity;
  double? _taxAmount;
  List<AddOn>? _addOnIds;
  Product? _product;
  List<List<bool?>>? _variations;
  List<String>? _extraIds;
  List<String>? _dropDownIds;
  double? _extraPrice;


  CartModel(
      double? price,
      double? discountedPrice,
      List<Variation> variation,
      double? discountAmount,
      int? quantity,
      double? taxAmount,
      List<AddOn> addOnIds,
      Product? product,
      List<List<bool?>> variations,
      List<String> extraIds,
      List<String> dropDownIds,
      double? extraPrice,

  ) {
    _price = price;
    _discountedPrice = discountedPrice;
    _variation = variation;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _addOnIds = addOnIds;
    _product = product;
    _variations = variations;
    _extraIds = extraIds;
    _dropDownIds = dropDownIds;
    _extraPrice = extraPrice;
  }


  double? get price => _price;
  double? get extraPrice => _extraPrice;
  double? get discountedPrice => _discountedPrice;
  List<Variation>? get variation => _variation;
  double? get discountAmount => _discountAmount;
  // ignore: unnecessary_getters_setters
  int? get quantity => _quantity;
  // ignore: unnecessary_getters_setters
  set quantity(int? qty) => _quantity = qty;
  double? get taxAmount => _taxAmount;
  List<AddOn>? get addOnIds => _addOnIds;
  Product? get product => _product;
  List<List<bool?>>? get variations => _variations;
  List<String>? get extraIds => _extraIds;
  List<String>? get dropDownIDs => _dropDownIds;


  CartModel.fromJson(Map<String, dynamic> json) {
    _price = json['price'].toDouble();
    _extraPrice = json['extra price'].toDouble();
    _discountedPrice = json['discounted_price'].toDouble();
    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }

    dynamic variantId = json['variant_id'];
    if (variantId is String) {
      _extraIds = [variantId];
      print('extras ids $_extraIds');
    } else if (variantId is List) {
      _extraIds = variantId.cast<String>();
      print('extras ids  cast String$_extraIds');
    } else {
    }

    dynamic dropDownIds = json['dropdown_id'];
    if (dropDownIds is String) {
      _dropDownIds = [dropDownIds];
    } else if (dropDownIds is List) {
      _dropDownIds = dropDownIds.cast<String>();
    } else {
    }

    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }


    _discountAmount = json['discount_amount'].toDouble();
    _quantity = json['quantity'];
    _taxAmount = json['tax_amount'].toDouble();
    if (json['add_on_ids'] != null) {
      _addOnIds = [];
      json['add_on_ids'].forEach((v) {
        _addOnIds!.add(AddOn.fromJson(v));
      });
    }
    if (json['product'] != null) {
      _product = Product.fromJson(json['product']);
    }
    if (json['variations'] != null) {
      _variations = [];
      for(int index=0; index<json['variations'].length; index++) {
        _variations!.add([]);
        for(int i=0; i<json['variations'][index].length; i++) {
          _variations![index].add(json['variations'][index][i]);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = _price;
    data['extra price'] = _extraPrice;
    data['discounted_price'] = _discountedPrice;
    if (_variation != null) {
      data['variation'] = _variation!.map((v) => v.toJson()).toList();
    }
    if (_extraIds != null) {
      print(_extraIds);
      // Convert _extraIds list of integers to list of strings
      data['variant_id'] = _extraIds!.map((id) => id.toString()).toList();
      print('extra string ids to String   $_extraIds');

    }

    if (_dropDownIds != null) {
      // Convert _dropDownIds list of integers to list of strings
      data['dropdown_id'] = _dropDownIds!.map((id) => id.toString()).toList();
    }
    data['discount_amount'] = _discountAmount;
    data['quantity'] = _quantity;
    data['tax_amount'] = _taxAmount;
    if (_addOnIds != null) {
      data['add_on_ids'] = _addOnIds!.map((v) => v.toJson()).toList();
    }
    data['product'] = _product!.toJson();
    data['variations'] = _variations;
    return data;
  }
}

class AddOn {
  int? _id;
  int? _quantity;

  AddOn({int? id, int? quantity}) {
    _id = id;
    _quantity = quantity;
  }

  int? get id => _id;
  int? get quantity => _quantity;

  AddOn.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['quantity'] = _quantity;
    return data;
  }
}
