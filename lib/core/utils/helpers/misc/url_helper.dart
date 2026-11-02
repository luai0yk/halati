import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  UrlHelper._();

  /// Launches a phone call using the provided phone number.
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        log('Could not launch phone call to $phoneNumber');
      }
    } catch (e) {
      log('Error launching phone call: $e');
    }
  }

  /// Opens WhatsApp with the given phone number and optional pre-filled message.
  static Future<bool> openWhatsApp(
    String phoneNumber, {
    String? message,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = message != null ? Uri.encodeComponent(message) : '';

    // Primary: native WhatsApp scheme
    final nativeUri = Uri.parse(
      'whatsapp://send?phone=$cleanPhone${encodedMessage.isNotEmpty ? '&text=$encodedMessage' : ''}',
    );
    try {
      final launched = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (_) {}

    // Fallback: https://wa.me link
    final webUri = Uri.parse(
      'https://wa.me/$cleanPhone${encodedMessage.isNotEmpty ? '?text=$encodedMessage' : ''}',
    );
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Opens an external URL in the default browser or application.
  /// Returns `true` if launched successfully, `false` otherwise.
  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
      return await launchUrl(uri);
    } catch (e) {
      log('Error launching URL $url: $e');
      return false;
    }
  }

  /// Opens the default email client addressed to [email] with optional [subject] and [body].
  /// Returns `true` if launched successfully, `false` otherwise.
  static Future<bool> sendEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    final Map<String, String> queryParameters = {};
    if (subject != null && subject.isNotEmpty) {
      queryParameters['subject'] = subject;
    }
    if (body != null && body.isNotEmpty) {
      queryParameters['body'] = body;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: queryParameters.isNotEmpty
          ? queryParameters.entries
                .map(
                  (e) =>
                      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                )
                .join('&')
          : null,
    );

    try {
      return await launchUrl(emailUri);
    } catch (e) {
      log('Error launching email to $email: $e');
      return false;
    }
  }
}
