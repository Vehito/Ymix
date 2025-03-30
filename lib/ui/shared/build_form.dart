import 'package:choice/choice.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:ymix/ui/shared/dialog_utils.dart';
import './format_helper.dart';

Widget buildDateTimeForm(
    {required BuildContext context,
    required DateTime dateTime,
    Color? formColor,
    required ValueChanged<DateTime> onDateSaved,
    String? title,
    bool isMonth = false,
    bool isYear = false}) {
  Widget buildDateForm(FormFieldState<DateTime?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title:
          Text('${title ?? ''}${FormatHelper.dateFormat.format(field.value!)}'),
      trailing: IconButton(
        onPressed: () async {
          field.didChange(
            await showDatePicker(
                  context: context,
                  initialDate: dateTime,
                  firstDate: DateTime(dateTime.year - 1),
                  lastDate: DateTime(dateTime.year + 1),
                ) ??
                field.value,
          );
        },
        icon: const Icon(Icons.change_circle),
      ),
    );
  }

  Widget buildMonthForm(FormFieldState<DateTime?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: Text(
          '${title ?? ''}${FormatHelper.monthFormat.format(field.value!)}'),
      trailing: IconButton(
        onPressed: () async {
          field.didChange(
            await showMonthPicker(
                  context: context,
                  initialDate: dateTime,
                  firstDate: DateTime(dateTime.year - 1),
                  lastDate: DateTime(dateTime.year + 1),
                ) ??
                field.value,
          );
        },
        icon: const Icon(Icons.change_circle),
      ),
    );
  }

  Widget buildYearForm(FormFieldState<DateTime?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title:
          Text('${title ?? ''}${FormatHelper.yearFormat.format(field.value!)}'),
      trailing: IconButton(
        onPressed: () async {
          final year = await showYearPicker(
            context: context,
            initialDate: dateTime,
            firstDate: DateTime(dateTime.year - 5),
            lastDate: DateTime(dateTime.year + 5),
          );
          field.didChange(DateTime(year ?? field.value!.year));
        },
        icon: const Icon(Icons.change_circle),
      ),
    );
  }

  return FormField<DateTime>(
    initialValue: dateTime,
    onSaved: (newValue) => onDateSaved(newValue!),
    builder: (field) => Card(
      color: formColor,
      child: isYear
          ? buildYearForm(field)
          : isMonth
              ? buildMonthForm(field)
              : buildDateForm(field),
    ),
  );
}

Widget buildDateRangeForm({
  required BuildContext context,
  required ValueChanged<dynamic> onDateRangeSaved,
  Color? formColor,
  DateTime? start,
  DateTime? end,
  bool isMonth = false,
  bool isInSameYear = true,
  bool isYear = false,
}) {
  final now = DateTime.now();
  Widget buildDateForm(FormFieldState<DateTimeRange?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: Text(
          '${FormatHelper.dateFormat.format(field.value!.start)} - ${FormatHelper.dateFormat.format(field.value!.end)}'),
      trailing: IconButton(
          onPressed: () async {
            field.didChange(
              await showDateRangePicker(
                      context: context,
                      initialDateRange: field.value,
                      firstDate: DateTime(field.value!.start.year - 2),
                      lastDate: DateTime(field.value!.end.year + 2)) ??
                  field.value,
            );
          },
          icon: const Icon(Icons.change_circle)),
    );
  }

  Widget buildMonthForm(FormFieldState<DateTimeRange?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: Text(
          '${FormatHelper.monthFormat.format(field.value!.start)} - ${FormatHelper.monthFormat.format(field.value!.end)}'),
      trailing: IconButton(
          onPressed: () async {
            await showMonthRangePicker(
              context: context,
              firstDate: DateTime(
                isInSameYear ? now.year : field.value!.start.year - 2,
                1,
              ),
              lastDate: DateTime(
                isInSameYear ? now.year : field.value!.start.year + 2,
                12,
              ),
              rangeList: true,
            ).then((List<DateTime>? selectedValue) {
              field.didChange(
                selectedValue != null
                    ? DateTimeRange(
                        start: selectedValue.first, end: selectedValue.last)
                    : field.value,
              );
            });
          },
          icon: const Icon(Icons.change_circle)),
    );
  }

  Widget buildYearForm(FormFieldState<DateTimeRange?> field) {
    return ListTile(
      leading: const Icon(Icons.calendar_month),
      title: Text(
          '${FormatHelper.yearFormat.format(field.value!.start)} - ${FormatHelper.yearFormat.format(field.value!.end)}'),
      trailing: IconButton(
          onPressed: () async {
            final firstYear = await showYearPicker(
              context: context,
              headerTitle: const Text('Choose first year'),
              firstDate: DateTime(field.value!.start.year - 5),
              lastDate: DateTime(field.value!.start.year + 5),
            );

            if (!context.mounted) return;
            final secondYear = await showYearPicker(
              context: context,
              headerTitle: const Text('Choose second year'),
              firstDate: DateTime(field.value!.start.year - 5),
              lastDate: DateTime(field.value!.start.year + 5),
            );

            field.didChange(
              (firstYear != null && secondYear != null)
                  ? DateTimeRange(
                      start: DateTime(firstYear), end: DateTime(secondYear))
                  : field.value,
            );
          },
          icon: const Icon(Icons.change_circle)),
    );
  }

  return FormField<DateTimeRange?>(
    initialValue: DateTimeRange(
        start: start ?? DateTime.now(), end: end ?? DateTime.now()),
    onSaved: (newDate) => onDateRangeSaved(newDate!),
    validator: (value) {
      if (value == null) return "Invalid Date time range";
      return null;
    },
    builder: (field) => Card(
        color: formColor,
        child: isYear
            ? buildYearForm(field)
            : isMonth
                ? buildMonthForm(field)
                : buildDateForm(field)),
  );
}

