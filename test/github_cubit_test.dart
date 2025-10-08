import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:gitpeek/cubit/github_cubit.dart';
import 'package:gitpeek/models/repo.dart';
import 'package:gitpeek/services/github_service.dart';

class MockGithubService extends GithubService {
  bool shouldThrow = false;

  @override
  Future<List<Repo>> fetchRepos(String username) async {
    if (shouldThrow) throw Exception('User not found');
    return [Repo(name: 'test_repo', description: 'A test repo', language: 'Dart')];
  }
}

void main() {
  late GithubCubit cubit;
  late MockGithubService mockService;

  setUp(() {
    mockService = MockGithubService();
    cubit = GithubCubit(mockService);
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<GithubCubit, GithubState>(
    'emits [Loading, Loaded] when fetchRepos succeeds',
    build: () => cubit,
    act: (cubit) => cubit.fetchRepos('valid_user'),
    expect: () => [isA<GithubLoading>(), isA<GithubLoaded>()],
  );

  blocTest<GithubCubit, GithubState>(
    'emits [Loading, Error] when fetchRepos fails',
    build: () {
      mockService.shouldThrow = true;
      return GithubCubit(mockService);
    },
    act: (cubit) => cubit.fetchRepos('invalid_user'),
    expect: () => [isA<GithubLoading>(), isA<GithubError>()],
  );
}
