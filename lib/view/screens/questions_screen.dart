import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reff_shared/core/models/models.dart';
import 'package:reff_shared/core/services/api.dart';
import 'package:reff_web/core/locator.dart';
import 'package:reff_web/core/providers/main_provider.dart';
import 'package:reff_web/core/providers/question_provider.dart';
import 'package:reff_web/styles.dart';
import 'package:reff_web/view/screens/edit_question_screen.dart';
import 'package:reff_web/view/widgets/custom_card.dart';
import 'package:reff_web/view/widgets/edit_question_widgets.dart';

final questionsFromApi =
    StreamProvider((_) => locator<BaseApi>().question.getsStream());

class QuestionsScreen extends HookWidget {
  static const route = "/questions";

  @override
  Widget build(BuildContext context) {
    final _dateTime = useState(DateTime.now());

    final busyState = useProvider(busyStateProvider.state);
    final questionState = useProvider(questionChangeNotifierProvider);

    final questionsStream = useProvider(questionsFromApi);
    return Scaffold(
      appBar: _appBar(busyState),
      floatingActionButton: QuestionsScreenFloatingActionButton(),
      body: Column(
        children: [
          FilterBar(),
          Container(
            padding: mediumPadding,
            width: double.maxFinite,
            child: questionsStream.when(
                data: (questions) => CustomCard(
                      child: DataTable(
                          columns: ["Header", "Date", ""]
                              .map((e) => DataColumn(
                                    label: Text(e,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ))
                              .toList(),
                          rows: questions
                              .map(
                                (question) => DataRow(cells: [
                                  DataCell(Text(
                                    question.header,
                                    style: TextStyle(
                                        fontWeight: question.isActive
                                            ? FontWeight.bold
                                            : FontWeight.w100),
                                  )),
                                  DataCell(Text(DateFormat("HH:mm - dd.MM.yyyy")
                                      .format(question.timeStamp))),
                                  DataCell(Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          busyStateProvider
                                              .read(context)
                                              .busy();
                                          final api = locator<BaseApi>();
                                          final answers = await api.answer
                                              .gets(question.answers);
                                          busyStateProvider
                                              .read(context)
                                              .notBusy();

                                          questionState.initialize(
                                              answers: answers,
                                              question: question);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditQuestionScreen()),
                                          );
                                        },
                                        icon: Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          busyStateProvider
                                              .read(context)
                                              .busy();

                                          await locator<BaseApi>()
                                              .question
                                              .remove(question.id);
                                          busyStateProvider
                                              .read(context)
                                              .notBusy();
                                        },
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  )),
                                ]),
                              )
                              .toList()),
                    ),
                loading: () => Center(child: LinearProgressIndicator()),
                error: (err, stack) => Text("$err")),
          ),
        ],
      ),
    );
  }
}

AppBar _appBar(bool busyState) => AppBar(
    flexibleSpace: Align(
        alignment: Alignment.centerRight,
        child: busyState
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )
            : null),
    title: Text('Reff Panel'));

class QuestionsScreenFloatingActionButton extends HookWidget {
  const QuestionsScreenFloatingActionButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionState = useProvider(questionChangeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
//        FloatingActionButton(
//            heroTag: "date",
//            backgroundColor: Colors.blueGrey,
//            child: Icon(Icons.date_range),
//            onPressed: () {}),
//        Divider(color: Colors.transparent),
        FloatingActionButton(
            heroTag: "add",
            child: Icon(Icons.add),
            backgroundColor: Colors.blueGrey,
            onPressed: () {
              questionState.initialize(
                  answers: <AnswerModel>[],
                  question: QuestionModel(
                      countryCode: "tr",
                      header: "",
                      timeStamp: DateTime.now()));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditQuestionScreen()),
              );
            }),
      ],
    );
  }
}
