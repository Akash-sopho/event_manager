require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody'])
    legislators = legislators.officials
    legislator_names = legislators.map(&:name).join(", ")
  rescue
    "whatever"
  end
end

def clean_zip(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("../output") unless Dir.exists? "../output"

  filename = "../output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

template_letter = File.read("../form_letter.erb")
erb_template = ERB.new template_letter

contents = CSV.open "../event_attendees.csv", headers:true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zip(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end
