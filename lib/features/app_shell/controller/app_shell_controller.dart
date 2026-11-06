import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_durations.dart';

class AppShellController extends GetxController {
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
  }

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: AppDurations.medium,
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
