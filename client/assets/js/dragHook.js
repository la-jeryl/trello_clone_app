import Sortable from 'sortablejs';

export default {
  mounted() {
    let dragged;
    const hook = this;
    const selector = '#' + this.el.id;

    document.querySelectorAll('.list-dropzone').forEach((dropzone) => {
      new Sortable(dropzone, {
        animation: 0,
        delay: 50,
        delayOnTouchOnly: true,
        group: 'shared-list',
        draggable: '.draggable-list',
        onEnd: function (evt) {
          hook.pushEventTo(selector, 'dropped-list', {
            draggedId: evt.item.id, // id of the dragged item ("10")
            dropzoneId: evt.to.id, // id of the drop zone where the drop occured ("lists")
            draggableIndex: evt.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
          });
        },
      });
    });

    document.querySelectorAll('.task-dropzone').forEach((dropzone) => {
      new Sortable(dropzone, {
        animation: 0,
        delay: 50,
        delayOnTouchOnly: true,
        group: 'shared-task',
        draggable: '.draggable-task',
        onEnd: function (evt) {
          hook.pushEventTo(selector, 'dropped-task', {
            draggedId: evt.item.id, // id of the list id AND id of the dragged item ("14-10")
            dropzoneId: evt.to.id, // id of the drop zone where the drop occured; also includes the list id ("11-tasks")
            draggableIndex: evt.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
          });
        },
      });
    });
  },
};