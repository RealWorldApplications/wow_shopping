import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:wow_shopping/app/theme.dart';
import 'package:wow_shopping/backend/backend.dart';
import 'package:wow_shopping/features/cart/widgets/cart_item.dart';
import 'package:wow_shopping/models/cart_item.dart';
import 'package:wow_shopping/utils/formatting.dart';
import 'package:wow_shopping/widgets/app_button.dart';
import 'package:wow_shopping/widgets/app_panel.dart';
import 'package:wow_shopping/widgets/child_builder.dart';
import 'package:wow_shopping/widgets/common.dart';
import 'package:wow_shopping/widgets/top_nav_bar.dart';

@immutable
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _cartPageKey = GlobalKey();
  final _checkoutPanelKey = GlobalKey();
  double _cartBottomInset = 0;
  double _checkoutPanelHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final view = PlatformDispatcher.instance.implicitView!;
      final cartBox = _cartPageKey.currentContext!.findRenderObject() as RenderBox;
      final bottom = cartBox.localToGlobal(Offset(0.0, cartBox.size.height));
      final screenHeight = (view.physicalSize / view.devicePixelRatio).height;
      _cartBottomInset = screenHeight - bottom.dy;
      final panelBox = _checkoutPanelKey.currentContext!.findRenderObject() as RenderBox;
      if (mounted) {
        setState(() {
          _checkoutPanelHeight = panelBox.size.height;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CartItem>>(
      initialData: cartRepo.currentCartItems,
      stream: cartRepo.streamCartItems,
      builder: (BuildContext context, AsyncSnapshot<List<CartItem>> snapshot) {
        final items = snapshot.requireData;
        return SizedBox.expand(
          child: Material(
            key: _cartPageKey,
            child: ChildBuilder(
              builder: (BuildContext context, Widget child) {
                final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: math.max(0.0, keyboardHeight - _cartBottomInset),
                  ),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverTopNavBar(
                          title: items.isEmpty
                              ? const Text('No items in your cart')
                              : Text('${items.length} items in your cart'),
                          pinned: true,
                          floating: true,
                        ),
                        const SliverToBoxAdapter(
                          child: _DeliveryAddressCta(
                              // FIXME: onChangeAddress ?
                              ),
                        ),
                        for (final item in items) //
                          SliverCartItemView(
                            key: Key(item.product.id),
                            item: item,
                          ),
                      ],
                    ),
                  ),
                  CheckoutPanel(
                    key: _checkoutPanelKey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

@immutable
class _DeliveryAddressCta extends StatelessWidget {
  const _DeliveryAddressCta();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: horizontalPadding12 + verticalPadding16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Delivery to '),
                      TextSpan(
                        // FIXME: replace with selected address name
                        text: 'Designer Techcronus',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalMargin4,
                // FIXME: replace with selected address
                Text(
                  '4/C Center Point,Panchvati, '
                  'Ellisbridge, Ahmedabad, Gujarat 380006',
                ),
              ],
            ),
          ),
          AppButton(
            onPressed: () {
              // FIXME open Delivery address screen
            },
            style: AppButtonStyle.outlined,
            label: 'Change',
          ),
        ],
      ),
    );
  }
}

class CheckoutPanel extends StatelessWidget {
  const CheckoutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Decimal>(
      initialData: context.cartRepo.currentCartTotal,
      stream: context.cartRepo.streamCartTotal,
      builder: (BuildContext context, AsyncSnapshot<Decimal> snapshot) {
        final total = snapshot.requireData;
        return AppPanel(
          padding: horizontalPadding24 + topPadding12 + bottomPadding24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order amount:'),
                    Text(formatCurrency(total)),
                  ],
                ),
              ),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 12.0,
                  color: appGreyColor,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your total amount of discount:'),
                    Text('-'),
                  ],
                ),
              ),
              verticalMargin12,
              AppButton(
                onPressed: () {
                  // FIXME: goto checkout
                },
                style: AppButtonStyle.highlighted,
                label: 'Checkout',
              ),
            ],
          ),
        );
      },
    );
  }
}
