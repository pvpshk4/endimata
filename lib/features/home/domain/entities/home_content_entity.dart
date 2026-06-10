import 'package:equatable/equatable.dart';

class HomeContentEntity extends Equatable {
  final String title;
  final String description;
  const HomeContentEntity({required this.title, required this.description});

  HomeContentEntity copyWith({String? title, String? description}) {
    return HomeContentEntity(
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object> get props => [title, description];
}
