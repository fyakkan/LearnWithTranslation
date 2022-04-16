import 'package:learn_with_translation/models/languages.dart';
import 'package:learn_with_translation/models/translation_api.dart';
import 'package:flutter/material.dart';

class TranslationWidget extends StatefulWidget {

  const TranslationWidget({Key? key,
    required this.message,
    required this.fromLanguage,
    required this.toLanguage,
    required this.builder,
  }) : super(key: key);

  final String message;
  final String fromLanguage;
  final String toLanguage;
  final Widget Function(String translation) builder;

  @override
  State<StatefulWidget> createState() {
    return _TranslationWidgetState();
  }
}

class _TranslationWidgetState extends State<TranslationWidget> {
  late String translation = "";

  @override
  Widget build(BuildContext context) {
    //final fromLanguageCode = Translations.getLanguageCode(widget.fromLanguage);
    final toLanguageCode = Languages.getLanguageCode(widget.toLanguage);

    return FutureBuilder(
      future: TranslationApi.translate(widget.message, toLanguageCode),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return buildWaiting();
          default:
            if (snapshot.hasError) {
              translation = 'Could not translate due to Network problems';
            } else {
              if (snapshot.hasData){
                translation = snapshot.data;
              }
              else{
                return const Center(child: CircularProgressIndicator(),);
              }


            }
            return widget.builder(translation);
        }
      },
    );
  }

  Widget buildWaiting() =>
      translation == null ? const Center(child: CircularProgressIndicator(),) : widget.builder(translation);
}