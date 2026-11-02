import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppIcons {
  AppIcons._();

  // Navigation
  static const home = Iconsax.home_2_copy;
  static const homeFilled = Iconsax.home_2;
  static const user = Iconsax.user_copy;
  static const userFilled = Iconsax.user;
  static const users = Iconsax.people_copy;
  static const usersFilled = Iconsax.people;
  static const report = Iconsax.document_text_1_copy;
  static const reportFilled = Iconsax.document_text;
  static const box = Iconsax.box_copy;
  static const category = Iconsax.element_3_copy;

  static IconData arrowBack(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Iconsax.arrow_right_3_copy
        : Iconsax.arrow_left_2_copy;
  }

  static IconData arrowForward(BuildContext context) {
    return Directionality.of(context) == TextDirection.rtl
        ? Iconsax.arrow_left_2_copy
        : Iconsax.arrow_right_3_copy;
  }

  static const arrowDown = Iconsax.arrow_down_1_copy;
  static const arrowUp = Iconsax.arrow_up_2_copy;
  static const arrowTUp = Iconsax.arrow_up_3_copy;
  static const arrowTDown = Iconsax.arrow_down_copy;
  static const arrowSwap = Iconsax.arrow_swap_copy;

  // Actions
  static const IconData logout = Iconsax.logout_1_copy;
  static const IconData login = Iconsax.login_1_copy;
  static const add = Iconsax.add_copy;
  static const categoryAdd = Iconsax.element_plus_copy;
  static const storeAdd = Iconsax.shop_add_copy;
  static const userAdd = Iconsax.user_add_copy;
  static const minus = Iconsax.minus_copy;
  static const remove = Iconsax.minus_square_copy;
  static const edit = Iconsax.edit_copy;
  static const delete = Iconsax.trash_copy;
  static const favRemove = Iconsax.heart_remove_copy;
  static const copy = Iconsax.copy_copy;
  static const refresh = Iconsax.refresh_copy;
  static const share = Iconsax.share_copy;
  static const more = Iconsax.more_copy;
  static const close = Icons.close_rounded;
  static const clear = Iconsax.broom_copy;
  static const undo = Iconsax.undo_copy;
  static const userEdit = Iconsax.user_edit_copy;
  static const archive = Iconsax.archive_2_copy;
  static const backspace = Icons.backspace_outlined;

  // Search & Filter
  static const search = Iconsax.search_normal_1_copy;
  static const searchFilled = Iconsax.search_normal_1;
  static const searchOff = Iconsax.search_status_copy;
  static const filter = Iconsax.filter_copy;

  // Communication
  static const message = Iconsax.messages_1_copy;
  static const phone = Iconsax.call_copy;
  static const call = Iconsax.call_copy;

  // Finance
  static const money = Iconsax.money_2_copy;
  static const moneyAdd = Iconsax.money_add_copy;

  // Date & Time
  static const calendar = Iconsax.calendar_copy;
  static const time = Iconsax.clock_copy;
  static const notes = Iconsax.note_2_copy;
  static const text = Iconsax.note_text_copy;

  // Rating & Feedback
  static const favorite = Iconsax.heart_copy;
  static const favoriteFilled = Iconsax.heart;
  static const star = Iconsax.star_copy;
  static const rateReview = Iconsax.messages_2_copy;

  // Media & Files
  static const addPhoto = Iconsax.gallery_add_copy;
  static const camera = Iconsax.camera_copy;
  static const gallery = Iconsax.gallery_copy;
  static const imageNotSupported = Iconsax.gallery_slash_copy;
  static const file = Iconsax.document_text_copy;
  static const folder = Iconsax.folder_copy;
  static const exportBackup = Iconsax.export_copy;
  static const importBackup = Iconsax.import_copy;
  static const cloudExport = Icons.cloud_upload_outlined;
  static const cloudImport = Icons.cloud_download_outlined;

  // Status
  static const check = Icons.check_rounded;
  static const checkSquare = Iconsax.tick_square_copy;
  static const checkCircle = Iconsax.tick_circle_copy;
  static const doneAll = Iconsax.task_copy;
  static const error = Iconsax.danger_copy;
  static const warning = Iconsax.warning_2_copy;
  static const info = Iconsax.info_circle_copy;
  static const help = Iconsax.message_question_copy;
  static const connectionError = Iconsax.cloud_cross_copy;

  // Settings
  static const settings = Iconsax.setting_2_copy;
  static const settingsFilled = Iconsax.setting_2;
  static const lock = Iconsax.lock_copy;
  static const unlock = Iconsax.unlock_copy;
  static const fingerprint = Iconsax.finger_cricle_copy;
  static const brightness = Icons.brightness_4_outlined;
  static const translate = Iconsax.translate_copy;
  static const eye = Iconsax.eye_copy;
  static const eyeSlash = Iconsax.eye_slash_copy;
  static const prefs = Iconsax.setting_4_copy;

  // Misc
  static const notifications = Iconsax.notification_copy;
  static const chart = Iconsax.chart_square_copy;
  static const chartFilled = Iconsax.chart_square;
  static const oneTwoThree = Icons.onetwothree_rounded;
  static const store = Iconsax.shop_copy;
  static const color = Iconsax.brush_2_copy;
  static const globe = Iconsax.global_copy;
  static const subscription = Iconsax.crown_1_copy;
  static const card = Iconsax.card_copy;
  static const receipt = Iconsax.receipt_2_1_copy;
  static const googlePlay = Iconsax.google_play;
}
