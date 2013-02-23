
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

$found = {}


def scrap_volume_data(volume_xml, col)
  volume = {}
  volume[:legacy_id] = volume_xml["id"]

  volume_xml.children.each do |c|
    case c.name
      when "name"
        volume[:names] ||= []
        volume[:names].push({name: c.text, lang: c["lang"]})
      when "text"
        next
      when "note"
        volume[:notes] ||=[]
        volume[:notes].push({name: c.text, lang: c["lang"]})
     when "contributor"
        volume[:contributors] ||= []
        contributor = {}
        contributor[:role] = c["role"] if c["role"]
        contributor[:title] = c["title"] if c["title"]
        surname =  c.css("[@key='person.surname']").first
        firstname =  c.css("[@key='person.firrstname']").first
        contributor[:surname] = surname["value"] if surname
        contributor[:firstname] = firstname["value"] if firstname
        volume[:contributors].push contributor
      when "hierarchy"
        element = c.css("element-ref").first
        volume[:parent] = element["ref"]
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
  col.insert volume
end

db = get_mongo

col = db["volumes_scrap"]
col.remove
Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  volumes = get_volumes_from_xml(xml_file.read)

  volumes.each do |volume|
    scrap_volume_data(volume, col)
  end
end

puts $found
