
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

def get_articles_from_xml(xml_string)
  get_elem_from_xml(xml_string, 'bwmeta1.level.hierarchy_Journal_Article')
end

$found = {}

def scrap_article_data(article_xml, db)
  article = {}
  article[:legacy_id] = article_xml["id"]

  article_xml.children.each do |c|
    case c.name
      when "name"
        article[:names] ||= []
        article[:names].push({name: c.text, lang: c["lang"]})
      when "attribute"
        case c["key"]
        when "bibliographical.description"
          article[:description] = c["value"]
        else

          $found[c.name + " " + c["key"] ||= 0
          $found[c.name + " " + c["key"]] += 1
        end
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
end

Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  articles = get_articles_from_xml(xml_file.read)

  db = get_mongo

  articles.each do |article|
    scrap_article_data(article, db)
  end
end

puts $found
