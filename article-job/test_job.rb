
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

def get_volumes_from_xml(xml_string)
  get_elem_from_xml(xml_string, 'bwmeta1.level.hierarchy_Journal_Volume')
end



 hash = {}

Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  doc = Nokogiri::XML(xml_file.read)

  hierarchy_elements =doc.css("hierarchy").to_a

  elems = hierarchy_elements.each do |he|
    hash[he["level"]] ||= 0
    hash[he["level"]] += 1


  end

end

puts hash
