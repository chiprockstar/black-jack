 $(document).ready(function() {

  $(document).on('click', '#hit_form input',function() {
    $.ajax({
      type: 'POST',
      url: '/player_hit',
    }).done(function(msg) {
      $('#game').html(msg);
    });
    return false;
  });

  $(document).on('click', '#stay_form input',function() {
    $.ajax({
      type: 'POST',
      url: '/player_stay',
    }).done(function(msg) {
      $('#game').html(msg);
    });
    return false;
  });


  $(document).on('click', '#dealer_form input',function() {
    $.ajax({
      type: 'POST',
      url: '/dealer_hit',
    }).done(function(msg) {
      $('#game').html(msg);
    });
    return false;
  });







 });
