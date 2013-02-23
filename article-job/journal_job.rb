
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

def get_journals_from_xml(xml_string)
  get_elem_from_xml(xml_string, 'bwmeta1.level.hierarchy_Journal_Journal')
end

$found = {}

def scrap_journal_data(journal_xml, col)
  journal = {}
  journal[:legacy_id] = journal_xml["id"]
  journal_xml.children.each do |c|
    case c.name
      when "name"
        journal[:names] ||= []
        journal[:names].push({name: c.text, lang: c["lang"]})
      when "hierarchy"
        element = c.css("element-ref").first
        journal[:parent] = element["ref"] if element
      when "note"
        journal[:notes] ||= []
        journal[:notes].push({lang: c["lang"], text: c.text})
      when "id"
        journal[:id] = {class: c["class"], text: c.text}
      when "date"
        journal[:dates] ||=[]
        journal[:dates].push({type: c["type"], text: c.text })
      when "attribute"
        case c["key"]
          when "journal.frequency"
            journal[:frequency] = c["value"]
          when "journal.www"
            journal[:www] = c["value"]
          else
            $found[c.name + " " + c["key"]] ||= 0
            $found[c.name + " " + c["key"]] += 1
        end
      when "contributor"
        journal[:contributors] ||= []
        contributor = {}
        contributor[:role] = c["role"] if c["role"]
        contributor[:title] = c["title"] if c["title"]
        surname =  c.css("[@key='person.surname']").first
        firstname =  c.css("[@key='person.firstname']").first
        contributor[:surname] = surname["value"] if surname
        contributor[:firstname] = firstname["value"] if firstname
        journal[:contributors].push contributor
      when "text"
        next
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
  col.insert journal
end

db = get_mongo

col = db["journals_scrap"]
col.remove

Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  journals = get_journals_from_xml(xml_file.read)


  journals.each do |journal|
    scrap_journal_data(journal, col)
  end
end

puts $found
