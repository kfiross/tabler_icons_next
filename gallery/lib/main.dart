import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tabler_icons_next/tabler_icons_next.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'icons.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final packageInfo = await PackageInfo.fromPlatform();

  runApp(GalleryApp(version: packageInfo.version));
}

const _appName = 'Tabler Icons Next';

class GalleryApp extends StatelessWidget {
  const GalleryApp({
    super.key,
    required this.version,
  });

  final String version;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(version: version),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.version,
  });

  final String version;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late final TextEditingController _searchController;
  final _iconNames = icons.keys.toList();
  late List<String> _filteredIcons = _iconNames;
  final List<num> strokeTypes = [1, 1.25, 1.5, 1.75, 2];
  var _selections = [false, false, false, false, true];
  num _strokeType = 2;


  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController()
      ..addListener(() {
        final keyword = _searchController.text.toLowerCase();
        if (keyword.isEmpty) {
          setState(() => _filteredIcons = _iconNames);
          return;
        }
        setState(() => _filteredIcons = _iconNames
            .where((name) => name.toLowerCase().contains(keyword))
            .toList());
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          children: [
            // App title
            const Text(_appName),
            const SizedBox(width: 16),

            // Version
            Text(widget.version, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 60),
            const Text("Stroke: ", style: TextStyle(fontSize: 14),),
            ToggleButtons(
              onPressed: (int index){
                setState(() {
                  _strokeType = strokeTypes[index];
                  _selections = List.generate(strokeTypes.length, (i) => index == i);
                });
              },
              isSelected: _selections,
            children: const [
              Text("1"),
              Text("1.25"),
              Text("1.5"),
              Text("1.75"),
              Text("2"),
            ],),
            // Search
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                  prefixIcon: Icon(TablerIcons.search, size: 18),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              const SizedBox(width: 16),

              // GitHub
              IconButton(
                icon: const Icon(TablerIcons.brandGithub),
                onPressed: () {
                  launchUrlString('https://github.com/beta/tabler_icons_next');
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
        ),
        itemCount: _filteredIcons.length,
        itemBuilder: (context, index) {
          return IconView(
            TablerIcon(icons[_filteredIcons[index]]!, strokeWidth: _strokeType.toDouble(),),
            name: _filteredIcons[index],
          );
        },
      ),
    );
  }
}

class IconView extends StatefulWidget {
  const IconView(
    this.icon, {
    super.key,
    required this.name,
  });

  final TablerIcon icon;
  final String name;

  @override
  State<StatefulWidget> createState() => _IconViewState();
}

class _IconViewState extends State<IconView> {
  bool _hover = false;
  void setHover(bool hover) => setState(() => _hover = hover);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setHover(true),
      onExit: (_) => setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          border: Border.all(
            color: _hover ? Colors.black38 : Colors.transparent,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: widget.icon,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
