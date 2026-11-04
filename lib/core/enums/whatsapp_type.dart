enum WhatsAppType {
  whatsapp,
  business;

  bool get isBusiness => this == WhatsAppType.business;
  bool get isWhatsapp => this == WhatsAppType.whatsapp;

  String get packageName => isBusiness ? 'com.whatsapp.w4b' : 'com.whatsapp';
  String get folderName => isBusiness ? 'WhatsApp Business' : 'WhatsApp';
}

