import 'package:app_settings/app_settings.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pauseguitare/models/programme.dart';
import 'package:pauseguitare/models/programme_artist.dart';
import 'package:pauseguitare/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<ProgrammeArtist> favoriteArtists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 1. Fetch saved IDs and match them to the schedule data
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedIds = prefs.getStringList('favorites') ?? [];

    // Load the local JSON file containing all the schedule data
    final String response = await rootBundle.loadString(
      'assets/data/programme.json',
    );
    final data = await json.decode(response);

    // Parse the JSON into Programme and ProgrammeArtist objects
    List<Programme> fullSchedule = (data as List)
        .map((e) => Programme.fromJSON(e))
        .toList();

    List<ProgrammeArtist> matchedFavorites = [];

    // Search the schedule to find the artists that match the saved IDs
    for (var day in fullSchedule) {
      if (day.programmeArtists != null) {
        for (var artist in day.programmeArtists!) {
          if (savedIds.contains(artist.id)) {
            matchedFavorites.add(artist);
          }
        }
      }
    }

    setState(() {
      favoriteArtists = matchedFavorites;
      isLoading = false;
    });
  }

  // 2. Remove an item from SharedPreferences and the visible list
  Future<void> _removeFavorite(String artistId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedIds = prefs.getStringList('favorites') ?? [];

    savedIds.remove(artistId);
    await prefs.setStringList('favorites', savedIds);

    setState(() {
      favoriteArtists.removeWhere((artist) => artist.id == artistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Profil'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'Favoris'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: The Favorites List
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : favoriteArtists.isEmpty
                ? const Center(child: Text("Vous n'avez pas de favoris."))
                : ListView.builder(
                    itemCount: favoriteArtists.length,
                    itemBuilder: (context, index) {
                      final artist = favoriteArtists[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            artist.artistName ?? 'Inconnu',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${artist.day ?? ""} \nDe ${artist.timeStart ?? ""} à ${artist.timeEnd ?? ""}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: AppColors.primary),
                            onPressed: () => _removeFavorite(artist.id!),
                          ),
                        ),
                      );
                    },
                  ),

            // TAB 2: Notifications
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Activez les notifications pour cette application dans les réglages de votre appareil, pour choisir les informations à recevoir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // This opens the phone's notification settings!
                      AppSettings.openAppSettings(
                        type: AppSettingsType.notification,
                      );
                    },
                    child: const Text('Accéder aux réglages'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
