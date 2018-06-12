(function() {
  var $loginCheckWaiting = document.getElementById('login-check-waiting');
  if (!$loginCheckWaiting) return;

  setTimeout(function() {
    window.location.reload();
  }, 5000);
})();
