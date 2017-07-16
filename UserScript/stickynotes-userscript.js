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

var touchCount = 0;
function getScrollOffset(elem) {
  var p = { left: 0, top: 0 };
  for (var n = elem.parentNode; n !== document; n = n.parentNode) {
    p.left += n.scrollLeft;
    p.top += n.scrollTop;
  }
  return p;
};

document.addEventListener('touchstart', function(e) {
  var touches = e.changedTouches;
  if (touches.length === 0) {
    return;
  }
  var touch  = touches[0];
  var dom    = e.target;
  var startX = touch.clientX;
  var startY = touch.clientY;
  touchCount++;
  if (touchCount >= 3) {
    var scrollPosition = getScrollOffset(dom);
    StickyNotes.postMessage({
      type: 'create-sticky',
      x: startX + scrollPosition.left,
      y: startY + scrollPosition.top
    });
  }
  setTimeout(function() {
    touchCount = 0;
  }, 500);
});

StickyNotes.PREFIX = '__stickynotes_';
StickyNotes.stickies = [];
StickyNotes.getDom = function(sticky) {
  return document.getElementById(StickyNotes.PREFIX + sticky.uuid);
};

StickyNotes.addSticky = function(sticky) {
  if (StickyNotes.getDom(sticky)) {
    return StickyNotes.Result.Failure;
  }
  var dom = document.createElement('div');
  dom.id = StickyNotes.PREFIX + sticky.uuid;
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
    e.preventDefault();
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
  }

  function onTouchEnd(e) {
    e.preventDefault();
    e.stopPropagation();
    cancel();
    if (Math.abs(sticky.top - parseInt(dom.style.top)) < 5 &&
        Math.abs(sticky.left - parseInt(dom.style.left)) < 5) {
      StickyNotes.postMessage({ type: 'select-sticky', sticky: sticky });
    } else {
      sticky.top = parseInt(dom.style.top);
      sticky.left = parseInt(dom.style.left);
      StickyNotes.postMessage({type: 'update-sticky', sticky: sticky});
    }
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
