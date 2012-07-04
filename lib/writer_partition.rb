class WriterPartition
  
  def initialize(column, partition_size)
    raise 'No column name specified!' if column.blank?
    
    @column = column
    @partition_size = partition_size
    shards_config = YAML.load_file("#{Rails.root.to_s}/config/shards.yml")['octopus'][Rails.env]
    
    @conns = []
    shards = []
    if ['development', 'test'].include?(Rails.env)
      shards = %w(com)
    else
      shards = %w(com de fr net)
    end
    
    shards.each do |shard|
      config = shards_config[shard]
      @owner = config["username"]
      @conns << PGconn.new(config["host"], config["port"], '', '', config["database"], @owner, config["password"])
    end
  end
  
  def master_table
    "daily_#{@column}_views_master"
  end
  
  # column can be
  # keyphrase, domain, or page
  def trigger
    trigger_function = "insert_#{master_table}"
    unless @column == 'page'
      column = "#{@column},"
      column_function = "coalesce(quote_literal(NEW.#{@column}), 'NULL') || ',' ||"
    end
    
    cmd = <<-COMMAND
      CREATE OR REPLACE FUNCTION #{trigger_function}() 
      RETURNS TRIGGER AS $$ 
      DECLARE
        ins_sql TEXT; 
      BEGIN
        ins_sql := 'INSERT INTO daily_#{@column}_views_' || (NEW.writer_id % #{@partition_size}) ||
          '(date,article_id,#{column}count,writer_id,partition_id) 
          VALUES ' ||
          '('|| quote_literal(NEW.date) || ',' || NEW.article_id ||',' ||
          	#{column_function} 
      			NEW.count || ',' || 
      			NEW.writer_id || ',' || (NEW.writer_id % #{@partition_size}) ||')'
          ; 
        EXECUTE ins_sql;
        RETURN NULL;
      END; 
      $$
      LANGUAGE plpgsql;
      
      CREATE TRIGGER #{trigger_function}_trigger
          BEFORE INSERT ON #{master_table}
          FOR EACH ROW EXECUTE PROCEDURE #{trigger_function}();
    COMMAND
    @conns.each{|conn| conn.exec(cmd)}
  end
      
  def create_master_table
    unless @column == 'page'
      column = "#{@column} character varying(255),"
    end
    
    cmd = <<-COMMANDS
      CREATE TABLE #{master_table}
      (
        id serial NOT NULL,
        date date,
        article_id integer,
        #{column}
        count integer,
        writer_id integer,
        created_at timestamp without time zone,
        updated_at timestamp without time zone,
        partition_id integer,
        CONSTRAINT #{master_table}_pkey PRIMARY KEY (id)
      )
      WITH (
        OIDS=FALSE
      );
      ALTER TABLE #{master_table} OWNER TO #{@owner};
    COMMANDS
    
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def create_partition_tables
    0.upto(@partition_size - 1) do |p|
      cmd = "CREATE TABLE daily_#{@column}_views_#{p}( ) INHERITS (#{master_table});"
      @conns.each{|conn| conn.exec(cmd)}
    end
  end
  
  def add_indices
    0.upto(@partition_size - 1) do |partition|
      # index_on_article_id_and_date(partition)
      # index_on_writer_id_and_date(partition)
      unless @column == 'page'
        index_on_column(partition)
      else
        index_on_date(partition)
      end
    end
  end
  
  def drop_indices
    0.upto(@partition_size - 1) do |partition|
      index_on_article_id_and_date(partition, true)
      index_on_writer_id_and_date(partition, true)
      unless @column == 'page'
        index_on_column(partition, true)
      else
        index_on_date(partition, true)
      end
    end
  end
  
  def index_on_date(index, drop=false)
    if drop
      cmd = drop_index(index_name)
    else
      cmd = <<-COMMANDS
        CREATE INDEX CONCURRENTLY index_daily_#{@column}_views_#{index}_on_date
          ON daily_#{@column}_views_#{index}
          USING btree
          (date DESC);
      COMMANDS
    end
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def index_on_article_id_and_date(index, drop=false)
    index_name = "index_daily_#{@column}_views_#{index}_on_article_id_n_date"
    
    if drop
      cmd = drop_index(index_name)
    else
      cmd = <<-COMMANDS
        CREATE INDEX #{index_name}
          ON daily_#{@column}_views_#{index}
          USING btree
          (article_id, date DESC);
      COMMANDS
    end
    @conns.each{|conn| conn.exec(cmd)}
  end
    
  def index_on_writer_id_and_date(index, drop=false)
    index_name = "index_daily_#{@column}_views_#{index}_on_writer_id_n_date"
    if drop
      cmd = drop_index(index_name)
    else
      cmd = <<-COMMANDS
        CREATE INDEX #{index_name}
          ON daily_#{@column}_views_#{index}
          USING btree
          (writer_id, date DESC);
      COMMANDS
    end
    @conns.each{|conn| conn.exec(cmd)}
  end

  def index_on_column(index, drop=false)
    index_name = "index_daily_#{@column}_views_#{index}_on_#{@column}"
    if drop
      cmd = drop_index(index_name)
    else
      cmd = <<-COMMANDS
        CREATE INDEX #{index_name}
          ON daily_#{@column}_views_#{index}
          USING btree
          (#{@column});
      COMMANDS
    end
    @conns.each{|conn| conn.exec(cmd)}
  end
    
  def drop_index(index_name)
    <<-COMMANDS
      DROP INDEX IF EXISTS #{index_name};
    COMMANDS
  end
  
  def add_primary_keys
    0.upto(@partition_size - 1) do |partition|
      cmd = <<-COMMANDS
        ALTER TABLE daily_#{@column}_views_#{partition} ADD PRIMARY KEY (id);
      COMMANDS
      @conns.each{|conn| conn.exec(cmd)}
    end    
  end
      
  def drop_tables
    puts "Dropping partitioned tables"
    drop_functions    
    cmd = "Drop TABLE IF EXISTS #{master_table} CASCADE;"
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def drop_functions
    cmd = <<-COMMANDS
      DROP TRIGGER IF EXISTS insert_#{master_table}_trigger on #{master_table};
      DROP TRIGGER IF EXISTS update_#{master_table}_trigger on #{master_table};
      
      DROP FUNCTION IF EXISTS insert_#{master_table}();
      DROP FUNCTION IF EXISTS update_#{master_table}();
    COMMANDS
    puts "Dropping triggers and functions"
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def live_migrate_trigger
    trigger_function = "update_#{master_table}"
    
    cmd = <<-COMMANDS
      CREATE OR REPLACE FUNCTION #{trigger_function}()
      RETURNS TRIGGER AS $$ 
      BEGIN
        DELETE FROM #{master_table} WHERE OLD.id=id; 
        INSERT INTO #{master_table} values(NEW.*); 
        RETURN NULL;
      END; 
      $$ 
      LANGUAGE plpgsql; 
      
      CREATE TRIGGER #{trigger_function}_trigger
        BEFORE UPDATE ON #{master_table}
        FOR EACH ROW EXECUTE PROCEDURE #{trigger_function}();
    COMMANDS
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def live_migrate
    cmd = <<-COMMANDS
      UPDATE #{master_table} SET id=id;      
    COMMANDS
    @conns.each{|conn| conn.exec(cmd)}
  end
  
  def migrate(start_date, end_date)
    unless @column == 'page'
      column = "#{@column},"
    end
    cmd = <<-COMMANDS
      INSERT INTO #{master_table}
      (date, article_id, #{column}count, writer_id)
      SELECT date, article_id, #{column} count, writer_id
      FROM daily_#{@column}_views
      WHERE date BETWEEN '#{start_date}' AND '#{end_date}';
    COMMANDS
    @conns.each{|conn| conn.exec(cmd)}
  end
  
end