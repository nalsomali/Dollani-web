import 'package:flutter_test/flutter_test.dart';
import 'package:web/addMapsScreen.dart';

void main() {
  test("Validate empty name", () {
    String name = "";
    String actual = ValidateName(name);
    expect(actual, "الرجاء ادخال اسم المبنى");
  });
  test("Validate name less than 3", () {
    String name = "فو";
    String actual = ValidateName(name);
    expect(actual, 'يجب ان يحتوي اسم المبنى على ٣ حروف على الاقل');
  });

  test("Validate name more than 20", () {
    String name = "١٢٢كلية الحاسب المعلومات  ";
    String actual = ValidateName(name);
    expect(actual, 'يجب ان لا يتجاوز اسم المبنى  ٢٠ حرف  ');
  });
  test("Validate empty height", () {
    String height = "";
    String actual = ValidateHeight(height);
    expect(actual, 'الرجاء ادخال الطول ');
  });
  test("Validate invalid height", () {
    String height = "20#";
    String actual = ValidateHeight(height);
    expect(actual, 'الرجاء ادخال رقم صحيح ');
  });

  test("Validate invalid height", () {
    String height = "20#";
    String actual = ValidateHeight(height);
    expect(actual, 'الرجاء ادخال رقم صحيح ');
  });

  test("Validate invalid Width(", () {
    String width = "300k";
    String actual = ValidateWidth(width);
    expect(actual, 'الرجاء ادخال رقم صحيح ');
  });
  test("Validate invalid Width(", () {
    String width = "";
    String actual = ValidateWidth(width);
    expect(actual, 'الرجاء ادخال الطول ');
  });
}
