import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/shop/presentation/widgets/shop_form_view.dart';

/// Edit the shop's name and contact details (More → Shop profile).
class ShopProfilePage extends StatelessWidget {
  const ShopProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopProfileTitle)),
      body: ShopFormView(
        submitLabel: l10n.actionSave,
        onSaved: () {
          showSavedMessage(context, l10n.shopProfileSaved);
          context.pop();
        },
      ),
    );
  }
}
