import 'package:awesome_period_tracker/core/environment/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class CycleApiClient {
  @factoryMethod
  @Named('cycle_api_client')
  Dio createInstance(Env env) {
    final headers = {
      'X-RapidAPI-Key': env.cyclePhaseApiKey,
      'X-RapidAPI-Host': env.cyclePhaseApiUrl.replaceFirst('https://', ''),
    };

    final dio = Dio(
      BaseOptions(
        baseUrl: env.cyclePhaseApiUrl,
        headers: headers,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          maxWidth: 120,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}
