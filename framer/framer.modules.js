require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({"DevicePixelRatio":[function(require,module,exports){
exports.DevicePixelRatio = (function() {
  var VALUE, dpr, log;

  function DevicePixelRatio() {}

  log = function(v) {
    console.log("DevicePixelRatio set as:", v);
    return v;
  };

  dpr = function() {
    var devicePixelRatio, device_2x, device_3p5x, device_3x, i, initialValue, j, k, len, len1, len2, ref, ref1, ref2, value;
    initialValue = 1;
    value = initialValue;
    if (Utils.isFramerStudio() || Utils.isDesktop()) {
      ref = ['apple-', 'google-nexus-', 'iphone-6-', 'iphone-5', 'ipad-air', 'nexus-9', 'applewatch'];
      for (i = 0, len = ref.length; i < len; i++) {
        device_2x = ref[i];
        if (_.startsWith(Framer.Device.deviceType, device_2x)) {
          value = 2;
        }
      }
      ref1 = ['apple-iphone-6s-plus', 'google-nexus-5', 'htc-one-', 'microsoft-lumia-', 'samsung-galaxy-note-', 'iphone-6plus', 'nexus-5'];
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        device_3x = ref1[j];
        if (_.startsWith(Framer.Device.deviceType, device_3x)) {
          value = 3;
        }
      }
      ref2 = ['google-nexus-6'];
      for (k = 0, len2 = ref2.length; k < len2; k++) {
        device_3p5x = ref2[k];
        if (_.startsWith(Framer.Device.deviceType, device_3p5x)) {
          value = 3.5;
        }
      }
    }
    if (value !== initialValue) {
      return log(value);
    }
    if (!Utils.isDesktop()) {
      devicePixelRatio = Utils.devicePixelRatio();
      if (devicePixelRatio > initialValue) {
        value = devicePixelRatio;
      }
    }
    return log(value);
  };

  VALUE = dpr();

  DevicePixelRatio.calc = function(v) {
    return v * VALUE;
  };

  DevicePixelRatio.value = VALUE;

  return DevicePixelRatio;

})();

exports.dpr = exports.DevicePixelRatio.calc;


},{}]},{},[])
//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZnJhbWVyLm1vZHVsZXMuanMiLCJzb3VyY2VzIjpbIi4uLy4uLy4uLy4uLy4uL1VzZXJzL2VpbmFuY3VubHUvRHJvcGJveC9Qcml2YXRlL1dlYnNpdGUvUHJvdG90eXBlLmZyYW1lci9tb2R1bGVzL0RldmljZVBpeGVsUmF0aW8uY29mZmVlIiwibm9kZV9tb2R1bGVzL2Jyb3dzZXItcGFjay9fcHJlbHVkZS5qcyJdLCJzb3VyY2VzQ29udGVudCI6WyIjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcbiMgQ3JlYXRlZCBvbiAyMyBERUMgMjAxNSBieSBKb3JkYW4gRG9ic29uIC8gQGpvcmRhbmRvYnNvbiAvIGpvcmRhbkBicm90aGUucnNcbiMgVXBkYXRlZCBvbiAxMiBBUFIgMjAxNiBieSBKb3JkYW4gRG9ic29uIHdpdGggdGhhbmtzIHRvIE5pa29sYXkgQmVyZXpvdnNraXkhXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcbiNcbiMgVXNlIHRvIG1lYXN1cmUgcGl4ZWxzIGF0IDF4IGFuZCBoYXZlIGl0IGFkanVzdCBmb3IgdGhlIFBpeGVsIFJhdGlvXG4jXG4jIFRvIEdldCBTdGFydGVkLi4uXG4jXG4jICAxLiBQbGFjZSB0aGlzIGZpbGUgaW4gRnJhbWVyIFN0dWRpbyBtb2R1bGVzIGRpcmVjdG9yeVxuI1xuIyAgMi4gSW4geW91ciBwcm9qZWN0IGluY2x1ZGU6XG4jXG4jICAgICB7ZHByfSA9IHJlcXVpcmUgJ0RldmljZVBpeGVsUmF0aW8nXG4jXG4jICAzLiBXaGVuIHlvdSBjcmVhdGUgYSBsYXllciBkbyBzbyBAIDF4IGFuZCBhZGQgdGhlIGRwciBmdW5jdGlvbiB0byB0aGUgdmFsdWVcbiNcbiMgICAgIHJlY3QgPSBuZXcgTGF5ZXJcbiMgICAgICAgd2lkdGg6ICBkcHIoMzAwKVxuIyAgICAgICBoZWlnaHQ6IGRwciA1MFxuIyAgICAgICB4OiAgICAgIChkcHIgMTYpXG4jIFxuIyAgNC4gVXNlIGl0IGZvciBtb3JlIHRoYW4gbGF5ZXIgc2l6ZS4gSGVyZSdzIGFkdmFuY2VkIHVzYWdlIGZvciBtdWx0aSBkZXZpY2VzOlxuI1xuI1x0XHRcdCMgQWRkIGEgbGlzdCByb3cgdy8gdGhlIGhlaWdodCAmIHRleHQgc2l6aW5nL2xheW91dCB1c2luZyBkcHIoKVxuI1xuIyAgICAgbGlzdFJvdyA9IG5ldyBMYXllclxuIyAgICAgICB3aWR0aDogU2NyZWVuLndpZHRoXG4jICAgICAgIGhlaWdodDogZHByIDQ0XG4jICAgICAgIGh0bWw6IFwiTGlzdCBJdGVtXCJcbiMgICAgICAgYmFja2dyb3VuZENvbG9yOiBcIiNmZmZcIlxuIyAgICAgICBjb2xvcjogXCIjMDAwXCJcbiMgICAgICAgc3R5bGU6IFxuIyAgICAgICAgIGZvbnQ6IFwiNDAwICN7ZHByIDE0fXB4LyN7ZHByIDQyfXB4IC1hcHBsZS1zeXN0ZW0sIEhlbHZldGljYSBOZXVlXCJcbiMgICAgICAgICB0ZXh0SW5kZW50OiBcIiN7ZHByIDE1fXB4XCJcbiNcbiMgXHRcdCMgQWRkIGEgY2hldnJvbiB3aXRoIHRoZSBzaXplLCByaWdodCBtYXJnaW4gJiBzaGFkb3cgc3Ryb2tlIHVzaW5nIGRwcigpXG4jICAgICBcbiMgICAgIGxpc3RDaGV2cm9uID0gbmV3IExheWVyXG4jICAgICBcdHN1cGVyTGF5ZXI6IGxpc3RSb3dcbiMgICAgIFx0d2lkdGg6ICBkcHIgOVxuIyAgICAgXHRoZWlnaHQ6IGRwciA5XG4jICAgICBcdG1heFg6IGxpc3RSb3cud2lkdGggLSBkcHIgMTVcbiMgICAgIFx0eTogICAgbGlzdFJvdy5oZWlnaHQgLyAyXG4jICAgICBcdG9yaWdpblg6IDFcbiMgICAgIFx0b3JpZ2luWTogMFxuIyAgICAgXHRyb3RhdGlvbjogNDVcbiMgICAgIFx0YmFja2dyb3VuZENvbG9yOiBcIlwiXG4jICAgICBcdHN0eWxlOlxuIyAgICAgXHRcdGJveFNoYWRvdzogXCJpbnNldCAtI3tkcHIgMn1weCAje2RwciAyfXB4IDAgI0JDQkNDMVwiXG4jXG4jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblxuY2xhc3MgZXhwb3J0cy5EZXZpY2VQaXhlbFJhdGlvXG5cblx0IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblx0IyBQcml2YXRlIE1ldGhvZHMgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblx0XG5cdGxvZyA9ICh2KSAtPlxuXHRcdGNvbnNvbGUubG9nIFwiRGV2aWNlUGl4ZWxSYXRpbyBzZXQgYXM6XCIsIHZcblx0XHRyZXR1cm4gdlxuXG5cdGRwciA9ICgpIC0+XG5cdFx0aW5pdGlhbFZhbHVlID0gMVxuXHRcdHZhbHVlID0gaW5pdGlhbFZhbHVlXG5cdFx0IyBDaGVjayBpZiBpbiBTdHVkaW8gb3IgRGVza3RvcCB0byBmaWd1cmUgb3V0IHdoYXQgdGhlIHNjYWxpbmcgc2hvdWxkIGJlXG5cdFx0aWYgVXRpbHMuaXNGcmFtZXJTdHVkaW8oKSBvciBVdGlscy5pc0Rlc2t0b3AoKVxuXG5cdFx0XHQjIENoZWNrIGZvciAyeCBkZXZpY2VzIFxuXHRcdFx0Zm9yIGRldmljZV8yeCBpbiBbJ2FwcGxlLScsICdnb29nbGUtbmV4dXMtJywgJ2lwaG9uZS02LScsICdpcGhvbmUtNScsICdpcGFkLWFpcicsICduZXh1cy05JywgJ2FwcGxld2F0Y2gnXVxuXHRcdFx0XHR2YWx1ZSA9IDIgaWYgXy5zdGFydHNXaXRoKEZyYW1lci5EZXZpY2UuZGV2aWNlVHlwZSwgZGV2aWNlXzJ4KVxuXG5cdFx0XHQjIENoZWNrIGZvciAzeCBkZXZpY2VzXG5cdFx0XHRmb3IgZGV2aWNlXzN4IGluIFsnYXBwbGUtaXBob25lLTZzLXBsdXMnLCAnZ29vZ2xlLW5leHVzLTUnLCAnaHRjLW9uZS0nLCAnbWljcm9zb2Z0LWx1bWlhLScsICdzYW1zdW5nLWdhbGF4eS1ub3RlLScsICdpcGhvbmUtNnBsdXMnLCAnbmV4dXMtNSddXG5cdFx0XHRcdHZhbHVlID0gMyBpZiBfLnN0YXJ0c1dpdGgoRnJhbWVyLkRldmljZS5kZXZpY2VUeXBlLCBkZXZpY2VfM3gpXG5cdFx0XHRcdFxuXHRcdFx0IyBDaGVjayBmb3IgMy41eCBkZXZpY2VzXG5cdFx0XHRmb3IgZGV2aWNlXzNwNXggaW4gWydnb29nbGUtbmV4dXMtNiddXG5cdFx0XHRcdHZhbHVlID0gMy41IGlmIF8uc3RhcnRzV2l0aChGcmFtZXIuRGV2aWNlLmRldmljZVR5cGUsIGRldmljZV8zcDV4KVxuXG5cdFx0IyBSZXR1cm4gaWYgdGhlIHZhbHVlIGNoYW5nZWQuLi4gb3RoZXJ3aXNlIGNvbnRpbnVlXG5cdFx0cmV0dXJuIGxvZyB2YWx1ZSB1bmxlc3MgdmFsdWUgaXMgaW5pdGlhbFZhbHVlXG5cdFx0XG5cdFx0IyBTZXQgVW5pdHMgYmFzZWQgb24gRGV2aWNlIFBpeGVsIFJhdGlvIEV4Y2VwdCBmb3IgRGVza3RvcFxuXHRcdHVubGVzcyBVdGlscy5pc0Rlc2t0b3AoKVxuXHRcdFx0ZGV2aWNlUGl4ZWxSYXRpbyA9IFV0aWxzLmRldmljZVBpeGVsUmF0aW8oKVxuXHRcdFx0IyBpZiBpdCdzIGdyZWF0ZXIgdGhhbiAxIHRoZW4gdXBkYXRlIGl0IVxuXHRcdFx0dmFsdWUgPSBkZXZpY2VQaXhlbFJhdGlvIGlmIGRldmljZVBpeGVsUmF0aW8gPiBpbml0aWFsVmFsdWVcblxuXHRcdCMgcmV0dXJuIHRoZSB2YWx1ZSBldmVuIGlmIGl0IGhhc24ndCBjaGFuZ2VkIGFuZCBsb2cgaXQgZXZlcnl0aW1lIGl0cyBzZXRcblx0XHRyZXR1cm4gbG9nIHZhbHVlXG5cdFx0XG5cdCMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cdCMgQ29uc3RhbnQgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG5cdFxuXHRWQUxVRSA9IGRwcigpXG5cblx0IyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblx0IyBQdWJsaWMgTWV0aG9kcyAjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblx0XG5cdEAuY2FsYyAgPSAodikgLT4gcmV0dXJuIHYgKiBWQUxVRVxuXHRcblx0QC52YWx1ZSA9IFZBTFVFXG5cbiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjXG4jIENyZWF0ZSBhIHNob3J0aGFuZCB0byBnZXQgZGlyZWN0bHkgdG8gdGhlIGNhbGMgc3RhdGVtZW50XG5cbmV4cG9ydHMuZHByID0gZXhwb3J0cy5EZXZpY2VQaXhlbFJhdGlvLmNhbGNcbiIsIihmdW5jdGlvbiBlKHQsbixyKXtmdW5jdGlvbiBzKG8sdSl7aWYoIW5bb10pe2lmKCF0W29dKXt2YXIgYT10eXBlb2YgcmVxdWlyZT09XCJmdW5jdGlvblwiJiZyZXF1aXJlO2lmKCF1JiZhKXJldHVybiBhKG8sITApO2lmKGkpcmV0dXJuIGkobywhMCk7dmFyIGY9bmV3IEVycm9yKFwiQ2Fubm90IGZpbmQgbW9kdWxlICdcIitvK1wiJ1wiKTt0aHJvdyBmLmNvZGU9XCJNT0RVTEVfTk9UX0ZPVU5EXCIsZn12YXIgbD1uW29dPXtleHBvcnRzOnt9fTt0W29dWzBdLmNhbGwobC5leHBvcnRzLGZ1bmN0aW9uKGUpe3ZhciBuPXRbb11bMV1bZV07cmV0dXJuIHMobj9uOmUpfSxsLGwuZXhwb3J0cyxlLHQsbixyKX1yZXR1cm4gbltvXS5leHBvcnRzfXZhciBpPXR5cGVvZiByZXF1aXJlPT1cImZ1bmN0aW9uXCImJnJlcXVpcmU7Zm9yKHZhciBvPTA7bzxyLmxlbmd0aDtvKyspcyhyW29dKTtyZXR1cm4gc30pIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQ0FBO0FEcURNLE9BQU8sQ0FBQztBQUtiLE1BQUE7Ozs7RUFBQSxHQUFBLEdBQU0sU0FBQyxDQUFEO0lBQ0wsT0FBTyxDQUFDLEdBQVIsQ0FBWSwwQkFBWixFQUF3QyxDQUF4QztBQUNBLFdBQU87RUFGRjs7RUFJTixHQUFBLEdBQU0sU0FBQTtBQUNMLFFBQUE7SUFBQSxZQUFBLEdBQWU7SUFDZixLQUFBLEdBQVE7SUFFUixJQUFHLEtBQUssQ0FBQyxjQUFOLENBQUEsQ0FBQSxJQUEwQixLQUFLLENBQUMsU0FBTixDQUFBLENBQTdCO0FBR0M7QUFBQSxXQUFBLHFDQUFBOztRQUNDLElBQWEsQ0FBQyxDQUFDLFVBQUYsQ0FBYSxNQUFNLENBQUMsTUFBTSxDQUFDLFVBQTNCLEVBQXVDLFNBQXZDLENBQWI7VUFBQSxLQUFBLEdBQVEsRUFBUjs7QUFERDtBQUlBO0FBQUEsV0FBQSx3Q0FBQTs7UUFDQyxJQUFhLENBQUMsQ0FBQyxVQUFGLENBQWEsTUFBTSxDQUFDLE1BQU0sQ0FBQyxVQUEzQixFQUF1QyxTQUF2QyxDQUFiO1VBQUEsS0FBQSxHQUFRLEVBQVI7O0FBREQ7QUFJQTtBQUFBLFdBQUEsd0NBQUE7O1FBQ0MsSUFBZSxDQUFDLENBQUMsVUFBRixDQUFhLE1BQU0sQ0FBQyxNQUFNLENBQUMsVUFBM0IsRUFBdUMsV0FBdkMsQ0FBZjtVQUFBLEtBQUEsR0FBUSxJQUFSOztBQURELE9BWEQ7O0lBZUEsSUFBd0IsS0FBQSxLQUFTLFlBQWpDO0FBQUEsYUFBTyxHQUFBLENBQUksS0FBSixFQUFQOztJQUdBLElBQUEsQ0FBTyxLQUFLLENBQUMsU0FBTixDQUFBLENBQVA7TUFDQyxnQkFBQSxHQUFtQixLQUFLLENBQUMsZ0JBQU4sQ0FBQTtNQUVuQixJQUE0QixnQkFBQSxHQUFtQixZQUEvQztRQUFBLEtBQUEsR0FBUSxpQkFBUjtPQUhEOztBQU1BLFdBQU8sR0FBQSxDQUFJLEtBQUo7RUE1QkY7O0VBaUNOLEtBQUEsR0FBUSxHQUFBLENBQUE7O0VBS1IsZ0JBQUMsQ0FBQyxJQUFGLEdBQVUsU0FBQyxDQUFEO0FBQU8sV0FBTyxDQUFBLEdBQUk7RUFBbEI7O0VBRVYsZ0JBQUMsQ0FBQyxLQUFGLEdBQVU7Ozs7OztBQUtYLE9BQU8sQ0FBQyxHQUFSLEdBQWMsT0FBTyxDQUFDLGdCQUFnQixDQUFDIn0=
