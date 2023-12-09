part of 'widgets.dart';

class UiLoading {
  static Container loadingBlock(){
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      color: Colors.black12, // blacknya kadarnya cuma 12, jadi transparancynya 88
      child: const SpinKitFadingCircle(
        size: 50,
        color: Colors.purple,
      ),
    );
  }
}
