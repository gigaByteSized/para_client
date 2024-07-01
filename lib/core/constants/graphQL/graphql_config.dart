import 'package:flutter/cupertino.dart';
import 'package:para_client/core/constants/constants.dart';
import 'package:para_client/core/constants/graphQL/graphql_base_queries.dart';
// import 'package:para_client/src/destination_selected_map/presentation/graphql/itinerary_model.dart';

HttpLink httpLink = HttpLink(itineraryAPIBaseURL);
ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

// class GraphqlConfig {
//   // GraphQLClient clientToQuery() => GraphQLClient(
//   //       link: httpLink,
//   //       cache: GraphQLCache(),
//   //     );

//   Future<List<ItineraryModel>> getItineraries({
//     required double fromLat,
//     required double fromLon,
//     required double toLat,
//     required double toLon,
//     required String date,
//     required String time,
//     required List<Map<String, String>> transportModes,
//   }) async {
//     try {
//       QueryResult result = await client.value.query(
//         QueryOptions(
//           document: gql(getItinerariesQuery),
//           variables: {
//             'fromLat': fromLat,
//             'fromLon': fromLon,
//             'toLat': toLat,
//             'toLon': toLon,
//             'date': date,
//             'time': time,
//             'transportModes': transportModes,
//           },
//         ),
//       );

//       if (result.hasException) {
//         throw Exception(result.exception.toString());
//       }

//       List? res = result.data?['plan']['itineraries'];

//       if (res == null) {
//         return [];
//       }

//       List<ItineraryModel> itineraries =
//           res.map((e) => ItineraryModel.fromMap(e)).toList();

//       return itineraries;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
