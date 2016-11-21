function searchBook() {
  var bookTitle = document.getElementsByTagName("input")[0].value,
      indexPage = true,
      $result_partial = $('#results'),
      $dimmer = (function () {
        if ($('#index_dimmer').length === 0) {
          indexPage = false;
          return $('#results_dimmer');
        } else {
          return $('#index_dimmer');
        }
      })();

  $dimmer.dimmer('show');

  $.get('/search', { title: bookTitle }, function (data) {
    $dimmer.dimmer('hide');

    if (indexPage === true) { $('.ui.main.text.container').remove(); }

    if (!$result_partial.hasClass('result_container')) {
      $result_partial.addClass('result_container');
    }

    $result_partial.html(data);
    $result_partial.transition('slide down in');
  }
  );
};

$(function () {
  $('input').keypress(function (e) {
    var key = e.which;
    if (key === 13) {
      searchBook();
    }
  });

  $('#search_button').click(function (e) {
    searchBook();
  });
});
