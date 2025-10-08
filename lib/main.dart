import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gitpeek/cubit/github_cubit.dart';
import 'package:gitpeek/services/github_service.dart';
import 'package:gitpeek/models/repo.dart';

void main() {
  runApp(GitPeekApp());
}

class GitPeekApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitPeek',
      home: BlocProvider(create: (_) => GithubCubit(GithubService()), child: GitHubSearchScreen()),
    );
  }
}

class GitHubSearchScreen extends StatefulWidget {
  @override
  _GitHubSearchScreenState createState() => _GitHubSearchScreenState();
}

class _GitHubSearchScreenState extends State<GitHubSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GithubCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('GitPeek')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'GitHub Username',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    cubit.fetchRepos(_controller.text.trim());
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<GithubCubit, GithubState>(
                builder: (context, state) {
                  if (state is GithubInitial) {
                    return const Center(child: Text('Benutzername eingeben'));
                  } else if (state is GithubLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GithubLoaded) {
                    return ListView.builder(
                      itemCount: state.repos.length,
                      itemBuilder: (context, index) {
                        final Repo repo = state.repos[index];
                        return ListTile(
                          title: Text(repo.name),
                          subtitle: Text(repo.description ?? ''),
                          trailing: Text(repo.language ?? ''),
                        );
                      },
                    );
                  } else if (state is GithubError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
