require 'lib/writer_partition.rb'

namespace :writer_partition do
    
  # RAILS_ENV=production rake writer_partition:create column=keyphrase
  # RAILS_ENV=staging rake writer_partition:create column=keyphrase
  desc "Create partition table"
  task :create => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    
    partition.create_master_table
        
    puts "Creating partitioned tables"
    partition.create_partition_tables
    
    puts "Creating trigger function"
    partition.trigger    
  end
  
  # RAILS_ENV=production rake writer_partition:indices column=keyphrase
  desc "Add indices for each partition"
  task :indices => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    
    puts "Adding indices to partitioned tables"
    partition.add_indices
  end
  
  # RAILS_ENV=production rake writer_partition:pks column=keyphrase
  desc "Add indices for each partition"
  task :pks => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    
    puts "Adding primary keys to partitioned tables"
    partition.add_primary_keys
  end
  
  # RAILS_ENV=production rake writer_partition:drop_indices column=domain
  desc "Drop indices for each partition"
  task :drop_indices => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    
    puts "Dropping indices on partitioned tables"
    partition.drop_indices
  end
  
  
  # RAILS_ENV=production rake writer_partition:drop column=keyphrase
  desc "Create partition table"
  task :drop => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    
    partition.drop_tables
  end
  
  # RAILS_ENV=production rake writer_partition:migrate column=page
  desc "Migration data from unpartitioned table"
  task :migrate => :environment do
    partition = WriterPartition.new(ENV['column'], PARTITION_SIZE)
    start_date = '2011-05-12' 
    end_date = '2011-05-12'
    puts "Migrating data to #{partition.master_table}"
    partition.migrate(start_date, end_date)
  end
  
end
# recommended sequence

# RAILS_ENV=production rake writer_partition:migrate column=page
# RAILS_ENV=production rake writer_partition:migrate column=domain 
# RAILS_ENV=production rake writer_partition:migrate column=keyphrase

# RAILS_ENV=production rake writer_partition:pks column=page
# RAILS_ENV=production rake writer_partition:pks column=domain
# RAILS_ENV=production rake writer_partition:pks column=keyphrase

# RAILS_ENV=production rake writer_partition:indices column=keyphrase
# RAILS_ENV=production rake writer_partition:indices column=page
# RAILS_ENV=production rake writer_partition:indices column=domain
