(function() {
  var $heroSlideshow = document.getElementsByClassName('.hero-slideshow');
  if (!$heroSlideshow) return;


  $('.hero-img').hide();
  $('.hero-img').first().show();

  setInterval(function() {
    $('.hero-slideshow > .hero-img:first')
      .fadeOut(2000)
      .next()
      .fadeIn(2000)
      .end()
      .appendTo('.hero-slideshow');
  }, 7000);
})();
