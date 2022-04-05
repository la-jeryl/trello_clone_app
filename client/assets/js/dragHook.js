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
            draggedId: evt.item.id, // id of the dragged item
            dropzoneId: evt.to.id, // id of the drop zone where the drop occured
            draggableIndex: evt.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
          });
        },
      });
    });
  },
};