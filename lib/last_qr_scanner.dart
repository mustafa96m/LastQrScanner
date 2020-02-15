import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:last_qr_scanner/barcode_types.dart';

typedef void QRViewCreatedCallback(QRViewController controller);

class LastQrScannerPreview extends StatefulWidget {
  final List<BarcodeFormat> lookupFormats;
  const LastQrScannerPreview({
    Key key,
    this.lookupFormats,
    this.onQRViewCreated,
  }) : super(key: key);

  final QRViewCreatedCallback onQRViewCreated;

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<LastQrScannerPreview> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var androidView = AndroidView(
        viewType: 'last_qr_scanner/qrview',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
      return androidView;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'last_qr_scanner/qrview',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _CreationParams.fromWidget(0, 0).toMap(),
        creationParamsCodec: StandardMessageCodec(),
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onQRViewCreated == null) {
      return;
    }
    widget.onQRViewCreated(new QRViewController._(id, widget.lookupFormats));
  }
}

class _CreationParams {
  _CreationParams({this.width, this.height});

  static _CreationParams fromWidget(double width, double height) {
    return _CreationParams(
      width: width,
      height: height,
    );
  }

  final double width;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

class QRViewController {
  final List<BarcodeFormat> lookupFormats;
  final MethodChannel channel;

  QRViewController._(int id, this.lookupFormats)
      : channel = MethodChannel('last_qr_scanner/qrview_$id');

  void init(GlobalKey qrKey) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      channel.invokeMethod("setDimensions",
          {"width": renderBox.size.width, "height": renderBox.size.height});
    }
    _setLookupFormats();
  }

  void toggleTorch() {
    channel.invokeMethod("toggleTorch");
  }

  void pauseScanner() {
    channel.invokeMethod("pauseScanner");
  }

  void resumeScanner() {
    channel.invokeMethod("resumeScanner");
  }

  void _setLookupFormats() {
    channel.invokeListMethod("setLookupFormats",
        lookupFormats.map((obj) => obj.toString().split(".").last).toList());
  }
}
