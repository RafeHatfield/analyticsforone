# setup table partition parameters
sql = ActiveRecord::Base.connection();
sql.execute("SET constraint_exclusion = on;") 
PARTITION_SIZE = 41