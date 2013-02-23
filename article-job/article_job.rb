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


def scrap_article_data(article_xml, db)
  article = {}
  article[:legacy_id] = article_xml["id"]

  article_xml.children.each do |c|

  end
  puts article
end

plik = 0
plikow = Dir["./full_db/*.xml"].length

Dir["./full_db/*.xml"].each do |file|
  plik+=1
  puts "plik #{plik}/#{plikow}" if plik%10==0

  xml_file = open(file)

  articles = get_articles_from_xml(xml_file.read)

  db = get_mongo

  articles.each do |article|
    scrap_article_data(article, db)
  end
end
puts JSON.pretty_generate(article_child)


