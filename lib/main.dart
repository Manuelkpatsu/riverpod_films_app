import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Films App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

@immutable
class Film {
  final int id;
  final String title;
  final String description;
  final String image;
  final bool isFavorite;

  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.isFavorite,
  });

  Film copy({required bool isFavorite}) => Film(
        id: id,
        title: title,
        description: description,
        image: image,
        isFavorite: isFavorite,
      );

  @override
  bool operator ==(covariant Film other) => id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);

  @override
  String toString() =>
      'Film(id: $id, title: $title, description: $description, image: $image, isFavorite: $isFavorite)';
}

const allFilms = [
  Film(
    id: 1,
    title: 'The Shawshank Redemption',
    description: 'Description for the Shawshank Redemption',
    image:
        'https://www.whatspaper.com/wp-content/uploads/2022/03/hd-the-shawshank-redemption-wallpaper-whatspaper-5.jpg',
    isFavorite: false,
  ),
  Film(
    id: 2,
    title: 'The Godfather',
    description: 'Description for The Godfather',
    image:
        'https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_.jpg',
    isFavorite: false,
  ),
  Film(
    id: 2,
    title: 'The Godfather: Part II',
    description: 'Description for The Godfather: Part II',
    image:
        'https://resizing.flixster.com/-XZAfHZM39UwaGJIFWKAE8fS0ak=/v3/t/assets/p6319_p_v8_bc.jpg',
    isFavorite: false,
  ),
  Film(
    id: 4,
    title: 'The Dark Knight',
    description: 'Description for The Dark Knight',
    image:
        'https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_.jpg',
    isFavorite: false,
  ),
  Film(
    id: 5,
    title: 'The Beekeeper',
    description: 'Description for The Beekeeper',
    image:
        'https://m.media-amazon.com/images/M/MV5BYjZmODc5YmQtNjA2Mi00OTIwLWI5OWMtMzgwNGI2NDczNWZlXkEyXkFqcGdeQXVyMTY3ODkyNDkz._V1_.jpg',
    isFavorite: false,
  ),
  Film(
    id: 6,
    title: 'Freelance',
    description: 'Description for Freelance',
    image:
        'https://m.media-amazon.com/images/M/MV5BZmMxNjdiNTYtZmQzMC00NDFjLWE3MjEtYzRkOTE2NDZmMWM3XkEyXkFqcGdeQXVyMjI0NjI0Nw@@._V1_.jpg',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void update({required Film film, required bool isFavorite}) {
    state = state
        .map(
            (thisFilm) => thisFilm.id == film.id ? thisFilm.copy(isFavorite: isFavorite) : thisFilm)
        .toList();
  }
}

enum FavoriteStatus { all, favorite, notFavorite }

final favoriteStatusProvider = StateProvider<FavoriteStatus>((_) => FavoriteStatus.all);

// All films
final allFilmsProvider = StateNotifierProvider<FilmsNotifier, List<Film>>((_) => FilmsNotifier());

// Favorite films
final favoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite),
);

// Not Favorite films
final notFavoriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Films')),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);

              switch (filter) {
                case FavoriteStatus.all:
                  return FilmsList(provider: allFilmsProvider);
                case FavoriteStatus.favorite:
                  return FilmsList(provider: favoriteFilmsProvider);
                case FavoriteStatus.notFavorite:
                  return FilmsList(provider: notFavoriteFilmsProvider);
              }
            },
          )
        ],
      ),
    );
  }
}

class FilmsList extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;

  const FilmsList({required this.provider, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: films.length,
        separatorBuilder: (ctx, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final film = films.elementAt(index);

          return Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(film.image),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      film.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(film.description),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {
                  ref.read(allFilmsProvider.notifier).update(
                        film: film,
                        isFavorite: !film.isFavorite,
                      );
                },
                splashRadius: 20,
                icon: Icon(film.isFavorite ? Icons.favorite : Icons.favorite_border),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavoriteStatus.values
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: FavoriteStatusText(favoriteStatus: status),
                  ))
              .toList(),
          onChanged: (status) {
            ref.read(favoriteStatusProvider.notifier).state = status!;
          },
        );
      },
    );
  }
}

class FavoriteStatusText extends StatelessWidget {
  final FavoriteStatus favoriteStatus;

  const FavoriteStatusText({
    Key? key,
    required this.favoriteStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String favoriteStatusText() {
      switch (favoriteStatus) {
        case FavoriteStatus.all:
          return 'All';
        case FavoriteStatus.favorite:
          return 'Favorite';
        case FavoriteStatus.notFavorite:
          return 'Not Favorite';
      }
    }

    return Text(favoriteStatusText());
  }
}
