import 'package:flutter/material.dart';
import 'package:melo_mobile/services/recommender_service.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminRecommenderPage extends StatefulWidget {
  const AdminRecommenderPage({super.key});

  @override
  State<AdminRecommenderPage> createState() => _AdminRecommenderPageState();
}

class _AdminRecommenderPageState extends State<AdminRecommenderPage> {
  late RecommenderService _recommenderService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recommenderService = RecommenderService(context);
  }

  Future<void> trainModels() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await _recommenderService.trainModels();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 38.0;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Recommender",
        ),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (verticalPadding * 2),
                ),
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: verticalPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Train models for the Melo recommender system. Models are trained automatically over a set period of time. You can train them manually, but beware that it might take some time to finish.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: trainModels,
                          child: const Text('Train models'),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
