part of 'view_screen_cubit.dart';

@immutable
sealed class ViewScreenState {}

final class ViewScreenInitial extends ViewScreenState {}

class ViewScreenConnecting extends ViewScreenState {}

class ViewScreenConnected extends ViewScreenState {}

class ViewScreenError extends ViewScreenState {
  final String message;
  ViewScreenError(this.message);
}
