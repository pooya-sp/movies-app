import 'package:flutter/material.dart';
import 'package:movies_app/helpers/db_helper.dart';
import 'package:movies_app/locale/app_localization.dart';
import 'package:movies_app/modals/config.dart';
import 'package:movies_app/providers/movies_provider.dart';
import 'package:movies_app/screens/movies_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchData extends SearchDelegate<String> {
  List<Movie> allMovies;
  List<Movie> recentSearches = [];
  BuildContext context;
  List<Movie> suggestionList;
  SearchData(this.context) : super(textInputAction: TextInputAction.done) {
    allMovies = Provider.of<MoviesProvider>(context, listen: false).allMovies;
    DBHelper.getData('movies_table').then((value) {
      recentSearches = value
          .map(
            (element) => Movie(
              posterImage: element['posterImage'],
              title: element['title'],
              overview: element['overview'],
              id: element['id'],
              isFavorite: element['isFavorite'] == 1 ? true : false,
            ),
          )
          .toList();
    });
  }
  TextStyle posRes = TextStyle(
        color: Colors.red,
        fontSize: 18,
      ),
      negRes = TextStyle(
        color: currentTheme.isDark ? Colors.white : Colors.black,
        fontSize: 18,
      );
  @override
  TextStyle get searchFieldStyle => currentTheme.isDark
      ? TextStyle(color: Colors.grey)
      : TextStyle(color: Theme.of(context).hintColor);
  @override
  String get searchFieldLabel => AppLocalization.of(context).search;
  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: currentTheme.isDark
            ? Color.fromRGBO(41, 82, 163, 0.3)
            : Colors.white,
        textTheme: theme.textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    showSuggestions(context);
    FocusScope.of(context).unfocus();
    return Center();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(builder: (ctx, setState) {
      suggestionList = query.isEmpty
          ? recentSearches
          : allMovies
              .where((element) =>
                  element.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.length > 0 && query.isEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      recentSearches = [];
                      DBHelper.deleteData('movies_table');
                    });
                  },
                  child: Text(
                    AppLocalization.of(context).clearHistory,
                    style: TextStyle(
                        color: Theme.of(context).hintColor, fontSize: 18),
                  )),
            ),
          if (recentSearches.length == 0 && query.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  AppLocalization.of(context).enterKeyword,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          if (suggestionList.length == 0 && query.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  AppLocalization.of(context).noResultsFound,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: suggestionList.length,
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        this.close(context, query);
                        final response = await Navigator.pushNamed(
                            context, MoviesDetailScreen.routeName,
                            arguments: suggestionList[index]) as Movie;
                        DBHelper.insert('movies_table', {
                          'posterImage': response.posterImage,
                          'title': response.title,
                          'overview': response.overview,
                          'id': response.id,
                          'isFavorite': response.isFavorite ? 1 : 0,
                        });
                      },
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                            'https://image.tmdb.org/t/p/w154${suggestionList[index].posterImage}'),
                      ),
                      title: RichText(
                        text: searchMatch(suggestionList[index].title),
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).dividerColor,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  TextSpan searchMatch(String movieTitle) {
    if (query == null || query == "")
      return TextSpan(text: movieTitle, style: negRes);
    var refinedMovieTitle = movieTitle.toLowerCase();
    var refinedSearch = query.toLowerCase();
    if (refinedMovieTitle.contains(refinedSearch)) {
      if (refinedMovieTitle.substring(0, refinedSearch.length) ==
          refinedSearch) {
        return TextSpan(
          style: posRes,
          text: movieTitle.substring(0, refinedSearch.length),
          children: [
            searchMatch(
              movieTitle.substring(
                refinedSearch.length,
              ),
            ),
          ],
        );
      } else if (refinedMovieTitle.length == refinedSearch.length) {
        return TextSpan(text: movieTitle, style: posRes);
      } else {
        return TextSpan(
          style: negRes,
          text: movieTitle.substring(
            0,
            refinedMovieTitle.indexOf(refinedSearch),
          ),
          children: [
            searchMatch(
              movieTitle.substring(
                refinedMovieTitle.indexOf(refinedSearch),
              ),
            ),
          ],
        );
      }
    } else if (!refinedMovieTitle.contains(refinedSearch)) {
      return TextSpan(text: movieTitle, style: negRes);
    }
    return TextSpan(
      text: movieTitle.substring(0, refinedMovieTitle.indexOf(refinedSearch)),
      style: negRes,
      children: [
        searchMatch(
            movieTitle.substring(refinedMovieTitle.indexOf(refinedSearch)))
      ],
    );
  }
}
