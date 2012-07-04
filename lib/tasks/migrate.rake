namespace :migrate do
  def select_shard(domain_extension)
    if SHARDING_ENABLED
      Octopus.using(domain_extension) { yield }
    else
      yield
    end
  end
  
  desc "Import CSV files into database"
  task :writers => :environment do
    count = 0.0
    [:com, :de, :net, :fr].each do |domain_extension|
      puts "Migrating #{domain_extension} writers..."
      
      select_shard(domain_extension) do
        articles = Article.all
        size = articles.size
        pbar = ProgressBar.new("Migrating writers...", 100)
        time = Benchmark.realtime do
          articles.each do |a|
            Writer.create(domain_extension).writer_ids_set << a.writer_id
            percentage = (count += 1)/size * 100
            pbar.set percentage
          end
          pbar.finish
        end
        puts "done. Time elapsed #{time} seconds"
      end
    end
  end
end