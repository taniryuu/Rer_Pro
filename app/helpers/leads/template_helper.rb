module Leads::TemplateHelper
  # テンプレートがある場合、日付をスライドさせる
  def modified_date(date, template_date, date_difference)
    if template_date.blank?
      date
    elsif template_date.is_a?(Date)
      template_date + date_difference
    else
      Date.parse(template_date) + date_difference
    end
  end
      
end
