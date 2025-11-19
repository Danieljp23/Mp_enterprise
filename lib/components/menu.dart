import 'package:flutter/material.dart';
import 'package:maple/styles/colors.dart';

class PopupMenuButtonExample extends StatefulWidget {
  @override
  _PopupMenuButtonExampleState createState() => _PopupMenuButtonExampleState();
}

class _PopupMenuButtonExampleState extends State<PopupMenuButtonExample> {
  String _selectedValue = 'Nenhuma opção selecionada';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopupMenuButton Exemplo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Valor selecionado: $_selectedValue',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _selectedValue = value;
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: MyColors.orangeDark,
                size: 40,
              ),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              color: MyColors.orangeMediun,
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Opção 1',
                    child: Text('Opção 1'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Opção 2',
                    child: Text('Opção 2'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Opção 3',
                    child: Text('Opção 3'),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
