import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture_samples/flutter_architecture_samples.dart';
import 'package:redux_sample/containers/app_loading.dart';
import 'package:redux_sample/containers/todo_details.dart';
import 'package:redux_sample/models.dart';
import 'package:redux_sample/widgets/details_screen.dart';
import 'package:redux_sample/widgets/todo_item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo, bool) onCheckboxChanged;
  final Function(Todo) onRemove;
  final Function(Todo) onUndoRemove;

  TodoList({
    @required this.todos,
    @required this.onCheckboxChanged,
    @required this.onRemove,
    @required this.onUndoRemove,
  });

  @override
  Widget build(BuildContext context) {
    return new AppLoading(builder: (context, loading) {
      return loading
          ? new Center(
              child: new CircularProgressIndicator(
              key: ArchSampleKeys.loading,
            ))
          : new Container(
              child: new ListView.builder(
                key: ArchSampleKeys.todoList,
                itemCount: todos.length,
                itemBuilder: (BuildContext context, int index) {
                  final todo = todos[index];

                  return new TodoItem(
                    todo: todo,
                    onDismissed: (direction) {
                      _removeTodo(context, todo);
                    },
                    onTap: () => _onTodoTap(context, todo),
                    onCheckboxChanged: (complete) {
                      onCheckboxChanged(todo, complete);
                    },
                  );
                },
              ),
            );
    });
  }

  void _removeTodo(BuildContext context, Todo todo) {
    onRemove(todo);

    Scaffold.of(context).showSnackBar(new SnackBar(
        duration: new Duration(seconds: 2),
        backgroundColor: Theme.of(context).backgroundColor,
        content: new Text(
          ArchSampleLocalizations.of(context).todoDeleted(todo.task),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: new SnackBarAction(
          label: ArchSampleLocalizations.of(context).undo,
          onPressed: () => onUndoRemove(todo),
        )));
  }

  void _onTodoTap(BuildContext context, Todo todo) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (_) {
          return new TodoDetails(
            id: todo.id,
            builder: (
              BuildContext context,
              TodoDetailsViewModel vm,
            ) {
              return new DetailsScreen(
                todo: vm.todo,
                onDelete: vm.onDelete,
                toggleCompleted: vm.toggleCompleted,
              );
            },
          );
        },
      ),
    ).then((removedTodo) {
      if (removedTodo != null) {
        Scaffold.of(context).showSnackBar(
              new SnackBar(
                duration: new Duration(seconds: 2),
                backgroundColor: Theme.of(context).backgroundColor,
                content: new Text(
                  ArchSampleLocalizations.of(context).todoDeleted(todo.task),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                action: new SnackBarAction(
                  label: ArchSampleLocalizations.of(context).undo,
                  onPressed: () {
                    onUndoRemove(todo);
                  },
                ),
              ),
            );
      }
    });
  }
}