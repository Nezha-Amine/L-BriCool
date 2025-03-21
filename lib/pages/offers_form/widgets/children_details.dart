import 'package:flutter/material.dart';

class ChildrenDetailsWidget extends StatefulWidget {
  final List<Map<String, String>> childrenDetails;
  final Function(List<Map<String, String>>) onChildrenDetailsChanged;

  const ChildrenDetailsWidget({
    Key? key,
    required this.childrenDetails,
    required this.onChildrenDetailsChanged,
  }) : super(key: key);

  @override
  _ChildrenDetailsWidgetState createState() => _ChildrenDetailsWidgetState();
}

class _ChildrenDetailsWidgetState extends State<ChildrenDetailsWidget> {
  final List<String> _childTypes = [
    'Baby',
    'Toddler',
    'Preschooler',
    'School-age child',
  ];

  void _addChild() {
    final updatedList = List<Map<String, String>>.from(widget.childrenDetails);
    updatedList.add({'type': 'Baby', 'age': '0 months'});
    widget.onChildrenDetailsChanged(updatedList);
  }

  void _removeChild(int index) {
    if (widget.childrenDetails.length > 1) {
      final updatedList = List<Map<String, String>>.from(widget.childrenDetails);
      updatedList.removeAt(index);
      widget.onChildrenDetailsChanged(updatedList);
    }
  }

  void _updateChildType(int index, String type) {
    final updatedList = List<Map<String, String>>.from(widget.childrenDetails);
    updatedList[index]['type'] = type;
    widget.onChildrenDetailsChanged(updatedList);
  }

  void _updateChildAge(int index, String age) {
    final updatedList = List<Map<String, String>>.from(widget.childrenDetails);
    updatedList[index]['age'] = age;
    widget.onChildrenDetailsChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kid(s) age',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        // List of children with add/remove functionality
        ...List.generate(widget.childrenDetails.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.childrenDetails[index]['type'],
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _updateChildType(index, newValue);
                                }
                              },
                              items: _childTypes.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Text(', '),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.childrenDetails[index]['age'],
                            decoration: InputDecoration(
                              hintText: 'Age',
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              _updateChildAge(index, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeChild(index),
                  color: Colors.red,
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: _addChild,
          icon: Icon(Icons.add_circle_outline),
          label: Text('Add another child'),
        ),
      ],
    );
  }
}