import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reff_shared/core/models/ResultModel.dart';
import 'package:reff_shared/core/models/models.dart';
import 'package:reff_shared/core/services/services.dart';
import 'package:reff_web/core/providers/question_provider.dart';
import 'package:reff_web/core/utils/locator.dart';

final resultIDState = StateProvider<String>((_) => "");

class ResultScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final resultID = useProvider(resultIDState);
    return Scaffold(
        appBar: AppBar(title: Text('Sonuçlar')),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.delete),
            onPressed: () async {
              // todo : add delete op.
              if (resultID.state != null && resultID.state != "") {
                await locator<BaseResultApi>().remove(resultID.state);
              }
            }),
        body: Column(
          children: [
            QuestionInfo(),
            Divider(height: 40),
            Expanded(child: ResultWidget())
          ],
        ));
  }
}

class QuestionInfo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final questionState = useProvider(QuestionChangeNotifier.provider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<QuestionModel>(
            future: locator<BaseQuestionApi>().get(questionState.question.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('loading question');
              }
              if (snapshot.hasData) {
                return Text('${snapshot.data.header}');
              } else {
                return Text('no question');
              }
            }),
      ),
    );
  }
}

class ResultWidget extends HookWidget {
  const ResultWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionState = useProvider(QuestionChangeNotifier.provider);

    return FutureBuilder<ResultModel>(
      future: locator<BaseResultApi>().getByQuestion(questionState.question.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('loading result');
        }
        if (snapshot.hasData) {
          final result = snapshot.data;
          return FutureBuilder<List<AnswerModel>>(
            future: locator<BaseAnswerApi>().gets(result.answers),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final answers = snapshot.data;
                return ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final answer = answers[index];
                      final resultAgeMapForThisAnswer = result.agesMap.entries
                          .where((element) => element.key == answer.id)
                          .map((e) => e.value)
                          .first;

                      final resultGenderMapForThisAnswer = result
                          .gendersMap.entries
                          .where((element) => element.key == answer.id)
                          .map((e) => e.value)
                          .first;

                      final resultCityNameMapForThisAnswer = result
                          .cityNameMap.entries
                          .where((element) => element.key == answer.id)
                          .map((e) => e.value)
                          .first;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(answer.content),
                              ),
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('Yaş')),
                                  DataColumn(label: Text('Sayı'))
                                ],
                                rows: resultAgeMapForThisAnswer.entries
                                    .map((e) => DataRow(cells: [
                                          DataCell(Text(e.key.toString())),
                                          DataCell(Text(e.value.toString())),
                                        ]))
                                    .toList(),
                              ),
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('Cinsiyet')),
                                  DataColumn(label: Text('Sayı'))
                                ],
                                rows: resultGenderMapForThisAnswer.entries
                                    .map((e) => DataRow(cells: [
                                          DataCell(Text(
                                              e.key.toString().substring(7))),
                                          DataCell(Text(e.value.toString())),
                                        ]))
                                    .toList(),
                              ),
                              DataTable(
                                columns: [
                                  DataColumn(label: Text('Şehir')),
                                  DataColumn(label: Text('Sayı'))
                                ],
                                rows: resultCityNameMapForThisAnswer.entries
                                    .map((e) => DataRow(cells: [
                                          DataCell(Text(e.key.toString())),
                                          DataCell(Text(e.value.toString())),
                                        ]))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return Text('loading answers');
              }
            },
          );
        } else {
          return CreateNewResult();
        }
      },
    );
  }
}

class CreateNewResult extends HookWidget {
  const CreateNewResult({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionProvider = useProvider(QuestionChangeNotifier.provider);

    return Center(
      child: RaisedButton(
          child: Text('not found result, create new one'),
          onPressed: () async {
            await locator<BaseResultApi>()
                .createFromQuestion(questionProvider.question.id);
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }),
    );
  }
}
