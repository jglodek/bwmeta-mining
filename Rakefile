namespace :wiki do

  desc "Scraps wikipedia MYSQL and saves scrapped info in mongo-db"
  task :page_scrap do
    require './wiki_page_scrap'
    wiki_page_scrap_and_save_to_mongo
  end

  desc "Takes scraped content from mongo and extracts features, saves again in mongodb"
  task :extract_features do
    require './wiki_extract_features'
    wiki_extract_features_and_save_to_mongo
  end

  desc "Takes extracted features and selects best set of features for data mining. Should reduce page-term matrix scarcity to ~10%."
  task :select_features do
    require './wiki_select_features'
    wiki_select_features_and_save_to_mongo
  end

  desc "Correlates pages using selected feature set"
  task :correlate_pages do
    require './wiki_correlate_pages'
    correlate_pages_and_save_to_mongo
  end

  desc "Runs all tasks for wiki pages correlation"
  task :all do
    require './wiki_page_scrap'
    require './wiki_extract_features'
    require './wiki_select_features'
    require './wiki_correlate_pages'
    print "Scrapping wiki pages..."
    t1 = Time.now
    wiki_page_scrap_and_save_to_mongo
    t2 = Time.now
    puts "ok!\t(#{t2-t1} s)"
    print "Extracting features..."
    t1 = Time.now
    wiki_extract_features_and_save_to_mongo
    t2 = Time.now
    puts "ok!\t(#{t2-t1} s)"
    print "Selecting features..."
    t1 = Time.now
    wiki_select_features_and_save_to_mongo
    t2 = Time.now
    puts "ok!\t(#{t2-t1} s)"
    print "Correlating wiki pages..."
    t1 = Time.now
    correlate_pages_and_save_to_mongo
    t2 = Time.now
    puts "ok!\t(#{t2-t1} s)"
    puts "Done!"
  end
end

namespace :expert_tags do
  desc "Parses scrapped pages for expert knowledge correlation tags. Requires wiki:page_scrap to be performed earlier."
  task :all do
    require './expert_tags_process.rb'
    process_expert_tags_and_save_to_mongo
  end
end
