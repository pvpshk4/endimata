import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final String? errorMessage;
  final DioException? error;

  const DataState({this.data, this.error, this.errorMessage});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException error) : super(error: error);
}

class DataFailedMessage<T> extends DataState<T> {
  const DataFailedMessage(String errorMessage)
    : super(errorMessage: errorMessage);
}
