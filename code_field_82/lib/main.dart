import 'dart:math';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/paraiso-light.dart';
import 'package:flutter_highlight/themes/paraiso-dark.dart';
import 'package:highlight/languages/all.dart' as languages;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      title: 'code_text_field Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CodeController codeController = CodeController(text: '')
    ..language = languages.builtinLanguages['sql'];

  static List<String> keywordsFromMode(mode) {
    var tips = <String>[
      ...mode?.keywords?.keys ?? [],
    ];
    mode?.contains?.forEach((m) {
      tips.addAll(keywordsFromMode(m));
    });
    return tips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: CodeTheme(
          data: const CodeThemeData(styles: paraisoDarkTheme),
          child: CodeField(
            minLines: 40,
            focusNode: FocusNode(), // Required to show the tip panel.
            controller: codeController,
            lineNumberStyle: const LineNumberStyle(
                textStyle: TextStyle(color: Color.fromRGBO(38, 82, 110, 1))),
            background: const Color(0xFF202020),
            autoComplete: CodeAutoComplete<String>(
              // The optionsBuilder will be called when the user types a word
              // and the auto complete panel will display when the options are not empty.
              optionsBuilder: (text, cursorIndex, mode) {
                if (cursorIndex < 0) return [];
                var cursorBefore = text.substring(0, cursorIndex);
                var b = cursorBefore.lastIndexOf(RegExp('\\s'));
                var lastWord = cursorBefore.substring(max(b, 0)).trim();
                List<String> tips = keywordsFromMode(mode);
                if (lastWord.trim().isEmpty) return [];
                return tips
                    .where((element) => element
                        .toLowerCase()
                        .startsWith(lastWord.toLowerCase()))
                    .toList()
                  ..sort((a, b) => a.length.compareTo(b.length));
              },
              // when we get the tips, we need to build the widget for each tip.
              itemBuilder: (context, tip, selected, onTap) {
                return ListTile(
                  title: Text(
                    tip,
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                  selected: selected,
                  onTap: () {
                    onTap(tip);
                  },
                );
              },
              offset: const Offset(10, 10),
            ),
          ),
        ),
      ),
    );
  }
}
