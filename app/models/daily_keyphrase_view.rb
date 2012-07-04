# == Schema Information
# Schema version: 20110519222312
#
# Table name: daily_keyphrase_views_master
#
#  id           :integer         not null, primary key
#  date         :date
#  article_id   :integer
#  keyphrase    :string(255)
#  count        :integer
#  writer_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#  partition_id :integer
#

class DailyKeyphraseView < ActiveRecord::Base
  belongs_to :article  
  validates_presence_of :date, :article_id, :writer_id, :count
  
  scope :partitioned, lambda {|writer_id| where(:partition_id => writer_id.to_i % PARTITION_SIZE) }
  set_table_name 'daily_keyphrase_views_master'
  
  # Keyphrase Views on and between start_date and end_date
  def self.between(start_date, end_date)
    where(:date => start_date.to_date...(end_date.to_date + 1.day))
    # Note: With "..." range rails generates a sql where clause with 
    # date >= d1, date < d2 so we add an extra day to include today.
  end
  
  # Get the total number of views for each keyphrase for writer_id between start_date and end_date
  # Ordered by total count descending.
  def self.keyphrases_with_total_counts_for_writer_between(writer_id, start_date, end_date, limit, offset)
    keyphrase_counts = DailyKeyphraseView.partitioned(writer_id).where(:writer_id => writer_id).between(start_date, end_date).group("keyphrase").select("keyphrase, SUM(count) as sum_count").order("sum_count desc").limit(limit).offset(offset)
    keyphrase_counts.sum("count").to_a
  end
  
  # Get the total number of views for each keyphrase for an article between start_date and end_date
  # Ordered by total count descending.
  def self.keyphrases_with_total_counts_for_article_between(article_id, start_date, end_date, limit, offset)
    keyphrases = DailyKeyphraseView.between(start_date, end_date).joins(:article) & Article.where(:id => article_id)
    keyphrase_counts = keyphrases.group("keyphrase").select("keyphrase").order("sum_count desc").limit(limit).offset(offset)
    keyphrase_counts.sum("count").to_a
  end
  
end
