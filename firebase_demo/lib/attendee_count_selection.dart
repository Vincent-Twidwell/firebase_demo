import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/widgets.dart';

class AttendeeCountSelection extends StatefulWidget {
  const AttendeeCountSelection(
      {super.key, required this.count, required this.onSelection});
  final int count;
  final void Function(int count) onSelection;

  @override 
  State<AttendeeCountSelection> createState() => _AttendeeCountSelectionState();
}

class _AttendeeCountSelectionState extends State<AttendeeCountSelection> {
  late final TextEditingController _controller =TextEditingController(text: '${widget.count}');

  @override
  void didUpdateWidget(AttendeeCountSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count){
      _controller.text = '${widget.count}';
    }
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = (int.tryParse(_controller.text) ?? 0).clamp(0,99);
    _controller.text = '$value';
    widget.onSelection(value);
    FocusScope.of(context).unfocus();
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'People attending',
                helperText: '0 = not going',
              ),
              onSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(width: 8),
          StyledButton(
            onPressed: _save,
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}