class Pages::QuestionForm < BaseForm
  include QuestionTextValidation

  attr_accessor :question_text, :hint_text, :is_optional, :answer_type

  # TODO: We could lose these attributes once we have an Check your answers page
  attr_accessor :answer_settings, :page_heading, :guidance_markdown

  # TODO: Remove once we get rid of session storage
  attr_accessor :form_id, :page_id

  validates :hint_text, length: { maximum: 500 }
end
