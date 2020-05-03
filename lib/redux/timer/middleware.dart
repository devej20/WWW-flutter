import 'package:injectable/injectable.dart';
import 'package:redux/redux.dart';
import 'package:what_when_where/common/timer_type.dart';
import 'package:what_when_where/redux/app/state.dart';
import 'package:what_when_where/redux/timer/actions.dart';
import 'package:what_when_where/services/sound.dart';
import 'package:what_when_where/services/vibrating.dart';
import 'package:what_when_where/utils/timer.dart';

const int _timerFrequency = 200;

@injectable
class TimerMiddleware {
  final ISoundService _soundService;
  final IVibratingService _vibratingService;

  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware => _middleware;

  TimerMiddleware({
    ISoundService soundService,
    IVibratingService vibratingService,
  })  : _soundService = soundService,
        _vibratingService = vibratingService {
    _middleware = _createMiddleware();
  }

  List<Middleware<AppState>> _createMiddleware() => [
        ..._TimerConnectingMiddleware().middleware,
        ..._TimerTickingMiddleware().middleware,
        ..._TimerSoundMiddleware(soundService: _soundService).middleware,
        ..._TimerVibratingMiddleware(vibratingService: _vibratingService)
            .middleware
      ];
}

class _TimerTickingMiddleware {
  final _timer = WWWTimer(updateFrequency: _timerFrequency);

  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware => _middleware;

  _TimerTickingMiddleware() {
    _middleware = _createMiddleware();
  }

  List<Middleware<AppState>> _createMiddleware() => [
        TypedMiddleware<AppState, StartTimerUserAction>(_startTimer),
        TypedMiddleware<AppState, StopTimerUserAction>(_stopTimer),
        TypedMiddleware<AppState, ResetTimerUserAction>(_resetTimer),
        TypedMiddleware<AppState, UpdateTimeTimerSystemAction>(
            _stopTimerAtZero),
        TypedMiddleware<AppState, ChangeTypeTimerUserAction>(_changeType),
      ];

  void _startTimer(
      Store<AppState> store, StartTimerUserAction action, NextDispatcher next) {
    next(action);

    final timerState = store.state.timerState;
    final initialTime = Duration(
        seconds: (timerState.secondsLeft <= 0)
            ? Timers.getSeconds(timerState.timerType)
            : timerState.secondsLeft);

    _timer.reset();
    _timer.start(callback: (duration) {
      final remainingTime = initialTime - duration;

      final secondsRemaining = remainingTime.inMilliseconds >
              remainingTime.inSeconds * Duration.millisecondsPerSecond
          ? remainingTime.inSeconds + 1
          : remainingTime.inSeconds;

      _updateTime(store, secondsRemaining);
    });

    store.dispatch(SystemActionTimer.isRunning(newValue: _timer.isRunning));
  }

  void _stopTimer(
      Store<AppState> store, StopTimerUserAction action, NextDispatcher next) {
    next(action);

    _onTimerStop(store);
  }

  void _onTimerStop(Store<AppState> store) {
    _timer.pause();
    store.dispatch(SystemActionTimer.isRunning(newValue: _timer.isRunning));
  }

  void _resetTimer(
      Store<AppState> store, ResetTimerUserAction action, NextDispatcher next) {
    next(action);

    _timer.reset();
  }

  void _updateTime(Store<AppState> store, int seconds) {
    if (store.state.timerState.secondsLeft != seconds) {
      store.dispatch(SystemActionTimer.updateTime(newValue: seconds));
    }
  }

  void _stopTimerAtZero(Store<AppState> store,
      UpdateTimeTimerSystemAction action, NextDispatcher next) {
    next(action);

    if (action.newValue == 0) {
      _onTimerStop(store);
    }
  }

  void _changeType(Store<AppState> store, ChangeTypeTimerUserAction action,
      NextDispatcher next) {
    next(action);

    store.dispatch(const UserActionTimer.reset());
  }
}

class _TimerConnectingMiddleware {
  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware => _middleware;

  _TimerConnectingMiddleware() {
    _middleware = _createMiddleware();
  }

  List<Middleware<AppState>> _createMiddleware() => [
        TypedMiddleware<AppState, UpdateTimeTimerSystemAction>(
            _notifyTimerExpiration),
      ];

  void _notifyTimerExpiration(Store<AppState> store,
      UpdateTimeTimerSystemAction action, NextDispatcher next) {
    next(action);

    final isTimerLong = store.state.timerState.timerType == TimerType.normal;
    final settings = store.state.settingsState;
    final timerExpired = action.newValue == 0;
    final timerIsExpiring = action.newValue == 10;
    final shouldNotify = timerExpired ||
        (timerIsExpiring &&
            ((isTimerLong && settings.notifyLongTimerExpiration) ||
                (!isTimerLong && settings.notifyShortTimerExpiration)));

    if (shouldNotify) {
      store.dispatch(const SystemActionTimer.notify());
    }
  }
}

class _TimerVibratingMiddleware {
  final IVibratingService _vibratingService;

  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware => _middleware;

  _TimerVibratingMiddleware({
    IVibratingService vibratingService,
  }) : _vibratingService = vibratingService {
    _middleware = _createMiddleware();
  }

  List<Middleware<AppState>> _createMiddleware() => [
        TypedMiddleware<AppState, NotifyTimerSystemAction>(_vibrate),
      ];

  void _vibrate(Store<AppState> store, NotifyTimerSystemAction action,
      NextDispatcher next) {
    next(action);

    _vibratingService.vibrate();
  }
}

class _TimerSoundMiddleware {
  final ISoundService _soundService;

  List<Middleware<AppState>> _middleware;
  Iterable<Middleware<AppState>> get middleware => _middleware;

  _TimerSoundMiddleware({
    ISoundService soundService,
  }) : _soundService = soundService {
    _middleware = _createMiddleware();
  }

  List<Middleware<AppState>> _createMiddleware() => [
        TypedMiddleware<AppState, NotifyTimerSystemAction>(_sound),
      ];

  void _sound(Store<AppState> store, NotifyTimerSystemAction action,
      NextDispatcher next) {
    next(action);

    _soundService.playSound();
  }
}
