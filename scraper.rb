require 'byebug'
require 'httparty'
require 'nokogiri'


def check_duplicate(x)
  false
end
def check_for_100k(salary)
  byebug
  isMonth = false
  isHour = false
  isWeek = false
  if salary.include?("month")
    isMonth = true
    salary.slice!(" a month")
  elsif salary.include?(" an hour")
    isHour = true
    salary.slice!(" an hour")
  elsif salary.include?(" a week")
    isWeek = true
    salary.slice!(" a week")
  else
    salary.slice!(" a year")
  end
  salary_arr = salary.split(" ")
  salaries = salary_arr.select {|e| e.gsub(/\D/,'')!=""}
  sal_arr_ints = salaries.map{|e| e.gsub(/\D/,'').to_i}

  #week
  if isWeek
    if (sal_arr_ints.length==2 && (sal_arr_ints[0]>=1923||sal_arr_ints[1]>=1923)) || (sal_arr_ints[0]>=1923)
      return true
    else
      return false
    end
  #month
  elsif isMonth
    if (sal_arr_ints.length==2 && (sal_arr_ints[0]>=8333||sal_arr_ints[1]>=8333)) || (sal_arr_ints[0]>=8333)
      return true
    else
      return false
    end
  elsif isHour
    if (sal_arr_ints.length==2 && (sal_arr_ints[0]>=54||sal_arr_ints[1]>=54)) || (sal_arr_ints[0]>=54)
      return true
    else
      return false
    end
  else #year
    if (sal_arr_ints.length==2 && (sal_arr_ints[0]>=100000||sal_arr_ints[1]>=100000)) || (sal_arr_ints[0]>=100000)
      return true
    else
      return false
    end
  end    
end
def scraper
  step=0
  results = []
  #get first 500 jobs for now; a hint for later: Page 1 of 5,595 jobs divide by 50; stop loop there
  while results.length <= 500 do
    url = "https://www.indeed.com/jobs?q=Ruby%20on%20Rails&limit=50&start=#{step}"
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page.body)
    results_per_page = parsed_page.css('td.resultContent')
    byebug
    results_per_page.each do |result|
      job_title = result.css('.heading4').text
      if job_title.slice(0,3)=="new"
        job_title.slice!(0,3)
      end
      job_salary = result.css('.salary-snippet-container').text
      job_location = result.css('.companyLocation').text
      job_company = result.css('span.companyName').text
      job = {:title=>job_title,:salary=>job_salary,:location=>job_location,:company=>job_company}
      #push on salaried jobs!
      
      if (!check_duplicate(results) && job_salary && job_salary != "" && check_for_100k(job_salary))
        # puts job_salary
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

scraper
