require 'rubygems'
require 'sinatra'
require 'bossman'
include BOSSMan

configure do
	set :application_id, 'YOUR_YAHOO_BOSS_KEY'
	set :site, 'yoursite.com'
	set :results_per_page, 10
end

helpers do
	include Rack::Utils
	alias_method :h, :escape_html

	def next_page
		link_text = 'Next &gt;'

		if (more_than_one_result_page? and not on_last_result_page?)
			start = @start.to_i + options.results_per_page
			link_to_result_page(link_text, start)
		else 
			inactive_link(link_text)
		end
	end

	def previous_page
		link_text = '&lt; Previous'

		if (more_than_one_result_page? and not on_first_result_page?)
			start = @start.to_i - options.results_per_page
			link_to_result_page(link_text, start)
		else
			inactive_link(link_text)
		end
	end

	private

	def inactive_link(link_text)
		'<span class="inactive">' + link_text + '</span>'
	end

	def link_to_result_page(link_text, start)
		start_param = (start > 0) ? '&start=' + start.to_s : '' 
		'<a href="/results?q=' + escape(@q) + start_param + '">' + link_text + '</a>'
	end
	
	def more_than_one_result_page?
		@boss.totalhits.to_i > options.results_per_page
	end

	def on_first_result_page?
		@start.to_i == 0
	end

	def on_last_result_page?
		@boss.totalhits.to_i <= @start.to_i + options.results_per_page
	end
end

get '/' do
	erb :index
end

get '/results' do
	@q = params[:q]
	@start = params[:start]
	BOSSMan.application_id = options.application_id
	@boss = BOSSMan::Search.web(@q + '+site:' + options.site, {:count => options.results_per_page, :start => @start})
	erb :results
end
