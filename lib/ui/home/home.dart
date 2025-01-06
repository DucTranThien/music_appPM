import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/now_playing/playing.dart';
import 'package:music_app/ui/home/viewmodel.dart';
import 'package:music_app/ui/settings/settings.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music PM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music PM'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  late List<Song> hitSongs;
  late MusicAppViewModel _viewModel;
  TextEditingController _searchController = TextEditingController();
  late Timer _autoScrollTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double nextPosition = _scrollController.offset + 150;
        if (nextPosition >= _scrollController.position.maxScrollExtent) {
          nextPosition = 0;
        }
        _scrollController.animateTo(
          nextPosition,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    _autoScrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANG CHỦ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              onChanged: filterSongs,
              placeholder: 'Tìm kiếm bài hát hoặc nghệ sĩ...',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (hitSongs.isNotEmpty) _buildHitSongCarousel(),
          Expanded(child: getBody()),
        ],
      ),
    );
  }

  Widget _buildHitSongCarousel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bài hát nổi bật',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: hitSongs.length,
              itemBuilder: (context, index) {
                final song = hitSongs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/itunes_256.png',
                              image: song.image,
                              width: 150,
                              height: 100,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/itunes_256.png',
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Hit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget getBody() {
    if (filteredSongs.isEmpty && _searchController.text.isEmpty) {
      return getProgressBar();
    } else if (filteredSongs.isEmpty) {
      return getNoResultsView();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget getNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text('Không tìm thấy kết quả', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  ListView getListView() {
    return ListView.separated(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) => getRow(index),
      separatorBuilder: (context, index) => const Divider(color: Colors.grey, thickness: 1),
    );
  }

  Widget getRow(int index) {
    final song = filteredSongs[index];
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(song.image, width: 48, height: 48, errorBuilder: (_, __, ___) {
          return Image.asset('assets/itunes_256.png', width: 48, height: 48);
        }),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      onTap: () => navigate(song),
    );
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs = songList;
        hitSongs = songs.where((song) => song.title.contains('Đ')).toList();
        filteredSongs = List.from(songs);
      });
    });
  }

  void filterSongs(String query) {
    setState(() {
      filteredSongs = songs
          .where((song) => song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => NowPlaying(songs: songs, playingSong: song)));
  }
}
