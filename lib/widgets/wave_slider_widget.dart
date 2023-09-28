import 'package:custom_wave_slider/widgets/wave_slide_painter.dart';
import 'package:flutter/material.dart';


class WaveSlider extends StatefulWidget {
  final double sliderWidth;
  final double sliderHeight;
  final Color color;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  WaveSlider({
    this.sliderWidth = 350.0,
    this.sliderHeight = 50.0,
    this.color = Colors.black,
    this.onChangeEnd,
    this.onChangeStart,
    required this.onChanged,
  }) : assert(sliderHeight >= 50 && sliderHeight <= 600);

  @override
  _WaveSliderState createState() => _WaveSliderState();
}

class _WaveSliderState extends State<WaveSlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  double _dragPercentage = 0.0;

  late WaveSliderController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = WaveSliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _slideController.dispose();
  }

  _handleChanged(double val) {
    widget.onChanged(val);
  }

  _handleChangeStart(double val) {
   // assert(widget.onChangeStart != null);
    widget.onChangeStart!(val);
  }

  _handleChangeEnd(double val) {
   // assert(widget.onChangeEnd != null);
    widget.onChangeEnd!(val);
  }

  void _updateDragPosition(Offset val) {
    double newDragPosition = 0.0;
    if (val.dx <= 0.0) {
      newDragPosition = 0.0;
    } else if (val.dx >= widget.sliderWidth) {
      newDragPosition = widget.sliderWidth;
    } else {
      newDragPosition = val.dx;
    }

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = _dragPosition / widget.sliderWidth;
    });
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {

    Offset localOffset =start.localPosition;
    _slideController.setStateToStart();
    _updateDragPosition(localOffset);
    _handleChangeStart(_dragPercentage);
  }

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {

    Offset localOffset =update.localPosition;
    _slideController.setStateToSliding();
    _updateDragPosition(localOffset);
    _handleChanged(_dragPercentage);
    print(_dragPercentage);
  }

  void _onDragEnd(BuildContext context, DragEndDetails end) {
    _slideController.setStateToStopping();
    setState(() {});
    _handleChangeEnd(_dragPercentage);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.sliderWidth,
        height: widget.sliderHeight,
        child: CustomPaint(
          painter: WavePainter(
            color: widget.color,
            sliderPosition: _dragPosition,
            dragPercentage: _dragPercentage,
            sliderState: _slideController.state,
            animationProgress: _slideController.progress,
          ),
        ),
      ),
      onHorizontalDragStart: (DragStartDetails start) =>
          _onDragStart(context, start),
      onHorizontalDragUpdate: (DragUpdateDetails update) =>
          _onDragUpdate(context, update),
      onHorizontalDragEnd: (DragEndDetails end) => _onDragEnd(context, end),
    );
  }
}

class WaveSliderController extends ChangeNotifier {
  final AnimationController controller;
  SliderState _state = SliderState.resting;

  WaveSliderController({required TickerProvider vsync})
      : controller = AnimationController(vsync: vsync) {
    controller
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _onTransitionCompleted();
    }
  }

  void _onTransitionCompleted() {
    if (_state == SliderState.stopping) {
      setStateToResting();
    }
  }

  double get progress => controller.value;

  SliderState get state => _state;

  void _startAnimation() {
    controller.duration = Duration(milliseconds: 500);
    controller.forward(from: 0.0);
    notifyListeners();
  }

  void setStateToStart() {
    _startAnimation();
    _state = SliderState.starting;
  }

  void setStateToStopping() {
    _startAnimation();
    _state = SliderState.stopping;
  }

  void setStateToSliding() {
    _state = SliderState.sliding;
  }

  void setStateToResting() {
    _state = SliderState.resting;
  }
}

enum SliderState {
  starting,
  resting,
  sliding,
  stopping,
}