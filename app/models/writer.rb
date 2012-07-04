require 'redis/set'
class Writer 
  include Singleton
  attr_accessor :redis, :writer_ids_set
  
  def initialize
    @redis = Redis.new(:host => 'localhost', :port => 6379)
  end
      
  def self.create domain
    case domain
    when :com
      ComWriter.instance
    when :fr
      FrWriter.instance
    when :net
      NetWriter.instance
    when :de
      DeWriter.instance
    else
      raise "unknown domain #{domain}"
    end
  end
           
  def exists?(writer_id)
    @writer_ids_set.member?(writer_id)
  end
  
  def writer_ids
    @writer_ids_set.members
  end
  
  def self.domain_extension(url)
    Addressable::URI.parse(url).host.split('.').last.to_sym
  end
  
end


class ComWriter < Writer
  def initialize
    super
    com_redis = Redis::Namespace.new(:com, :redis => @redis)
    @writer_ids_set  = Redis::Set.new('writer_ids_set', com_redis)
  end
end

class DeWriter < Writer
  def initialize
    super
    de_redis = Redis::Namespace.new(:de, :redis => @redis)
    @writer_ids_set  = Redis::Set.new('writer_ids_set', de_redis)
  end
end

class NetWriter < Writer
  def initialize
    super
    net_redis = Redis::Namespace.new(:net, :redis => @redis)
    @writer_ids_set  = Redis::Set.new('writer_ids_set', net_redis)
  end
end

class FrWriter < Writer
  def initialize
    super
    fr_redis = Redis::Namespace.new(:fr, :redis => @redis)
    @writer_ids_set  = Redis::Set.new('writer_ids_set', fr_redis)
  end
end
