import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import '../utils/error_handler.dart';

class FunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Logger _logger = Logger();

  // Call a callable function
  Future<T> callFunction<T>(
    String functionName, {
    Map<String, dynamic>? parameters,
    String? region,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable(
        functionName,
        options: region != null ? HttpsCallableOptions(region: region) : null,
      );

      HttpsCallableResult result = await callable.call(parameters);
      
      _logger.d('Function $functionName called successfully');
      return result.data as T;
    } catch (e) {
      _logger.e('Failed to call function $functionName: $e');
      throw ErrorHandler.handleFunctionsError(e);
    }
  }

  // Call function with timeout
  Future<T> callFunctionWithTimeout<T>(
    String functionName, {
    Map<String, dynamic>? parameters,
    Duration timeout = const Duration(seconds: 30),
    String? region,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(
          region: region,
          timeout: timeout,
        ),
      );

      HttpsCallableResult result = await callable.call(parameters);
      
      _logger.d('Function $functionName called successfully with timeout');
      return result.data as T;
    } catch (e) {
      _logger.e('Failed to call function $functionName with timeout: $e');
      throw ErrorHandler.handleFunctionsError(e);
    }
  }

  // Get function reference for advanced usage
  HttpsCallableReference getFunctionReference(
    String functionName, {
    String? region,
  }) {
    return _functions.httpsCallable(
      functionName,
      options: region != null ? HttpsCallableOptions(region: region) : null,
    );
  }
}