
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

def scrap_article_data(article_xml, col)
  article = {}
  article[:legacy_id] = article_xml["id"]
  article_xml.children.each do |c|
    case c.name
      when "name"
        article[:names] ||= []
        article[:names].push({name: c.text, lang: c["lang"]})
      when "text"
        next
      when "date"
        article[:dates] ||=[]
        article[:dates].push({type: c["type"], text: c.text })
      when "fulltext"
        next
      when "contributor"
        article[:contributors] ||= []
        contributor = {}
        contributor[:role] = c["role"] if c["role"]
        contributor[:title] = c["title"] if c["title"]
        surname =  c.css("[@key='person.surname']").first
        firstname =  c.css("[@key='person.firrstname']").first
        contributor[:surname] = surname["value"] if surname
        contributor[:firstname] = firstname["value"] if firstname
        article[:contributors].push contributor
      when "hierarchy"
        element = c.css("element-ref").first
        article[:parent] = element["ref"]
      when "note"
        article[:notes] ||= []
        article[:notes].push({lang: c["lang"], text: c.text})
      when "description"
        article[:descriptions] ||= []
        article[:descriptions].push({lang: c["lang"], text: c.text})
      when "contents"
        next
      when "attribute"
        case c["key"]
          when "bibliographical.description"
            article[:bibliographical_description] = c["value"]
          when "mhp.typ.form"
            article["mht_typ_form"] = c["value"]
          when "mhp.typ.rodz"
            article["mht_typ_rodz"] = c["value"]
          when "title.nonexplicit"
            article[:title_nonexplicit] = c["value"]
          when "mhp.reference"
            article[:mph_reference] = c["value"]
          when "baztech.autor.adress"
            next
          when "conference.title"
            next
          else
            $found[c.name + " " + c["key"]] ||= 0
            $found[c.name + " " + c["key"]] += 1
        end
      else
        $found[c.name] ||= 0
        $found[c.name] += 1
    end
  end
  col.insert article
end

db = get_mongo

col = db["articles_scrap"]
col.remove
Dir["./full_db/*.xml"].each do |file|
  xml_file = open(file)

  articles = get_articles_from_xml(xml_file.read)


  articles.each do |article|
    scrap_article_data(article, col)
  end
end

puts $found
