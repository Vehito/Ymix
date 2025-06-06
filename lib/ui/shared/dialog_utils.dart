import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.warning),
            title: const Text('Are you sure?'),
            content: Text(message),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ActionButton(
                      actionText: 'No',
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                    ),
                  ),
                  Expanded(
                    child: ActionButton(
                        actionText: 'Yes',
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        }),
                  )
                ],
              )
            ],
          ));
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.error),
            title: const Text('An Error Occurred!'),
            content: Text(message),
            actions: <Widget>[
              ActionButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ));
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.actionText,
    this.onPressed,
  });

  final String? actionText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        actionText ?? 'Okay',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
            ),
      ),
    );
  }
}

void showSnackBar(
    {required BuildContext context,
    required String message,
    Color? textColor,
    Color? color}) {
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: textColor)),
    backgroundColor: color,
    duration: const Duration(seconds: 5),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
