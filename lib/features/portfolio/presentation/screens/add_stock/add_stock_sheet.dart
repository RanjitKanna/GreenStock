import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../blocs/portfolio/portfolio_bloc.dart';
import '../../blocs/portfolio/portfolio_event.dart';
import '../../blocs/add_stock_cubit.dart';
import '../../../../../core/di/service_locator.dart';
import '../../../domain/usecases/get_stock_price.dart';

class AddStockSheet extends StatefulWidget {
  const AddStockSheet({
    super.key,
    this.prefilledSymbol,
    this.prefilledPrice,
  });
  final String? prefilledSymbol;
  final double? prefilledPrice;

  @override
  State<AddStockSheet> createState() => _AddStockSheetState();
}

class _AddStockSheetState extends State<AddStockSheet> {
  late final TextEditingController _symbolCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _symbolCtrl = TextEditingController(text: widget.prefilledSymbol ?? '');
    _qtyCtrl = TextEditingController();
    _priceCtrl = TextEditingController(
      text: widget.prefilledPrice?.toStringAsFixed(2) ?? '',
    );

    if (widget.prefilledSymbol != null && widget.prefilledPrice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchPrice(context, widget.prefilledSymbol!);
      });
    }
  }

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPrice(BuildContext context, String symbol) async {
    if (symbol.isEmpty) return;
    final cubit = context.read<AddStockCubit>();
    cubit.setFetchingPrice(true);
    final uc = sl<GetStockPrice>();
    final result = await uc(symbol.toUpperCase().trim());
    result.fold((_) {
      cubit.setFetchingPrice(false);
    }, (stock) {
      if (mounted) {
        _priceCtrl.text = stock.price.toStringAsFixed(2);
        cubit.setPrice(stock.price);
        cubit.setFetchingPrice(false);
      }
    });
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<AddStockCubit>();
    final symbol = _symbolCtrl.text.trim().toUpperCase();
    final qty = double.tryParse(_qtyCtrl.text.trim());
    final price = double.tryParse(_priceCtrl.text.trim());

    cubit.updateSymbol(symbol);
    if (qty != null) cubit.updateQuantity(qty.toString());
    if (price != null) cubit.updatePrice(price.toString());

    if (!cubit.validate()) return;

    context
        .read<PortfolioBloc>()
        .add(AddStockEvent(symbol: symbol, quantity: qty!, price: price!));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => AddStockCubit(),
      child: BlocBuilder<AddStockCubit, AddStockState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Add Stock to Portfolio',
                          style: theme.textTheme.titleLarge)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 4),
                  Text('Track its price and green impact',
                          style: theme.textTheme.bodyLarge)
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 300.ms),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _symbolCtrl,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    enabled: widget.prefilledSymbol == null,
                    decoration: InputDecoration(
                      labelText: 'Stock Symbol',
                      hintText: 'e.g. AAPL, TSLA, MSFT',
                      prefixIcon: const Icon(Icons.show_chart_rounded),
                      suffixIcon: state.isFetchingPrice
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      if (v.length >= 2) _fetchPrice(context, v);
                    },
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            prefixIcon: Icon(Icons.numbers_rounded),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          enabled: widget.prefilledPrice == null,
                          decoration: const InputDecoration(
                            labelText: 'Buy Price (\$)',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                      ),
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 8),
                    Text(state.error!,
                        style: TextStyle(color: colors.redScore, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      child: const Text('Add to Portfolio'),
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 300.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().slideY(
          begin: 0.3,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
