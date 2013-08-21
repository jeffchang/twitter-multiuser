$(document).ready(function() {
  $('#tweet').submit(function(e) {
    e.preventDefault();
    data = "tweet="+$('input[name='tweet']').val();
    $.post('/', data, function(response) {
      window.location.href='/';
    });
  });
});
