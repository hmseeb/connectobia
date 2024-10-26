import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<UserInitialEvent>((event, emit) async {});
  }
}
