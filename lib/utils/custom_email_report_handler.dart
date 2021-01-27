import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomEmailReportHandler extends ReportHandler {
  CustomEmailReportHandler();

  @override
  List<PlatformType> getSupportedPlatforms() => [
        PlatformType.Android,
        PlatformType.Unknown,
        PlatformType.Web,
        PlatformType.iOS,
      ];

  @override
  Future<bool> handle(Report error) async {
    return _sendMail(_getBody(error), "Error <${error.error}>");
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
    if (await canLaunch(url)) {
      await launch(url);
      return true;
    }

    return false;
  }
}