Widget buildToggleSwitch(int selectedMode, ValueChanged<int> onModeSaved) {
  return ToggleSwitch(
    animate: true,
    animationDuration: 200,
    centerText: true,
    minWidth: 200,
    initialLabelIndex: selectedMode, // Sử dụng biến trạng thái
    labels: const ['Expenses', 'Income'],
    activeBgColor: const [Colors.lightBlue],
    icons: const [Icons.money_off, Icons.attach_money],
    onToggle: (changedMode) => onModeSaved(changedMode!),
  );
}

Widget buildAmountForm(double? amount, String? title, Color formColor,
    ValueChanged<double> onAmountSaved,
    {ValueChanged<double>? onValueChanged,
    TextEditingController? controller,
    int? decimalDigits}) {
  return Column(
    children: [
      Card(
        color: formColor,
        child: TextFormField(
          controller: controller ??
              TextEditingController(
                text: amount == null
                    ? '0'
                    : decimalDigits == null
                        ? amount.toString()
                        : amount.toStringAsFixed(decimalDigits),
              ),
          autovalidateMode: AutovalidateMode.onUnfocus,
          keyboardType: TextInputType.number,
          onSaved: (newValue) => onAmountSaved(double.parse(newValue!)),
          onChanged: (newValue) {
            if (onValueChanged != null) {
              onValueChanged(double.parse(newValue));
            }
          },
          decoration: InputDecoration(
            hintText: 'Enter ${title ?? 'amount'}',
            icon: const Icon(Icons.attach_money_outlined),
            labelText: title ?? 'Amount *',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (double.tryParse(value) == null || double.tryParse(value) == 0) {
              return 'Invalid amount';
            }
            if (value.length != value.replaceAll(' ', '').length) {
              return 'Amount must not contain any spaces';
            }
            if (double.tryParse(value)! < 0) {
              return "Amount can not be negative";
            }

            return null;
          },
        ),
      ),
    ],
  );
}

Widget buildPromptedChoiceForm(
    List<dynamic>? listItem,
    String? itemId,
    String? selectedItemName,
    String titleListTile,
    Color? formColor,
    Color? dividerColor,
    ValueChanged<String> onValueSaved,
    Function(String? value)? validator) {
  return FormField<String>(
    initialValue: itemId,
    autovalidateMode: AutovalidateMode.always,
    onSaved: (newValue) => onValueSaved(newValue!),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      if (validator != null) return validator(value);
      return null;
    },
    builder: (field) => Card(
      color: formColor,
      child: Column(
        children: [
          ListTile(
            title: Text(titleListTile),
            leading: const Icon(Icons.wallet),
            subtitle: Divider(
              color: dividerColor ?? Colors.black,
            ),
          ),
          PromptedChoice<String>.single(
            title: 'Choose one',
            value: selectedItemName,
            onChanged: (value) => field.didChange(value),
            itemCount: listItem!.length,
            itemBuilder: (state, i) {
              return RadioListTile(
                value: listItem[i].name,
                groupValue: state.single,
                onChanged: (value) {
                  state.select(listItem[i].id!);
                  selectedItemName = listItem[i].name;
                },
                title: ChoiceText(
                  '${listItem[i].name} - ${listItem[i].balance ?? ''}đ',
                  highlight: state.search?.value,
                ),
              );
            },
            promptDelegate: ChoicePrompt.delegateBottomSheet(),
            anchorBuilder: ChoiceAnchor.create(inline: true),
          ),
          buildValidatorContainer(
            field.errorText,
            '$selectedItemName is selected',
          ),
        ],
      ),
    ),
  );
}

