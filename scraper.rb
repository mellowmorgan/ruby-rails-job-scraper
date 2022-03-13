require 'byebug'
require 'httparty'
require 'nokogiri'


def check_duplicate(x)
  false
end

def scraper
  step=0
  # 
  results = []
  #get first 500 jobs for now; a hint for later: Page 1 of 5,595 jobs divide by 50; stop loop there
  while results.length <= 500 do
    url = "https://www.indeed.com/jobs?q=Ruby%20on%20Rails&limit=50&start=#{step}"
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page.body)
    results_per_page = parsed_page.css('td.resultContent')

    results_per_page.each do |result|
      job_title = result.css('.heading4').text
      job_salary = result.css('.salary-snippet-container').text
      job_location = result.css('.companyLocation').text
      job_company = result.css('span.companyName').text
      job = {:title=>job_title,:salary=>job_salary,:location=>job_location,:company=>job_company}
      #push on salaried jobs!
      if (!check_duplicate(results) && job_salary && job_salary != "")
        results.push(job)
      end
    end
    step+=50
  end
  results
end
  
  # byebug
  #for each div of job, get title, company, link, salary, location WHERE:
  #THIS PARSED.css('div.salary-snippet-container').text will give string "$120,000 - $170,000 a year"
  #then look for 100k and push into objects, list of all objects of jobs :)  

puts scraper
