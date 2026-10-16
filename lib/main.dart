import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const VitalApp());

class VitalApp extends StatelessWidget {
  const VitalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compras VITAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      home: const HomePage(),
    );
  }
}

/* ============================================================
   MODELO
   ============================================================ */
class Categoria {
  final String nombre;
  final String emoji;
  final List<String> items;
  const Categoria({
    required this.nombre,
    required this.emoji,
    required this.items,
  });
}

const List<Categoria> categorias = [
  Categoria(
    nombre: 'LIMPIEZA',
    emoji: '🧴',
    items: [
      'Blem', 'Cif Baño', 'Cif Crema', 'Cif ultra rapido', 'Detergente',
      'Escobillon', 'Esp de Acero', 'Espongitas', 'Harpic', 'Jabón blanco',
      'Lavandina', 'Limpia Horno', 'Limpia vidrio', 'Lisoform',
      'Palo para secador', 'Pooet', 'Skip', 'Suabizante', 'Trapo amarillo',
      'Trapo de Piso', 'Trenet', 'Virulana',
    ],
  ),
  Categoria(
    nombre: 'ALMACÉN',
    emoji: '🥫',
    items: [
      'Aceite', 'Aceitunas', 'Alfajores', 'Arbejas', 'Arroz',
      'Arroz saborizado', 'Atum', 'Azúcar', 'Barbacoa', 'Café', 'Caldo',
      'Chanpiñon', 'Choclo en grano', 'Durazno en lata',
      'Edulcorante Liquido', 'Edulcorante Sobre', 'Escarvadientes',
      'Espinaca en lata', 'Fideos', 'Fideos Largos', 'Flan', 'Fosforos',
      'Fritolin', 'Galletitas', 'Galletitas de agua', 'Gelatina',
      'Harina común', 'Harina de Piza', 'Harina leudante', 'Ketchup',
      'Lasagna', 'Lentejas en paquete', 'matecosido', 'Mayonesa', 'Mostaza',
      'Nescafe Gold de granitos', 'Nesquik', 'Orégano', 'Pan rallado',
      'Pate', 'Polenta', 'Pure chef', 'Remolacha en lata', 'Sal fina',
      'Sal gruesa', 'Salsa de soja', 'Salsa Kaesa', 'Salsa teriyaqui',
      'Sobre Limonada', 'Sobres de TANG', 'Te', 'Tomate en Cajita',
      'Tomate en Sache', 'Vinagre', 'Yerba', 'Zucaritas',
    ],
  ),
  Categoria(
    nombre: 'HELADERA',
    emoji: '🧊',
    items: [
      'Casancrem', 'Crema', 'Dulce de Leche', 'Fiambres', 'Finlandia',
      'Jardinera', 'Leche', 'Manteca', 'Milanesa de Calabaza',
      'Milanesa de espinaca', 'Milanesa de Pescado', 'Milanesa de Soja',
      'Pan', 'Papas de frízer', 'Patitas', 'Quesos todos',
      'Rapiditas chicas', 'Tapas de empanadas', 'Tapas de tarta',
      'Yogur para pili de frutilla', 'Yogur para ponerle cereales',
    ],
  ),
  Categoria(
    nombre: 'PAQUETES',
    emoji: '🧻',
    items: ['Papel de cocina', 'Papel Higiénico'],
  ),
];

/* ============================================================
   HOME: elegir categoría
   ============================================================ */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Compras VITAL'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final cat = categorias[i];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Text(cat.emoji, style: const TextStyle(fontSize: 34)),
              title: Text(
                cat.nombre,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${cat.items.length} artículos'),
              trailing: const Icon(Icons.chevron_right, size: 28),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoriaPage(categoria: cat),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ============================================================
   PANTALLA DE CATEGORÍA
   ============================================================ */
class CategoriaPage extends StatefulWidget {
  final Categoria categoria;
  const CategoriaPage({super.key, required this.categoria});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  final Set<String> _seleccionados = {};
  bool _soloSeleccionados = false;

  String get _prefsKey => 'vital_${widget.categoria.nombre}';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardados = prefs.getStringList(_prefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _seleccionados
        ..clear()
        ..addAll(guardados);
    });
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _seleccionados.toList());
  }

  void _toggle(String item) {
    setState(() {
      if (_seleccionados.contains(item)) {
        _seleccionados.remove(item);
      } else {
        _seleccionados.add(item);
      }
    });
    _guardar();
  }

  void _limpiar() {
    setState(() => _seleccionados.clear());
    _guardar();
  }

  @override
  Widget build(BuildContext context) {
    final items = _soloSeleccionados
        ? widget.categoria.items.where(_seleccionados.contains).toList()
        : widget.categoria.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoria.emoji} ${widget.categoria.nombre}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            tooltip: _soloSeleccionados ? 'Ver todos' : 'Ver solo seleccionados',
            icon: Icon(
              _soloSeleccionados
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: () =>
                setState(() => _soloSeleccionados = !_soloSeleccionados),
          ),
          IconButton(
            tooltip: 'Limpiar selección',
            icon: const Icon(Icons.clear_all),
            onPressed: _limpiar,
          ),
        ],
      ),
      body: Column(
        children: [
          _contador(context),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Nada seleccionado todavía',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final sel = _seleccionados.contains(item);
                      return _ItemTile(
                        label: item,
                        selected: sel,
                        onTap: () => _toggle(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _contador(BuildContext context) {
    final total = widget.categoria.items.length;
    final sel = _seleccionados.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Text(
            '$sel de $total seleccionados',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : sel / total,
                minHeight: 10,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   OPCIÓN C — Card con tilde grande
   ============================================================ */
class _ItemTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ItemTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AnimatedScale(
                  scale: selected ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? scheme.primary : scheme.outline,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: selected ? TextDecoration.lineThrough : null,
                      decorationThickness: 2,
                      color: selected ? scheme.onPrimaryContainer : null,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
