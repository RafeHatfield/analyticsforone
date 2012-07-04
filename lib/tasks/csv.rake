require 'rubygems'
require "benchmark"
require 'progressbar'
$KCODE = 'u'
require 'jcode'

namespace :csv do
  class Hash
    # Create a hash from an array of keys and corresponding values.
    def self.zip(keys, values, default=nil, &block)
      hsh = block_given? ? Hash.new(&block) : Hash.new(default)
      keys.zip(values) { |k,v| hsh[k]=v }
      hsh
    end
  end
  
  def import_csv(file)
    error_count = 0
    time = Benchmark.realtime do
      if Rails.env == 'staging'
        csv_file = "/home/suite101/pvs-2011-01-20/#{file}.csv"
      else
        csv_file = "/Users/jerrytian/suite101/Export/Export_Jan20/#{file}.csv"
      end
      
      n_lines = (%x[wc -l #{csv_file}]).split(' ')[0].to_f
      count = 0.0
      puts "Import #{file} data"
      
      pbar = ProgressBar.new("Importing...", 100)
      begin
        FasterCSV.foreach(csv_file, {:headers => true, :encoding => 'u', :quote_char => "|", :col_sep => "|"}) do |row|
          headers = row.headers
          values = cleanup(row.fields)
          
          hash = Hash.zip(headers, values)
          # hack for Daily_Page_Views table
          hash.delete('article_id2') if hash.keys.include?('article_id2')
          begin
            if file == 'Articles'
              # manually setting the primary key for articles
              id = hash.delete('id')
              file.singularize.constantize.create!(hash){|a| a.id = id}
            else
              file.singularize.camelize.constantize.create!(hash)
            end

          rescue => e
            error_count += 1
            puts "Failed to import around line #{count}:\n#{hash.to_yaml}\n#{e.message}"
          end
          percentage = (count += 1)/n_lines * 100
          pbar.set percentage
        end
      rescue => e
        puts "Failed to import:\n#{e.message}"
      end
      
      pbar.finish
    end
    puts "done. #{error_count} errors. Time elapsed #{time} seconds"
  end
  
  def cleanup(array)
    array.map!{|e| Iconv.conv('UTF-8//IGNORE', 'UTF-8', e)}
    array
  end
  
  desc "Import CSV files into database"
  task :import => :environment do
    file_names = %w(Articles Daily_Domain_Views Daily_Keyphrase_Views Daily_page_Views Raw_page_Views)
    file_names.each do |f|
      import_csv(f)
    end
  end
end