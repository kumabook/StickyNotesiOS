document.addEventListener('touchstart', function(e) {
  var isCanceled = false;
  setTimeout(function() {
    if (!isCanceled) {
      var stickynotes = window.webkit.messageHandlers.stickynotes;
      if (stickynotes.postMessage) {
        stickynotes.postMessage(JSON.stringify({type: "create-sticky"}));
      }
    }
  }, 1000);
  function cancel() {
    isCanceled = true;
    document.removeEventListener(cancel);
  }
  document.addEventListener('touchend',    cancel);
  document.addEventListener('touchcancel', cancel);
});

function addSticky(sticky) {
  var dom = document.createElement('div');
  dom.id = '__stickynotes_' + sticky.id;
  dom.style.position = 'absolute';
  dom.style.top    = sticky.top + 'px';
  dom.style.left   = sticky.left + 'px';
  dom.style.width  = sticky.width + 'px';
  dom.style.height = sticky.height + 'px';
  dom.textContent  = sticky.content;
  dom.style.backgroundColor = sticky.color;
  dom.addEventListener('click', function() {
    var stickynotes = window.webkit.messageHandlers.stickynotes;
    if (stickynotes.postMessage) {
      stickynotes.postMessage(JSON.stringify({
        type: 'select-sticky',
        id: sticky.id
      }));
    }
  });
  document.body.appendChild(dom);
  return true;
}

function jumpToSticky(sticky) {
  var dom = document.getElementById('__stickynotes_' + sticky.id);
  if (!dom) {
    return false;
  }
  dom.scrollIntoView({block: 'end', behavior: 'smooth'});
  return true;
}
