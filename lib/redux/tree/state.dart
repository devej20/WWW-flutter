import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:what_when_where/db_chgk_info/models/tournaments_tree.dart';

@immutable
class TournamentsSubTreeState {
  final bool isLoading;
  final Exception exception;
  final TournamentsTree tree;

  bool get hasError => exception != null;

  bool get hasData => tree?.children?.isNotEmpty ?? false;

  const TournamentsSubTreeState._({
    this.isLoading = false,
    this.exception,
    this.tree,
  });

  const TournamentsSubTreeState.initial({
    @required TournamentsTree tree,
  }) : this._(tree: tree);

  TournamentsSubTreeState copyWith({
    Optional<bool> isLoading,
    Optional<Exception> exception,
    Optional<TournamentsTree> tree,
  }) =>
      TournamentsSubTreeState._(
        isLoading: isLoading != null ? isLoading.orNull : this.isLoading,
        exception: exception != null ? exception.orNull : this.exception,
        tree: tree != null ? tree.orNull : this.tree,
      );

  @override
  int get hashCode => hash3(tree, isLoading, exception.runtimeType);

  @override
  bool operator ==(dynamic other) =>
      other is TournamentsSubTreeState &&
      other.tree == tree &&
      other.isLoading == isLoading &&
      other.exception?.runtimeType == exception?.runtimeType;
}

@immutable
class TournamentsTreeState {
  static const String rootId = '0';

  final Map<String, TournamentsSubTreeState> _states;

  TournamentsSubTreeState operator [](String id) => _states[id];

  TournamentsTreeState._({Map<String, TournamentsSubTreeState> states})
      : _states = states ?? <String, TournamentsSubTreeState>{};

  TournamentsTreeState.initial()
      : this._(
          states: <String, TournamentsSubTreeState>{
            rootId: const TournamentsSubTreeState.initial(
              tree: TournamentsTree(id: rootId),
            ),
          },
        );

  TournamentsTreeState copyWithSubTree({
    @required String id,
    Optional<bool> isLoading,
    Optional<Exception> exception,
    Optional<TournamentsTree> tree,
  }) {
    final newStates = Map<String, TournamentsSubTreeState>.from(_states);
    newStates[id] = this[id].copyWith(
      isLoading: isLoading,
      exception: exception,
      tree: tree,
    );
    if (tree?.isPresent ?? false) {
      newStates.addEntries(
          tree.value.children.whereType<TournamentsTree>().map((x) => MapEntry(
                x.id,
                TournamentsSubTreeState.initial(tree: x),
              )));
    }

    return TournamentsTreeState._(states: newStates);
  }
}
