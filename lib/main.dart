import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gitpeek/cubit/github_cubit.dart';
import 'package:gitpeek/services/github_service.dart';
import 'package:gitpeek/models/repo.dart';

void main() {
  runApp(GitPeekApp());
}

class GitPeekApp extends StatelessWidget {
  const GitPeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitPeek',
      home: BlocProvider(create: (_) => GithubCubit(GithubService()), child: GitHubSearchScreen()),
    );
  }
}

class GitHubSearchScreen extends StatefulWidget {
  const GitHubSearchScreen({super.key});

  @override
  State<GitHubSearchScreen> createState() => _GitHubSearchScreenState();
}

class _GitHubSearchScreenState extends State<GitHubSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GithubCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitPeek', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.04,
          horizontal: MediaQuery.of(context).size.width * 0.06,
        ),
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
              onSubmitted: (value) => cubit.fetchRepos(value.trim()),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(
              child: BlocBuilder<GithubCubit, GithubState>(
                builder: (context, state) {
                  if (state is GithubInitial || _controller.text.isEmpty) {
                    return const Center(child: Text('Username eingeben'));
                  } else if (state is GithubLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is GithubLoaded) {
                    return ListView.builder(
                      itemCount: state.repos.length,
                      itemBuilder: (context, index) {
                        final Repo repo = state.repos[index];
                        return ListTile(
                          title: Text(repo.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: repo.description != null ? Text(repo.description!) : null,
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
