$(function(){
  $('#selector select[name="step[status]"]').on('change', function() {
    if ($('select[name="step[status]"]').val()=='in_progress' || $('select[name="step[status]"]').val()=='inactive') $('#new_task').css('display','block');
    else $('#new_task').css('display','none');
  });
});
