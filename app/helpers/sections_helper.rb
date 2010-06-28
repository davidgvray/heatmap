module SectionsHelper
  def show_number(section)
    survey = @survey || section.survey
    link_to '#' + section.id.to_s, survey_section_path(survey, section)
  end
end
