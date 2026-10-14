import 'package:flutter/material.dart';
import '../../shared/services/candidate_resolver.dart';

class ConfirmationBottomSheet extends StatefulWidget {
  final List<ResolvedMatch> matches;
  final Function(List<ResolvedMatch> selected) onSave;

  const ConfirmationBottomSheet({
    super.key,
    required this.matches,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required List<ResolvedMatch> matches,
    required Function(List<ResolvedMatch> selected) onSave,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ConfirmationBottomSheet(
        matches: matches,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ConfirmationBottomSheet> createState() => _ConfirmationBottomSheetState();
}

class _ConfirmationBottomSheetState extends State<ConfirmationBottomSheet> {
  late List<ResolvedMatch> _selectedMatches;

  @override
  void initState() {
    super.initState();
    _selectedMatches = List.from(widget.matches);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obras Encontradas (${widget.matches.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.matches.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No encontramos obras conocidas en la imagen. Podés buscar manualmente.'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.matches.length,
                itemBuilder: (context, index) {
                  final match = widget.matches[index];
                  final isSelected = _selectedMatches.contains(match);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedMatches.add(match);
                        } else {
                          _selectedMatches.remove(match);
                        }
                      });
                    },
                    secondary: match.coverUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              match.coverUrl!,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.book, size: 40),
                    title: Text(match.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${match.format.toUpperCase()} ${match.creator != null ? "• ${match.creator}" : ""}'),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: _selectedMatches.isEmpty
                  ? null
                  : () => widget.onSave(_selectedMatches),
              icon: const Icon(Icons.bookmark_add),
              label: Text('Guardar (${_selectedMatches.length})'),
            ),
          ),
        ],
      ),
    );
  }
}