

// ----------------------------------------------------------------------------
// Global
// ----------------------------------------------------------------------------


// Google Analytics
// --------------------------------------------------

(function(b, o, i, l, e, r) {
  b.GoogleAnalyticsObject = l;
  b[l] || (b[l] =
    function() {
      (b[l].q = b[l].q || []).push(arguments)
    });
  b[l].l = +new Date;
  e = o.createElement(i);
  r = o.getElementsByTagName(i)[0];
  e.src = '//www.google-analytics.com/analytics.js';
  r.parentNode.insertBefore(e, r)
}(window, document, 'script', 'ga'));
ga('create', 'UA-34242159-4', 'auto');
ga('send', 'pageview');


// ----------------------------------------------------------------------------
// Page Specific
// ----------------------------------------------------------------------------


function setupVideo(videoID) {
  var usingTouch = false;

  $(videoID + " .overlay").on('touchstart',function(e) {
    usingTouch = true
    console.log(usingTouch);
    $(videoID + " video").attr("controls", "");
  });

  $(videoID).hover(
    function() { // mouseenter
      if (usingTouch) return;
      var video = $("video", this);
      video.attr("controls", "");
      $(".overlay", this).fadeOut();

    }, function() { // mouseleave
      if (usingTouch) return;
      var video = $("video", this);
      video.removeAttr("controls");
      if (video.get(0).paused) {
        $(".overlay", this).fadeIn();
      }
    }
  );

  $(videoID + " video").bind('play pause ended', function(e) {
    if (e.type === "pause" || e.type === "ended") {
      if (usingTouch || $(videoID).is(":hover") === false) {
        $(videoID + " .overlay").fadeIn();
      }
    } else if (e.type === "play") {
      $(videoID + " .overlay").fadeOut();
    }
  });

  $(videoID + " .overlay").click(function() {
    var video = $(videoID + " video");
    if (video.get(0).paused) {
      video.get(0).play();
    }
    // else {
    //   video.get(0).pause();
    // }
  });
}
