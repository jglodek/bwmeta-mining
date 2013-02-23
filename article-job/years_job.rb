
# encoding: utf-8
require 'rubygems'
require './configuration.rb'
require 'nokogiri'
require 'json'

def get_elem_from_xml(xml_string, level)
  doc = Nokogiri::XML(xml_string)
  hierarchy_elements =doc.css("[@level='#{level}']").to_a
  elems = hierarchy_elements.collect do |he|
    he.parent
  end
  elems
end

def get_years_from_xml(xml_string)
  get_elem_from_xml(xml_string, 'bwmeta1.level.hierarchy_Journal_Year')
end

$found = {}

def scrap_year_data(year_xml, col)
  year = {}
  year[:legacy_id] = year_xml["id"]
  year_xml.children.each do |c|
    case c.name
      when "name"
        year[:names] ||= []
        year[:names].push({name: c.text, lang: c["lang"]})
      when "hierarchy"
        element = c.css("element-ref").first
        year[:parent] = element["ref"]
      when "note"
        year[:notes] ||= []
        year[:notes].push({lang: c["lang"], text: c.text})
      when "contributor"
        year[:contributors] ||= []
        contributor = {}
        contributor[:role] = c["role"] if c["role"]
        contributor[:title] = c["title"] if c["title"]
        surname =  c.css("[@key='person.surname']").first
        firstname =  c.css("[@key='person.firrstname']").first
        contributor[:surname] = surname["value"] if surname
        contributor[:firstname] = firstname["value"] if firstname
        year[:contributors].push contributor
      when "text"
        next
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
  col.insert year
end

db = get_mongo

col = db["years_scrap"]
col.remove
Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  years = get_years_from_xml(xml_file.read)

  years.each do |year|
    scrap_year_data(year, col)
  end
end

puts $found
