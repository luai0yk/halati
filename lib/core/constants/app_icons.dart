import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppIcons {
  AppIcons._();

  // Navigation
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

  // Actions
  static const edit = Iconsax.edit_copy;
  static const delete = Iconsax.trash_copy;
  static const share = Iconsax.share_copy;
  static const more = Iconsax.more_copy;
  static const close = Icons.close_rounded;
  static const clear = Iconsax.broom_copy;
  static const undo = Iconsax.undo_copy;
  static const download = Iconsax.import_copy;
  static const downloadFilled = Iconsax.import_3;
  static const play = Iconsax.play_copy;
  static const pause = Iconsax.pause_copy;
  static const status = Iconsax.status_copy;
  static const statusFilled = Iconsax.status;

  // Search & Filter
  static const search = Iconsax.search_normal_1_copy;
  static const searchOff = Iconsax.search_status_copy;
  static const filter = Iconsax.filter_copy;

  // Communication
  static const message = Iconsax.messages_1_copy;
  static const whatsapp = Iconsax.whatsapp_copy;

  // Rating & Feedback
  static const favorite = Iconsax.heart_copy;
  static const favoriteFilled = Iconsax.heart;

  // Media & Files
  static const addPhoto = Iconsax.gallery_add_copy;
  static const camera = Iconsax.camera_copy;
  static const gallery = Iconsax.gallery_copy;
  static const image = Iconsax.image_copy;
  static const video = Iconsax.video_play_copy;
  static const imageNotSupported = Iconsax.gallery_slash_copy;
  static const file = Iconsax.document_text_copy;
  static const folder = Iconsax.folder_copy;

  // Status & Feedback
  static const check = Icons.check_rounded;
  static const checkSquare = Iconsax.tick_square_copy;
  static const checkCircle = Iconsax.tick_circle_copy;
  static const error = Iconsax.danger_copy;
  static const warning = Iconsax.warning_2_copy;
  static const info = Iconsax.info_circle_copy;
  static const waveform = Iconsax.voice_square_copy;

  // Settings
  static const settings = Iconsax.setting_2_copy;
  static const settingsFilled = Iconsax.setting_2;
  static const brightness = Iconsax.sun_1_copy;
  static const translate = Iconsax.translate_copy;
  static const eye = Iconsax.eye_copy;
  static const eyeSlash = Iconsax.eye_slash_copy;

  // Misc
  static const box = Iconsax.box_copy;
  static const receipt = Iconsax.receipt_2_1_copy;
  static const code = Iconsax.code_circle_copy;
}
