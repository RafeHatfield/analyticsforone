# == Schema Information
# Schema version: 20110519222312
#
# Table name: daily_domain_views_master
#
#  id           :integer         not null, primary key
#  date         :date
#  article_id   :integer
#  domain       :string(255)
#  count        :integer
#  writer_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#  partition_id :integer
#

class DailyDomainView < ActiveRecord::Base
  belongs_to :article
  
  validates_presence_of :date, :article_id, :writer_id, :count
  
  scope :between, lambda {|start_date, end_date| where(:date => start_date.to_date...(end_date.to_date + 1.day)) }
  scope :partitioned, lambda {|writer_id| where(:partition_id => writer_id.to_i % PARTITION_SIZE) }
  set_table_name 'daily_domain_views_master'
            
  def self.domain_counts_for_writer_between(writer_id, start_date, end_date, limit, offset)
    domain_counts = DailyDomainView.partitioned(writer_id).where(:writer_id => writer_id).between(start_date, end_date).group("domain").select("domain").order("sum_count desc").limit(limit).offset(offset).sum("count")
  end
  
  def self.domain_counts_for_article_between(article_id, start_date, end_date, limit, offset)    
    domain_counts = DailyDomainView.where(:article_id => article_id).between(start_date, end_date).group("domain").select("domain").order("sum_count desc").limit(limit).offset(offset).sum("count")
  end
  
  def self.source_counts_for_writer_between(writer_id, start_date, end_date, limit, offset)
    total_domain_counts = DailyDomainView.domain_counts_for_writer_between(writer_id, start_date, end_date, limit, offset)
    source_counts = total_domain_counts.map {|domain,count| [source_from_domain(domain), count]}
    
    total_source_counts = {:internal => 0, :other => 0, :organic => 0}
    
    source_counts.each do |source_count|
      total_source_counts[source_count[0]] += source_count[1]      
    end
    
    return total_source_counts
  end
  
  def self.source_counts_for_article_between(article_id, start_date, end_date, limit, offset)
    total_domain_counts = DailyDomainView.domain_counts_for_article_between(article_id, start_date, end_date, limit, offset)
    source_counts = total_domain_counts.map {|domain,count| [source_from_domain(domain), count]}
    
    total_source_counts = {:internal => 0, :other => 0, :organic => 0}
    
    source_counts.each do |source_count|
      total_source_counts[source_count[0]] += source_count[1]      
    end
    
    return total_source_counts
  end
  
  private
  
  def self.source_from_domain(domain)
    url = domain.blank? ? "" : "http://#{domain}"
    ReferrerUrl.new(url).source
  end
  
end
