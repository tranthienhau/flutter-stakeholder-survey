import 'package:flutter/material.dart';

import '../../data/models/question.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                question.prompt,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (question.required) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        _input(context),
      ],
    );
  }

  Widget _input(BuildContext context) {
    switch (question.type) {
      case QuestionType.shortText:
        return TextFormField(
          initialValue: value as String? ?? '',
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: onChanged,
        );
      case QuestionType.longText:
        return TextFormField(
          initialValue: value as String? ?? '',
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: onChanged,
        );
      case QuestionType.rating:
        final v = (value as int?) ?? 0;
        return Row(
          children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(i < v ? Icons.star : Icons.star_border, color: Colors.amber),
              onPressed: () => onChanged(i + 1),
            );
          }),
        );
      case QuestionType.singleChoice:
        return Column(
          children: question.choices
              .map((c) => RadioListTile<String>(
                    value: c,
                    groupValue: value as String?,
                    title: Text(c),
                    onChanged: (v) => onChanged(v),
                  ))
              .toList(),
        );
      case QuestionType.multiChoice:
        final list = ((value as List?) ?? []).cast<String>();
        return Column(
          children: question.choices
              .map((c) => CheckboxListTile(
                    value: list.contains(c),
                    title: Text(c),
                    onChanged: (checked) {
                      final next = List<String>.from(list);
                      if (checked == true) {
                        next.add(c);
                      } else {
                        next.remove(c);
                      }
                      onChanged(next);
                    },
                  ))
              .toList(),
        );
    }
  }
}
