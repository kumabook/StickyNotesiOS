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
