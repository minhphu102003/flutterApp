import 'dart:async';
import 'package:flutter/widgets.dart';

// Widget FadeIn tạo hiệu ứng fade-in và fade-out cho một widget con (child).
// Cho phép điều khiển việc hiển thị bằng controller (FadeInController).
class FadeIn extends StatefulWidget {
  // Controller để điều khiển hiệu ứng fade-in/fade-out.
  final FadeInController? controller;

  // Widget con mà hiệu ứng sẽ được áp dụng.
  final Widget? child;

  // Thời gian của hiệu ứng fade-in. Mặc định là 250 ms.
  final Duration duration;

  // Đường cong (curve) cho hiệu ứng fade-in. Mặc định là [Curves.easeIn].
  final Curve curve;

  // Constructor nhận các tham số và truyền chúng vào State.
  const FadeIn({
    super.key,
    this.controller,
    this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeIn,
  });

  @override
  _FadeInState createState() => _FadeInState();
}

// Enum để định nghĩa các hành động cho hiệu ứng fade-in.
enum FadeInAction {
  fadeIn,
  fadeOut,
}

// Controller điều khiển hiệu ứng fade-in/fade-out qua Stream.
class FadeInController {
  // Stream controller để truyền các hành động fade-in/fade-out.
  final _streamController = StreamController<FadeInAction>();

  // Tự động bắt đầu hiệu ứng fade-in khi khởi tạo widget. Mặc định là false.
  final bool autoStart;

  // Constructor nhận vào giá trị autoStart.
  FadeInController({
    this.autoStart = false,
  });

  // Đóng Stream controller khi không sử dụng.
  void dispose() => _streamController.close();

  // Gọi hành động fade-in.
  void fadeIn() => run(FadeInAction.fadeIn);

  // Gọi hành động fade-out.
  void fadeOut() => run(FadeInAction.fadeOut);

  // Thêm hành động vào Stream.
  void run(FadeInAction action) => _streamController.add(action);

  // Trả về stream để lắng nghe các hành động.
  Stream<FadeInAction> get stream => _streamController.stream;
}

// State cho widget FadeIn để quản lý trạng thái hiệu ứng.
class _FadeInState extends State<FadeIn> with TickerProviderStateMixin {
  // AnimationController điều khiển hiệu ứng fade-in/fade-out.
  late AnimationController _controller;
  // Lắng nghe các sự kiện từ controller.
  StreamSubscription<FadeInAction>? _listener;

  @override
  void initState() {
    super.initState();

    // Khởi tạo AnimationController với thời gian và vsync từ widget.
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Cấu hình đường cong cho hiệu ứng fade-in.
    _setupCurve();

    // Tự động fade-in nếu autoStart là true.
    if (widget.controller?.autoStart != false) {
      fadeIn();
    }
    // Bắt đầu lắng nghe các hành động từ controller.
    _listen();
  }

  // Thiết lập đường cong cho hiệu ứng.
  void _setupCurve() {
    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Tạo Tween để thay đổi giá trị từ 0.0 đến 1.0 cho hiệu ứng fade-in.
    Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);
  }

  // Lắng nghe các hành động từ controller.
  void _listen() {
    // Huỷ bỏ listener cũ nếu có.
    if (_listener != null) {
      _listener!.cancel();
      _listener = null;
    }

    // Nếu widget có controller, lắng nghe stream của controller.
    if (widget.controller != null) {
      _listener = widget.controller!.stream.listen(_onAction);
    }
  }

  // Thực hiện hành động dựa trên giá trị nhận được từ stream.
  void _onAction(FadeInAction action) {
    switch (action) {
      case FadeInAction.fadeIn:
        fadeIn();
        break;
      case FadeInAction.fadeOut:
        fadeOut();
        break;
    }
  }

  @override
  void didUpdateWidget(FadeIn oldWidget) {
    // Cập nhật listener nếu controller thay đổi.
    if (oldWidget.controller != widget.controller) {
      _listen();
    }

    // Cập nhật thời gian hiệu ứng nếu duration thay đổi.
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    // Cập nhật đường cong hiệu ứng nếu curve thay đổi.
    if (oldWidget.curve != widget.curve) {
      _setupCurve();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Huỷ bỏ AnimationController và listener khi không sử dụng nữa.
    _controller.dispose();
    _listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng FadeTransition để áp dụng hiệu ứng fade-in cho widget con.
    return FadeTransition(
      opacity: _controller,
      child: widget.child,
    );
  }

  // Bắt đầu hiệu ứng fade-in.
  void fadeIn() => _controller.forward();

  // Bắt đầu hiệu ứng fade-out.
  void fadeOut() => _controller.reverse();
}
