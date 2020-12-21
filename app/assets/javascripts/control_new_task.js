// 新規進捗作成の進捗ステータスで「進捗中」または「保留」を選んだ時以外、新規タスク作成フォームは表示しない
$(function(){
  $('#selector select[name="step[status]"]').on('change', function() {
    if ($('select[name="step[status]"]').val()=='in_progress' || $('select[name="step[status]"]').val()=='inactive') $('#new_task').css('display','block');
    else $('#new_task').css('display','none');
  });
});
