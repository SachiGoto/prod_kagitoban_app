import 'package:flutter/foundation.dart';

class ApiLoadingController extends ChangeNotifier {
  ApiLoadingController._();

  static final ApiLoadingController instance = ApiLoadingController._();

  int _requestCount = 0;

  bool get isLoading => _requestCount > 0;

  Future<T> run<T>(Future<T> Function() request) async {
    _requestCount++;
    notifyListeners();

    try {
      return await request();
    } finally {
      _requestCount--;
      notifyListeners();
    }
  }
}
