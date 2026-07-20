import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tag_state.dart';

class TagCubit extends Cubit<TagState> {
  TagCubit() : super(TagInitial());
}
