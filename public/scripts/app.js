function searchBook() {
  var bookName = document.getElementsByTagName("input")[0].value;

  $.get('/search', { title: bookName }, function (data) {
    console.log(data);
  });
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
