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
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        functionName,
      );

      final HttpsCallableResult result = await callable.call(parameters);
      
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
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        functionName,
        options: HttpsCallableOptions(
          timeout: timeout,
        ),
      );

      final HttpsCallableResult result = await callable.call(parameters);
      
      _logger.d('Function $functionName called successfully with timeout');
      return result.data as T;
    } catch (e) {
      _logger.e('Failed to call function $functionName with timeout: $e');
      throw ErrorHandler.handleFunctionsError(e);
    }
  }

  // Get function reference for advanced usage
  HttpsCallable getFunctionReference(
    String functionName, {
  }) {
    return _functions.httpsCallable(
      functionName,
    );
  }
}