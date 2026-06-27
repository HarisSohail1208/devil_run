class GameInput {
  bool left = false;
  bool right = false;
  bool jumpQueued = false;

  void queueJump() {
    jumpQueued = true;
  }

  void consumeJump() {
    jumpQueued = false;
  }

  void reset() {
    left = false;
    right = false;
    jumpQueued = false;
  }
}
