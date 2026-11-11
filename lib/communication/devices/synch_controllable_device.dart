import 'dart:async';

abstract interface class SynchControllableDevice {
  Future<void> sendGuaranteedSynchRequest(bool enable);
}