Widget buildChoiceChipForm(
  List<dynamic> listItem,
  String? itemId,
  String? selectedItemName,
  String titleForm,
  Color? formColor,
  Color? dividerColor,
  ValueChanged<String> onValueSaved,
  ValueChanged<Map<String, String>> onValueChanged,
) {
  return FormField<String>(
    autovalidateMode: AutovalidateMode.always,
    initialValue: itemId,
    onSaved: (newValue) => onValueSaved(newValue!),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "This field is required";
      }
      return null;
    },
    builder: (field) => Card(
      color: formColor,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu),
            title: Text(titleForm),
            subtitle: Divider(color: dividerColor),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Wrap(
              spacing: 8,
              children: listItem.map((item) {
                return buildChoiceChip(
                    item, field, itemId, selectedItemName, onValueChanged);
              }).toList(),
            ),
          ),
          buildValidatorContainer(
            field.errorText,
            "$titleForm selected: $selectedItemName",
          )
        ],
      ),
    ),
  );
}

Widget buildChoiceChip(
    dynamic item,
    FormFieldState field,
    String? itemId,
    String? selectedItemName,
    ValueChanged<Map<String, String>> onValueChanged) {
  return ChoiceChip(
    label: Text(
      item.name,
      style: const TextStyle(color: Colors.white, fontSize: 15),
    ),
    showCheckmark: false,
    selected: itemId == item.id, // Kiểm tra trạng thái chọn
    onSelected: (selected) {
      if (selected) {
        onValueChanged({item.id: item.name});
        field.didChange(item.id); // Cập nhật giá trị trong form
      }
    },
    color: WidgetStatePropertyAll(item.color.withAlpha(230)),
    avatar: itemId != item.id
        ? Icon(
            item.icon,
            color: Colors.white,
            size: 20,
          )
        : CircleAvatar(
            backgroundColor: Colors.white,
            radius: 40,
            child: Icon(
              Icons.check,
              color: item.color,
              size: 20,
            ),
          ),
    selectedColor: Colors.white,
  );
}

Widget buildValidatorContainer(String? errorText, String successfulText) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    alignment: Alignment.centerLeft,
    child: Text(
      errorText ?? successfulText,
      style: TextStyle(
        color: errorText != null ? Colors.redAccent : Colors.lightBlue,
        fontSize: 15,
      ),
    ),
  );
}

Widget buildTextForm(String? text, String titleForm, Color formColor,
    ValueChanged<String> onTextSaved,
    {bool isTextArea = false}) {
  return Card(
    color: formColor,
    child: TextFormField(
      initialValue: text ?? '',
      maxLines: isTextArea ? 3 : null,
      keyboardType: TextInputType.multiline,
      autovalidateMode: AutovalidateMode.onUnfocus,
      onSaved: (newValue) => onTextSaved(newValue!),
      decoration: InputDecoration(
        hintText: 'Enter your $titleForm',
        icon: const Icon(Icons.text_fields),
        labelText: titleForm,
      ),
      maxLength: 100,
      validator: (value) {
        if (value!.length > 100) {
          return "Max length is 100 characters";
        }
        return null;
      },
    ),
  );
}

Widget buildDateBtn(BuildContext context, ValueChanged<DateTime> onDateChange) {
  return ElevatedButton.icon(
    icon: const Icon(Icons.calendar_month),
    label: const Text("Day"),
    onPressed: () async {
      final currentDate = DateTime.now();
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(currentDate.year - 1),
        lastDate: DateTime(currentDate.year + 1),
      );
      if (selectedDate != null) {
        onDateChange(selectedDate);
      }
    },
  );
}

Widget buildPeriodBtn(
  BuildContext context,
  ValueChanged<DateTimeRange> onPeriodChange,
) {
  return ElevatedButton.icon(
    icon: const Icon(Icons.timelapse),
    label: const Text("Period"),
    onPressed: () async {
      final now = DateTime.now();
      final selectedPeriod = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 1));
      if (selectedPeriod != null) onPeriodChange(selectedPeriod);
    },
  );
}

class Dropdown extends StatefulWidget {
  const Dropdown(this.valueList, this.onPressed, {super.key, this.width});

  final List<String> valueList;
  final double? width;
  final Function(String selectedValue) onPressed;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.valueList.isNotEmpty) {
      selectedValue = widget.valueList.first;
    } else {
      showErrorDialog(context, "Selected value is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      value: selectedValue,
      buttonStyleData: ButtonStyleData(
        height: 40,
        width: widget.width ?? 100,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        elevation: 2,
      ),
      style: const TextStyle(color: Colors.green),
      onChanged: (String? value) {
        setState(() {
          selectedValue = value!;
          widget.onPressed(selectedValue!);
        });
      },
      items: widget.valueList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
