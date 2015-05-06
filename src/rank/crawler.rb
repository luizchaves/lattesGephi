# http://www.webometrics.info/en/world
# http://www.webometrics.info/en/world?page=0
# http://www.webometrics.info/en/world?page=1
# ...
# http://www.webometrics.info/en/world?page=119

# table.sticky-table tbody tr td a
# table.sticky-table tbody tr td center

require 'byebug'
require 'nokogiri'
require 'open-uri'
require 'csv'
require 'progress_bar'

result = []

(0..119).each{|page_num|
	url = "http://www.webometrics.info/en/world?page=#{page_num}"
	page = Nokogiri::HTML(open(url))
	results = page.css("table.sticky-enabled tbody tr")
	# bar = ProgressBar.new(results.size)

	puts "#####{page_num}" if page_num % 4 == 0

	results.each{|row|
		# bar.increment!
		temp = []

		temp << row.at_css("td a")['href']
		row.css("td center").each{|center|
			text = center.children.to_s
			# <img alt="bandera" src="http://www.webometrics.info/sites/default/files/logos/us.png">
			if text.include? "bandera"
				text[/(\w+)\.png/]
				temp << $1
			else
				temp << text
			end
		}
		
		result << temp
	}

}

# byebug
CSV.open("webometrics.csv", "w") do |csv|
  csv << ["1", "2", "3", "4", "5", "6", "7"]
  result.each{|row|
  	csv << row
  }
end
