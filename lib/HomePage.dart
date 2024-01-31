import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController plateNumber = TextEditingController();
  bool isValid = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const SizedBox(height: 60),
      TextField(
          controller: plateNumber,
          maxLength: 4,
          keyboardType: TextInputType.none,
          decoration: InputDecoration(
              errorText: isValid ? null : 'Enter 4 digit number.',
              label: const Text(''),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)))),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('OCR')),
          ElevatedButton(onPressed: () {}, child: const Text('Voice')),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Container(
              height: 240,
              width: 300,
              color: Colors.grey[100],
              child: const Text('Search Results')),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Time IN',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Time OUT',
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),
      Container(
          // padding: EdgeInsets.only(top: 10, bottom: 20, left: MediaQuery.of(context).size.width/3.8),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                numButton(
                  number: '1',
                ),
                numButton(
                  number: '2',
                ),
                numButton(
                  number: '3',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                numButton(
                  number: '4',
                ),
                numButton(
                  number: '5',
                ),
                numButton(
                  number: '6',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                numButton(
                  number: '7',
                ),
                numButton(
                  number: '8',
                ),
                numButton(
                  number: '9',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 120,),
                numButton(
                  number: '0',
                ),
                ElevatedButton(
                    onPressed: () {
                      plateNumber.text = plateNumber.text
                          .substring(0, plateNumber.text.length - 1);
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 65)),
                    child: const Text('DEL'))
              ],
            ),
          ])),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[200], minimumSize: const Size(250, 60)),
        child: const Text('Search'),
        onPressed: () {
          if (plateNumber.text.isEmpty) {
            setState(() {
              isValid = false;
            });
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(plateNumber.text)));
            plateNumber.text = "";
            setState(() {
              isValid = true;
            });
          }
        },
      )
    ]));
  }

  ElevatedButton numButton({required String number}) => ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(120, 65)),
        child: Text(number),
        onPressed: () {
          plateNumber.text += number;
          plateNumber.value = TextEditingValue(
              text: plateNumber.text,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: plateNumber.text.length)));
        },
      );
}
