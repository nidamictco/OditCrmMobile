
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhoneCall(BuildContext context, String phoneNumber) async {
  try {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open application')),
      );
    }
  }
}

Future<void> launchWhatsApp(BuildContext context, String phoneNumber) async {
  try {
    var cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+|-|\+'), '');
    if (!cleanNumber.startsWith('91') && cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');
    await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalNonBrowserApplication,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open application')),
      );
    }
  }
}



Future<void> launchWeb(BuildContext context, String url) async {
  try {
    String website = url.trim();

    // Add https:// if the scheme is missing
    if (!website.startsWith('http://') &&
        !website.startsWith('https://')) {
      website = 'https://$website';
    }

    final Uri webUri = Uri.parse(website);

    await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open website'),
        ),
      );
    }
  }
}
