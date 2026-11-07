import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:status_saver/core/constants/app_durations.dart';

class AppShellController extends GetxController {
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;
  int? _targetPageIndex;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
  }

  Future<void> changeTab(int index) async {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    _targetPageIndex = index;

    if (pageController.hasClients) {
      try {
        await pageController.animateToPage(
          index,
          duration: AppDurations.medium,
          curve: Curves.easeInOut,
        );
      } finally {
        if (_targetPageIndex == index) {
          _targetPageIndex = null;
        }
      }
    }
  }

  void onPageChanged(int index) {
    if (_targetPageIndex != null) {
      if (index == _targetPageIndex) {
        _targetPageIndex = null;
      }
      return;
    }
    currentIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
