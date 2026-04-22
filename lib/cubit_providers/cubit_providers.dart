import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_sharing/features/host_screen/cubit/host_screen_cubit.dart';
import 'package:screen_sharing/features/view_screen/cubit/view_screen_cubit.dart';

get cubitLists {
  return [
    BlocProvider(
      create: (context) => HostScreenCubit(),
    ),
    BlocProvider(
      create: (context) => ViewScreenCubit(),
    ),
  ];
}
