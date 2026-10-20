import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final VoidCallback? retryAction;

  const ErrorView({super.key, this.retryAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppText.t('common.error_title'),
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 44,
            ),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                  ),
                  onPressed: () {
                    if (retryAction != null) {
                      retryAction!();
                    }
                  },
                  child: Text(
                    AppText.t('common.retry'),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
