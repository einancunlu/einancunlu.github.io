// Browser detection for when you get desparate. A measure of last resort.
// http://rog.ie/post/9089341529/html5boilerplatejs
// sample CSS: html[data-useragent*='Chrome/13.0'] { ... }
//
// var b = document.documentElement;
// b.setAttribute('data-useragent',  navigator.userAgent);
// b.setAttribute('data-platform', navigator.platform);

var s = skrollr.init({mobileCheck: function(){ return false }});

/*
$(".appPreviewContainer").click(function() {
	$(".playButtonMobile").hide()
	$(".playButton").hide()
	$("button.play").click()
	return false;
});
*/

$(".appPreviewContainer").colorbox({iframe:true, innerWidth:263, innerHeight:468, closeButton: false, fixed: true});

// remap jQuery to $
(function($){

	/* trigger when page is ready */
	$(document).ready(function (){
	
		// your functions go here
	
	});
	
	
	/* optional triggers
	
	$(window).load(function() {
		
	});
	
	$(window).resize(function() {
		
	});
	
	*/

})(window.jQuery);