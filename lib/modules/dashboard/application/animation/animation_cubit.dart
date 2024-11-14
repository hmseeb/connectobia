import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'animation_state.dart';

class AnimationCubit extends Cubit<AnimationState> {
  AnimationCubit() : super(AnimationInitial());
  void animationStopped() {
    emit(AnimationStopped());
  }
}
