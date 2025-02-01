
import 'package:cupms/studentAccess/model/silder_model.dart';
import 'package:flutter/gestures.dart';

List<sliderModel>getSliders(){
  List<sliderModel>slider=[];
  sliderModel categorymodel = new sliderModel();

  categorymodel.image = "assets/a.png";
  slider.add(categorymodel);
  categorymodel = new sliderModel();

  categorymodel.image ="assets/b.png";
  slider.add(categorymodel);
  categorymodel = new sliderModel();

  categorymodel.image = "assets/c.png";
  slider.add(categorymodel);
  categorymodel = new sliderModel();

  categorymodel.image ="assets/d.png";
  slider.add(categorymodel);
  categorymodel = new sliderModel();


  return slider;
}
