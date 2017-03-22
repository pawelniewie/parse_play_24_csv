#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

known_numbers = YAML.load(File.read('known_numbers.yml'))['known_numbers']

grouped_calls = File.open(ARGV[0], 'r:cp1250:utf-8') do |file|
	file.readline
	csv = SmarterCSV.process(file)
	csv
		.reject { |r| ['Internet', 'Rozm. przych.'].include?(r[:numer_telefonu]) }
		.reject { |r| r[:numer_telefonu].to_s.size < 9 }
		.group_by { |r| r[:numer_telefonu] }
end

match_known_numbers = %r[.*(#{known_numbers.values.join('|')}).*]
unknown_calls = grouped_calls
		.each_pair
		.reject { |(number, calls)| match_known_numbers =~ number.to_s }

unknown_calls.each do |(number, calls)|
	puts number
	puts (calls.map do |call|
		"   #{call[:data]} #{call[:'rodzaj_aktywności']} #{call[:'min./kb/szt.']} #{call[:kierunek]}"
	end.to_a)
end
