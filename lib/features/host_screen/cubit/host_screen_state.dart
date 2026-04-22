part of 'host_screen_cubit.dart';

@immutable
sealed class HostScreenState {}

final class HostScreenInitial extends HostScreenState {}

final class HostScreenConnected extends HostScreenState {}
