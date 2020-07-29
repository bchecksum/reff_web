import 'package:reff_shared/core/services/answer_api.dart';
import 'package:reff_shared/core/services/api.dart';
import 'package:reff_shared/core/services/question_api.dart';
import 'package:reff_web/core/locator.dart';

class FirestoreApi extends BaseApi {
  FirestoreApi()
      : super(
            question: locator<BaseQuestionApi>(),
            answer: locator<BaseAnswerApi>());
}
