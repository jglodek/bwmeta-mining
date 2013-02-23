
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

def get_numbers_from_xml(xml_string)
  get_elem_from_xml(xml_string, 'bwmeta1.level.hierarchy_Journal_Number')
end

$found = {}

def scrap_number_data(number_xml, col)
  number = {}
  number[:legacy_id] = number_xml["id"]
  number_xml.children.each do |c|
    case c.name
      when "name"
        number[:names] ||= []
        number[:names].push({name: c.text, lang: c["lang"]})
      when "note"
        number[:notes] ||= []
        number[:notes].push({name: c.text, lang: c["lang"]})
      when "hierarchy"
        element = c.css("element-ref").first
        number[:parent] = element["ref"] if element
      when "text"
        next
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
  col.insert number
end



db = get_mongo
col = db["numbers_scrap"]
col.remove

Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  numbers = get_numbers_from_xml(xml_file.read)

  result = []
  numbers.each do |number|
    number = scrap_number_data(number, col)
    result.push number
  end

end

puts $found
