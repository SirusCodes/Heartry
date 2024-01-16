import 'package:catcher_2/catcher_2.dart';
import 'package:catcher_2/model/platform_type.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomEmailReportHandler extends ReportHandler {
  CustomEmailReportHandler();

  @override
  List<PlatformType> getSupportedPlatforms() => [
        PlatformType.android,
        PlatformType.unknown,
        PlatformType.web,
        PlatformType.iOS,
      ];

  @override
  Future<bool> handle(Report report, BuildContext? context) async {
    return _sendMail(_getBody(report), "Error <${report.error}>");
  }

  String _getBody(Report report) {
    final StringBuffer buffer = StringBuffer();
    final List<String> requiredDeviceParams = [
      "id",
      "board",
      "brand",
      "device",
      "model",
      "product",
      "versionSdk",
    ];

    buffer.write("Heartry App crash report\n\n");

    buffer.write("Error: ");
    buffer.write(report.error.toString());
    buffer.write("\n\n");

    buffer.write("Stack trace:\n");
    buffer.write(report.stackTrace.toString());
    buffer.write("\n\n");

    buffer.write("Device parameters:\n");
    for (final entry in report.deviceParameters.entries)
      if (requiredDeviceParams.contains(entry.key))
        buffer.write("${entry.key}: ${entry.value}\n");
    buffer.write("\n\n");

    buffer.write("Application parameters:\n");
    for (final entry in report.applicationParameters.entries)
      buffer.write("${entry.key}: ${entry.value}");
    buffer.write("\n\n");

    return buffer.toString();
  }

  Future<bool> _sendMail(String body, String subject) async {
    final url = "mailto:heartryapp@gmail.com?body=$body&subject=$subject";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      return true;
    }

    return false;
  }
}
