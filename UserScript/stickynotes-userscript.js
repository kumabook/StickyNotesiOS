const StickyNotes = {};
StickyNotes.Result = {
  Success: 'Success',
  Failure: 'Failure'
};

StickyNotes.postMessage = function(message) {
  var stickynotes = window.webkit.messageHandlers.stickynotes;
  if (stickynotes.postMessage) {
    stickynotes.postMessage(JSON.stringify(message));
  }
};

document.addEventListener('touchstart', function(e) {
  var isCanceled = false;
  setTimeout(function() {
    if (!isCanceled) {
      StickyNotes.postMessage({type: 'create-sticky'});
    }
  }, 1000);
  function cancel() {
    isCanceled = true;
    document.removeEventListener(cancel);
  }
  document.addEventListener('touchend',    cancel);
  document.addEventListener('touchcancel', cancel);
});

StickyNotes.PREFIX = '__stickynotes_';
StickyNotes.stickies = [];
StickyNotes.getDom = function(sticky) {
  return document.getElementById(StickyNotes.PREFIX + sticky.id);
};

StickyNotes.addSticky = function(sticky) {
  if (StickyNotes.getDom(sticky)) {
    return StickyNotes.Result.Failure;
  }
  var dom = document.createElement('div');
  dom.id = StickyNotes.PREFIX + sticky.id;
  dom.style.position = 'absolute';
  dom.style.top    = sticky.top + 'px';
  dom.style.left   = sticky.left + 'px';
  dom.style.minWidth  = '50px';
  dom.style.minHeight = '10px';
  dom.textContent  = sticky.content;
  dom.style.backgroundColor = sticky.color;
  dom.style.borderRadius = '10px';
  dom.style.textOverflow = 'ellipsis';
  dom.style.padding = '10px';
  dom.addEventListener('click', function() {
    StickyNotes.postMessage({ type: 'select-sticky', sticky: sticky });
  });
  var startX;
  var startY;
  var origX;
  var origY;
  var deltaX;
  var deltaY;
  function onTouchStart(e) {
    var touches = e.changedTouches;
    if (touches.length === 0) {
      return;
    }
    var touch = touches[0];
    e.stopPropagation();
    origX  = dom.offsetLeft;
    origY  = dom.offsetTop;
    startX = touch.clientX;
    startY = touch.clientY;
    deltaX = startX - origX;
    deltaY = startY - origY;
    dom.addEventListener('touchmove', onTouchMove);
    dom.addEventListener('touchend', onTouchEnd);
  };

  function onTouchMove(e) {
    var touches = e.changedTouches;
    if (touches.length === 0) {
      cancel();
      return;
    }
    var touch = touches[0];
    e.stopPropagation();
    e.preventDefault();
    dom.style.left = (touch.clientX - deltaX) + 'px';
    dom.style.top  = (touch.clientY - deltaY) + 'px';
  };

  function onTouchEnd(e) {
    e.stopPropagation();
    cancel();
    sticky.top = parseInt(dom.style.top);
    sticky.left = parseInt(dom.style.left);
    StickyNotes.postMessage({type: 'update-sticky', sticky: sticky});
  };
  function cancel() {
    dom.removeEventListener('touchmove', onTouchMove);
    dom.removeEventListener('touchup', onTouchEnd);
  }
  document.body.appendChild(dom);
  dom.addEventListener('touchstart', onTouchStart);
  sticky.dom = dom;
  StickyNotes.stickies.push(sticky);
  return StickyNotes.Result.Success;
};

StickyNotes.removeSticky = function(sticky) {
  if (sticky.dom) {
    document.body.removeChild(sticky.dom);
    sticky.dom = null;
    return StickyNotes.Result.Success;
  }
  return StickyNotes.Result.Failure;
};

StickyNotes.cleanStickies = function() {
  StickyNotes.stickies.forEach(StickyNotes.removeSticky);
  StickyNotes.stickies = [];
  return StickyNotes.Result.Success;
};

StickyNotes.reloadStickies = function(stickies) {
  StickyNotes.cleanStickies();
  stickies.forEach(StickyNotes.addSticky);
  return StickyNotes.Result.Success;
};

StickyNotes.jumpToSticky = function(sticky) {
  var dom = StickyNotes.getDom(sticky);
  if (!dom) {
    return StickyNotes.Result.Failure;
  }
  dom.scrollIntoView({block: 'end', behavior: 'smooth'});
  return StickyNotes.Result.Success;
};
