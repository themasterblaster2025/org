import 'package:localdelivery_flutter/main/models/models.dart';

List<WalkThroughItemModel> getWalkThroughItems(){
  List<WalkThroughItemModel> list = [];
  list.add(WalkThroughItemModel(image: 'assets/walk_through1.png',title: 'Select Pickup Location',subTitle: 'It helps us to get package from your doorstep.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through2.png',title: 'Select Drop Location',subTitle: 'So that we can deliver the package to the correct person quickly.'));
  list.add(WalkThroughItemModel(image: 'assets/walk_through3.png',title: 'Confirm And Relax',subTitle: 'We will deliver your package on time and in perfect condition.'));
  return list;
}