import 'package:flutter/material.dart';
import '../../models/offer.dart';
import '../../repositories/offer_repository.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/neo_widgets.dart';

class OfferFormScreen extends StatefulWidget {
  final String merchantId;
  final Offer? existing;
  const OfferFormScreen({super.key, required this.merchantId, this.existing});
  @override State<OfferFormScreen> createState() => _State();
}
class _State extends State<OfferFormScreen> {
  final _fk   = GlobalKey<FormState>();
  final _repo  = OfferRepository();
  late final TextEditingController _title, _desc, _orig, _price, _qty;
  String _cat = offerCategories.first;
  TimeOfDay _start = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _end   = const TimeOfDay(hour: 19, minute: 0);
  bool _busy = false;
  List<String> _cats = offerCategories;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title        ?? '');
    _desc  = TextEditingController(text: e?.description  ?? '');
    _orig  = TextEditingController(text: e != null ? e.originalPrice.toString() : '');
    _price = TextEditingController(text: e != null ? e.price.toString() : '');
    _qty   = TextEditingController(text: e != null ? e.quantity.toString() : '');
    if (e != null) {
      _cat   = e.category;
      final s = e.pickupFrom.split(':');
      if (s.length == 2) _start = TimeOfDay(hour: int.parse(s[0]), minute: int.parse(s[1]));
      final t = e.pickupTo.split(':');
      if (t.length == 2) _end   = TimeOfDay(hour: int.parse(t[0]), minute: int.parse(t[1]));
    }
    _loadCats();
  }

  Future<void> _loadCats() async {
    final c = await _repo.fetchCategories();
    if (mounted) setState(() {
      _cats = c;
      if (!c.contains(_cat)) _cat = c.first;
    });
  }

  @override void dispose() {
    _title.dispose(); _desc.dispose();
    _orig.dispose();  _price.dispose(); _qty.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(context: context,
        initialTime: isStart ? _start : _end);
    if (t != null) setState(() { if (isStart) _start = t; else _end = t; });
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _busy = true);
    final body = {
      'title':         _title.text.trim(),
      'description':   _desc.text.trim(),
      'category':      _cat,
      'originalPrice': double.parse(_orig.text.trim()),
      'price':         double.parse(_price.text.trim()),
      'quantity':      int.parse(_qty.text.trim()),
      'pickupFrom':    fTimeOfDay(_start),
      'pickupTo':      fTimeOfDay(_end),
    };
    try {
      if (widget.existing == null) {
        await _repo.createOffer(body);
      } else {
        await _repo.updateOffer(widget.existing!.id, body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null ? 'New Offer' : 'Edit Offer')),
      body: Form(
        key: _fk,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title',
                prefixIcon: Icon(Icons.title)),
            validator: (v) => Validators.required(v, label: 'Title')),
          const SizedBox(height: 14),
          TextFormField(controller: _desc, maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _cats.contains(_cat) ? _cat : _cats.first,
            decoration: const InputDecoration(labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined)),
            items: _cats.map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) setState(() => _cat = v); }),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextFormField(controller: _orig,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Original price (TND)',
                  prefixIcon: Icon(Icons.price_change_outlined)),
              validator: Validators.positiveNumber)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Discounted price (TND)',
                  prefixIcon: Icon(Icons.sell_outlined)),
              validator: Validators.positiveNumber)),
          ]),
          const SizedBox(height: 14),
          TextFormField(controller: _qty, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity',
                prefixIcon: Icon(Icons.inventory_2_outlined)),
            validator: Validators.positiveInt),
          const SizedBox(height: 16),
          Text('Pickup window', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text('Start: ${fTimeOfDay(_start)}'),
              onPressed: () => _pickTime(true))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(Icons.access_time_filled),
              label: Text('End: ${fTimeOfDay(_end)}'),
              onPressed: () => _pickTime(false))),
          ]),
          const SizedBox(height: 24),
          NeoButton(
            label: widget.existing == null ? 'Create offer' : 'Save changes',
            onPressed: _busy ? null : _save,
            isLoading: _busy),
        ])));
  }
}
