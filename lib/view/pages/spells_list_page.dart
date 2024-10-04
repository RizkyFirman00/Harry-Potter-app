import 'package:flutter/material.dart';
import 'package:hni_project/view_model/spell_vm.dart';
import 'package:provider/provider.dart';
import '../../model/spells.dart';

class ListSpells extends StatefulWidget {
  const ListSpells({super.key});

  @override
  State<ListSpells> createState() => _ListSpellsState();
}

class _ListSpellsState extends State<ListSpells> {
  bool isSearchButtonClicked = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Spell> filteredSpells = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    final spellViewModel = Provider.of<SpellViewModel>(context, listen: false);
    spellViewModel.fetchSpells();
  }

  void updateSearchResults(String query) {
    final spellViewModel = Provider.of<SpellViewModel>(context, listen: false);
    setState(() {
      this.query = query;
      filteredSpells = spellViewModel.spell
          .where(
              (spell) => spell.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff2A291E),
        foregroundColor: Colors.white,
        title: isSearchButtonClicked
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextField(
                  focusNode: _searchFocus,
                  controller: _searchController,
                  onChanged: updateSearchResults,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                      border: InputBorder.none,
                      hintText: "Search Spells..."),
                ),
              )
            : Text("Spells"),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.keyboard_arrow_left_rounded),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                setState(
                  () {
                    isSearchButtonClicked = !isSearchButtonClicked;
                    if (isSearchButtonClicked) {
                      FocusScope.of(context).requestFocus(_searchFocus);
                    } else {
                      _searchController.clear();
                      updateSearchResults('');
                      FocusScope.of(context).unfocus();
                    }
                  },
                );
              },
              icon: Icon(isSearchButtonClicked ? Icons.close : Icons.search),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SpellViewModel>(
          builder: (context, spellViewModel, child) {
            final spells = query.isEmpty ? spellViewModel.spell : filteredSpells;
            return spellViewModel.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : spells.isEmpty
                    ? Center(
                        child: Text("Data Not Found"),
                      )
                    : ListView.builder(
                        itemCount: spells.length,
                        itemBuilder: (context, index) {
                          final spell = spells[index];
                          return ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(spell.name),
                                      content: Text(spell.description),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Close"))
                                      ],
                                    );
                                  });
                            },
                            title: Text(spell.name),
                          );
                        },
                      );
          },
        ),
      ),
    );
  }
}