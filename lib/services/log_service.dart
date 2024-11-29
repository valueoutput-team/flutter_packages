import 'package:deeplynks/models/log_model.dart';
import 'package:deeplynks/services/api_service.dart';
import 'package:deeplynks/utils/api_constants.dart';
import 'package:deeplynks/utils/app_constants.dart';

class LogService {
  static final _instance = LogService._();

  LogService._();

  factory LogService() {
    return _instance;
  }

  void logInfo(String msg) {
    // if (!kReleaseMode) log(msg);
  }

  void logError(Object e, StackTrace st) {
    // if (!kReleaseMode) log('${e.toString()} ${st.toString()}');
    ApiService().request(
      method: ApiMethod.post,
      endpoint: ApiEndpoints.logs,
      body: {
        ApiKeys.data: [
          LogModel(
            stack: st.toString(),
            message: e.toString(),
            level: LogLevel.error,
            time: DateTime.now().millisecondsSinceEpoch,
          ).toMap(),
        ],
      },
    );
  }
}
