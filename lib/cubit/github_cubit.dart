import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gitpeek/models/repo.dart';
import 'package:gitpeek/services/github_service.dart';

class GithubState {
  const GithubState();
}

class GithubInitial extends GithubState {}

class GithubLoading extends GithubState {}

class GithubLoaded extends GithubState {
  GithubLoaded(this.repos);
  final List<Repo> repos;
}

class GithubError extends GithubState {
  GithubError(this.message);
  final String message;
}

class GithubCubit extends Cubit<GithubState> {
  GithubCubit(this.service) : super(GithubInitial());
  final GithubService service;

  Future<void> fetchRepos(String username) async {
    emit(GithubLoading());
    try {
      final repos = await service.fetchRepos(username);
      emit(GithubLoaded(repos));
    } catch (e) {
      emit(GithubError(e.toString()));
    }
  }
}
