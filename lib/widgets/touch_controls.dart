import 'package:flutter/material.dart';

class TouchControls extends StatelessWidget {
  const TouchControls({
    required this.onLeftChanged,
    required this.onRightChanged,
    required this.onJump,
    super.key,
  });

  final ValueChanged<bool> onLeftChanged;
  final ValueChanged<bool> onRightChanged;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          Positioned(
            left: 22,
            bottom: 20,
            child: Row(
              children: [
                _HoldButton(
                  icon: Icons.keyboard_arrow_left_rounded,
                  onChanged: onLeftChanged,
                ),
                const SizedBox(width: 12),
                _HoldButton(
                  icon: Icons.keyboard_arrow_right_rounded,
                  onChanged: onRightChanged,
                ),
              ],
            ),
          ),
          Positioned(
            right: 28,
            bottom: 20,
            child: _TapButton(icon: Icons.arrow_upward_rounded, onTap: onJump),
          ),
        ],
      ),
    );
  }
}

class _HoldButton extends StatefulWidget {
  const _HoldButton({required this.icon, required this.onChanged});

  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  State<_HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<_HoldButton> {
  final Set<int> _activePointers = <int>{};

  void _press(int pointer) {
    final wasReleased = _activePointers.isEmpty;
    _activePointers.add(pointer);
    if (wasReleased) widget.onChanged(true);
  }

  void _release(int pointer) {
    _activePointers.remove(pointer);
    if (_activePointers.isEmpty) widget.onChanged(false);
  }

  @override
  void dispose() {
    if (_activePointers.isNotEmpty) widget.onChanged(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _press(event.pointer),
      onPointerUp: (event) => _release(event.pointer),
      onPointerCancel: (event) => _release(event.pointer),
      child: _ControlShell(icon: widget.icon),
    );
  }
}

class _TapButton extends StatelessWidget {
  const _TapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: _ControlShell(icon: icon, large: true),
    );
  }
}

class _ControlShell extends StatelessWidget {
  const _ControlShell({required this.icon, this.large = false});

  final IconData icon;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 76.0 : 64.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: large ? 38 : 34, color: Colors.white),
    );
  }
}
