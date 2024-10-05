import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'signup_bloc_event.dart';
part 'signup_bloc_state.dart';

class SignupBloc extends Bloc<SignupBlocEvent, SignupBlocState> {
  SignupBloc() : super(SignupBlocInitial()) {
    on<SignupBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
