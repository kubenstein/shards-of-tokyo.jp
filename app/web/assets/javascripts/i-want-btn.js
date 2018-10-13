(function() {
  $('.iwant').click(function(e) {
    var text = $(e.target).data('info-placeholder');
    var $el = $('#text');
    $el[0].scrollIntoView({ behavior: 'smooth' });

    setTimeout(function() {
      $el.addClass('blink').text(text);

      setTimeout(function() {
        $el.removeClass('blink');
      }, 1500);
    }, 1000);
  });
})();
