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


def scrap_article_data(article)

end

article_child = {}

def process_child(node, parent_hash)
  parent_hash[node.name] ||= {}
  parent_hash[node.name]["count"]||=0
  parent_hash[node.name]["count"]+=1
  node.children.each do |child|
    process_child(child, parent_hash[node.name])
  end
end

Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)
  articles = get_articles_from_xml(xml_file.read)
  articles.each do |article|
    article.children.each do |c|
      process_child(c, article_child)
    end
    scrap_article_data(article)
  end
end
puts JSON.pretty_generate(article_child)


