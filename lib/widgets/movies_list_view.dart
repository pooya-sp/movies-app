import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movies_app/screens/movies_detail_screen.dart';
import 'package:movies_app/providers/movies_provider.dart';
import 'package:sizer/sizer.dart';

class MoviesListView extends StatelessWidget {
  final List<Movie> movies;
  MoviesListView(this.movies);
  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var placeholder = AssetImage('assets/images/placeholder.png');
    return Container(
      width: MediaQuery.of(context).size.width,
      height: orientation == Orientation.portrait
          ? (MediaQuery.of(context).size.height * 0.32)
          : (MediaQuery.of(context).size.height * 0.45),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (movies.length - 50).isNegative ? 0 : movies.length - 50,
        itemBuilder: (ctx, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pushNamed(ctx, MoviesDetailScreen.routeName,
                    arguments: movies[index]);
              },
              child: Container(
                width: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.width * 0.4
                    : MediaQuery.of(context).size.width * 0.3,
                height: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.32
                    : MediaQuery.of(context).size.height * 0.45,
                child: Card(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: orientation == Orientation.portrait
                            ? MediaQuery.of(context).size.height * 0.24
                            : MediaQuery.of(context).size.height * 0.32,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://image.tmdb.org/t/p/w185${movies[index].posterImage}',
                                errorWidget: (ctx, url, error) =>
                                    Image(image: placeholder)),
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.height * 0.06
                              : MediaQuery.of(context).size.height * 0.08,
                          alignment: Alignment.center,
                          child: Text(
                            '${movies[index].title}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 9.sp),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
