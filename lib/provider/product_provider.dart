import 'package:flutter_restaurant/data/model/response/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/product_model.dart';
import 'package:flutter_restaurant/data/repository/product_repo.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/main.dart';
import 'package:flutter_restaurant/provider/cart_provider.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

import '../data/datasource/remote/exception/api_error_handler.dart';
import '../data/model/response/product_suub_categ_model.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo? productRepo;

  ProductProvider({required this.productRepo});

  // Latest products
  List<Product>? _popularProductList;
  List<ProductSubCategory>? _subCategoryProduct;
  List<Product>? _latestProductList;
  bool _isLoading = false;
  int? _popularPageSize;
  int? _latestPageSize;
  List<String> _offsetList = [];

  // List<int> _variationIndex = [0];
  int? _quantity = 1;
  List<bool> _addOnActiveList = [];
  List<int?> _addOnQtyList = [];
  bool _seeMoreButtonVisible = true;
  int latestOffset = 1;
  int popularOffset = 1;
  int _cartIndex = -1;
  final List<String> _productTypeList = ['all', 'non_veg', 'veg'];
  List<List<bool?>> _selectedVariations = [];
  double _totalPrice = 0.0;
  double _extraPrice = 0.0;

  List<Product>? get popularProductList => _popularProductList;
  List<ProductSubCategory>? get subCategoryProduct => _subCategoryProduct;

  List<Product>? get latestProductList => _latestProductList;

  bool get isLoading => _isLoading;

  int? get popularPageSize => _popularPageSize;

  int? get latestPageSize => _latestPageSize;

  // List<int> get variationIndex => _variationIndex;
  int? get quantity => _quantity;

  List<bool> get addOnActiveList => _addOnActiveList;

  List<int?> get addOnQtyList => _addOnQtyList;

  bool get seeMoreButtonVisible => _seeMoreButtonVisible;

  int get cartIndex => _cartIndex;

  List<String> get productTypeList => _productTypeList;

  List<List<bool?>> get selectedVariations => _selectedVariations;

  ProductSubCategory? _subCategory;
  String? _error;

  double get totalPrice => _totalPrice;
  double get extraPrice => _extraPrice;

  ProductSubCategory? get subCategory => _subCategory;
  String? get error => _error;
  final List<String?> _extraName = [];
  final List<String?> _extrasPrice = [];
  final List<String?> _extrasId = [];
  String _extraHeading = '';

  List<String?> get extraNames => _extraName;
  List<String?> get extraPrices => _extrasPrice;
  List<String?> get extraId => _extrasId;
  List<String> get selectedDropdownIds => getSelectedDropdownItemIdsListAsString();
  List<ExtraItem> extraItems = [];
  String get extraHeading => _extraHeading;
  List<bool> selectedItems = [];

  List<String> selectedDropDownIds = [];

  int selectedIndex = 0;

  List<String> selectedExtraIds = [];
  void saveExtraItemId(String id) {
    selectedExtraIds.add(id);
    notifyListeners();
  }

  void addExtraItem(ExtraItem item) {
    extraItems.add(item);
    notifyListeners();
  }

  // Method to remove extra item
  void removeExtraItemId(String id) {
    selectedExtraIds.remove(id);
    notifyListeners();
  }

  final Map<String, int> _selectedDropdownItemIds = {};

  // Method to save the selected dropdown item ID
  void saveDropDownItemId(String dropdownName, int itemId) {
    _selectedDropdownItemIds[dropdownName] = itemId;
    getSelectedDropDownItemId(dropdownName);
    notifyListeners();
  }

  // Method to get the selected dropdown item ID for a given dropdown
  int? getSelectedDropDownItemId(String dropdownName) {
    return _selectedDropdownItemIds[dropdownName];
  }

  List<String> getSelectedDropdownItemIdsListAsString() {
    // Iterate over the values of the map, convert them to strings, and store them in a list
    return _selectedDropdownItemIds.values.map((id) => id.toString()).toList();
  }

  void resetSelectedDropdownItemIds() {
    _selectedDropdownItemIds.clear();
    notifyListeners();
  }

  ExtraItem getExtraItem(int index) {
    return extraItems[index];
  }

  restExtraIdsList(){
    selectedExtraIds =[];
  }




  void updateTotalPrice(double total) {
    _totalPrice += total;
    print('Updated total is $_totalPrice');
  }

  void updateExtraPrice(double total,String condition) {
    if(condition == 'plus'){
      _extraPrice += total;
    }else if(condition == 'minus'){
      _extraPrice -= total;
    }

  }

  void resetExtraPrice() {
    _extraPrice = 0.0;
  }

  void resetTotalPrice() {
    _totalPrice = 0.0;
  }

  Future<void> getExtras(int? productId) async {
    _extraHeading = '';
    try {
      ApiResponse apiResponse = await productRepo!.getProductSubCategories(productId!);

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        Map<String, dynamic>? jsonData = apiResponse.response!.data;
        if (jsonData != null) {
          // Clear previous data
          _extraHeading = '';
          _extraName.clear();
          _extrasPrice.clear();
          selectedItems.clear(); // Clear selected items list
          extraItems.clear();

          // Extract subcategory heading
          _extraHeading = jsonData['name'] ?? '';

          // Extract items from variation list
          List<dynamic> variationList = jsonData['variation'];
          for (var variation in variationList) {
            ExtraItem extraItem = ExtraItem.fromJson(variation);
           addExtraItem(extraItem);
            _extraName.add(extraItem.name);
            _extrasPrice.add(extraItem.price);
            _extrasId.add(extraItem.id);
            selectedItems.add(false);
          }

          notifyListeners();
          _error = null; // Reset error if successful
        } else {
          _extraName.clear();
          _extrasPrice.clear();
          _error = "No subcategories found";
        }
      } else {
        _extraName.clear();
        _extrasPrice.clear();
        _error = "Failed to fetch subcategories: ${apiResponse.response?.statusCode}";
      }
    } catch (e) {
      _extraName.clear();
      _extrasPrice.clear();
      _error = ApiErrorHandler.getMessage(e);
    } finally {
      notifyListeners(); // Notify listeners regardless of success or failure
    }
  }


  bool isSelected(int index) {
    if (index >= 0 && index < selectedItems.length) {
      return selectedItems[index];
    }
    return false; // Return default value if index is out of range
  }

  void setSelected(int index, bool value) {
    // if (index >= 0 && index < selectedItems.length) {
    selectedItems[index] = value;
    if (value) {
      // Update selectedIndex only when an item is selected
      selectedIndex = index;
    } else {
      // Reset selectedIndex when an item is deselected
      selectedIndex = index;
    }
    notifyListeners();
    // } else {
    //   print('Invalid index: $index');
    // }
  }

  Future<void> getLatestProductList(bool reload, String offset) async {
    if (reload || offset == '1' || _latestProductList == null) {
      latestOffset = 1;
      _offsetList = [];
      _latestProductList = null;
    }
    if (!_offsetList.contains(offset)) {
      _offsetList = [];
      _offsetList.add(offset);
      ApiResponse apiResponse = await productRepo!.getLatestProductList(offset);
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        if (reload || offset == '1' || _latestProductList == null) {
          _latestProductList = [];
        }
        _latestProductList!.addAll(
            ProductModel.fromJson(apiResponse.response!.data).products!);
        _latestPageSize =
            ProductModel.fromJson(apiResponse.response!.data).totalSize;
        _isLoading = false;
        notifyListeners();
      } else {
        _latestProductList = [];

        showCustomSnackBar(apiResponse.error.toString());
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> getPopularProductList(bool reload, String offset,
      {String type = 'all', bool isUpdate = false}) async {
    bool apiSuccess = false;
    if (reload || offset == '1') {
      popularOffset = 1;
      _offsetList = [];
      _popularProductList = null;
    }
    if (isUpdate) {
      notifyListeners();
    }

    if (!_offsetList.contains(offset)) {
      _offsetList = [];
      _offsetList.add(offset);
      ApiResponse apiResponse =
          await productRepo!.getPopularProductList(offset, type);

      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        apiSuccess = true;
        if (reload || offset == '1') {
          _popularProductList = [];
        }
        _popularProductList!.addAll(
            ProductModel.fromJson(apiResponse.response!.data).products!);
        print('pupular products${apiResponse.response!.data}');
        _popularPageSize =
            ProductModel.fromJson(apiResponse.response!.data).totalSize;
        _isLoading = false;
        notifyListeners();
      } else {
        showCustomSnackBar(apiResponse.error.toString());
      }
    } else {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return apiSuccess;
  }

  void showBottomLoader() {
    _isLoading = true;
    notifyListeners();
  }

  void initData(Product? product, CartModel? cart) {
    _selectedVariations = [];
    _addOnQtyList = [];
    _addOnActiveList = [];

    if (cart != null) {
      _quantity = cart.quantity;
      _selectedVariations.addAll(cart.variations!);
      List<int?> addOnIdList = [];
      for (var addOnId in cart.addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in product!.addOns!) {
        if (addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList
              .add(cart.addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        } else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    } else {
      _quantity = 1;
      if (product!.variations != null) {
        for (int index = 0; index < product.variations!.length; index++) {
          _selectedVariations.add([]);
          for (int i = 0;
              i < product.variations![index].variationValues!.length;
              i++) {
            _selectedVariations[index].add(false);
          }
        }
      }

      if (product.addOns != null) {
        for (int i = 0; i < product.addOns!.length; i++) {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    }
  }

  void setAddOnQuantity(bool isIncrement, int index) {
    if (isIncrement) {
      _addOnQtyList[index] = _addOnQtyList[index]! + 1;
    } else {
      _addOnQtyList[index] = _addOnQtyList[index]! - 1;
    }
    notifyListeners();
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = _quantity! + 1;
    } else {
      _quantity = _quantity! - 1;
    }
    notifyListeners();
  }

  void setCartVariationIndex(
      int index, int i, Product? product, bool isMultiSelect) {
    if (!isMultiSelect) {
      for (int j = 0; j < _selectedVariations[index].length; j++) {
        if (product!.variations![index].isRequired!) {
          _selectedVariations[index][j] = j == i;
        } else {
          if (_selectedVariations[index][j]!) {
            _selectedVariations[index][j] = false;
          } else {
            _selectedVariations[index][j] = j == i;
          }
        }
      }
    } else {
      if (!_selectedVariations[index][i]! &&
          selectedVariationLength(_selectedVariations, index) >=
              product!.variations![index].max!) {
        showCustomSnackBar(
            '${getTranslated('maximum_variation_for', Get.context!)} '
                '${product.variations![index].name} ${getTranslated('is', Get.context!)}'
                ' ${product.variations![index].max}',
            isToast: true);
      } else {
        _selectedVariations[index][i] = !_selectedVariations[index][i]!;
      }
    }
    notifyListeners();
  }

  int selectedVariationLength(List<List<bool?>> selectedVariations, int index) {
    int length = 0;
    for (bool? isSelected in selectedVariations[index]) {
      if (isSelected!) {
        length++;
      }
    }
    return length;
  }

  int setExistInCart(Product product, {bool notify = true}) {
    final cartProvider = Provider.of<CartProvider>(Get.context!, listen: false);

    _cartIndex = cartProvider.isExistInCart(product.id, null);
    if (_cartIndex != -1) {
      _quantity = cartProvider.cartList[_cartIndex]!.quantity;
      _addOnActiveList = [];
      _addOnQtyList = [];
      List<int?> addOnIdList = [];
      for (var addOnId in cartProvider.cartList[_cartIndex]!.addOnIds!) {
        addOnIdList.add(addOnId.id);
      }
      for (var addOn in product.addOns!) {
        if (addOnIdList.contains(addOn.id)) {
          _addOnActiveList.add(true);
          _addOnQtyList.add(cartProvider.cartList[_cartIndex]!
              .addOnIds![addOnIdList.indexOf(addOn.id)].quantity);
        } else {
          _addOnActiveList.add(false);
          _addOnQtyList.add(1);
        }
      }
    }
    return _cartIndex;
  }

  void addAddOn(bool isAdd, int index) {
    _addOnActiveList[index] = isAdd;
    notifyListeners();
  }

  void moreProduct(BuildContext context) {
    int pageSize;
    pageSize = (latestPageSize! / 10).ceil();

    if (latestOffset < pageSize) {
      latestOffset++;
      showBottomLoader();
      getLatestProductList(false, latestOffset.toString());
    }
  }

  void seeMoreReturn() {
    latestOffset = 1;
    _seeMoreButtonVisible = true;
  }

  bool checkStock(Product product, {int? quantity}) {
    int? stock;
    if (product.branchProduct?.stockType != 'unlimited' &&
        product.branchProduct?.stock != null &&
        product.branchProduct?.soldQuantity != null) {
      stock =
          product.branchProduct!.stock! - product.branchProduct!.soldQuantity!;
      if (quantity != null) {
        stock = stock - quantity;
      }
    }
    return stock == null || (stock > 0);
  }
}
