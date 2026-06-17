import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:prod_kagitoban_app/core/api_loading_controller.dart';
import 'package:prod_kagitoban_app/models/ModelProvider.dart';

class LineUserService {
  static Future<List<LineUser>> listLineUsers() async {
    final users = <LineUser>[];
    var request = ModelQueries.list<LineUser>(
      LineUser.classType,
      authorizationMode: APIAuthorizationType.userPools,
      limit: 100,
    );

    while (true) {
      final response = await ApiLoadingController.instance.run(
        () => Amplify.API.query(request: request).response,
      );

      if (response.errors.isNotEmpty) {
        throw Exception(response.errors.first.message);
      }

      final page = response.data;
      if (page == null) break;

      users.addAll(page.items.whereType<LineUser>());

      final nextRequest = page.requestForNextResult;
      if (nextRequest == null) break;

      request = nextRequest;
    }

    return users;
  }
}
