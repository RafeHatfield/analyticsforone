# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110906222837) do

  create_table "article_votes", :force => true do |t|
    t.integer  "article_id"
    t.date     "date"
    t.text     "note"
    t.boolean  "vote"
    t.integer  "writer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.string   "title"
    t.integer  "writer_id"
    t.string   "permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["id"], :name => "uniq_article_check", :unique => true
  add_index "articles", ["writer_id"], :name => "index_articles_on_writer_id"

  create_table "daily_domain_views", :force => true do |t|
    t.date     "date"
    t.integer  "article_id"
    t.string   "domain"
    t.integer  "count"
    t.integer  "writer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_domain_views", ["article_id"], :name => "index_daily_domain_views_on_article_id"
  add_index "daily_domain_views", ["writer_id"], :name => "index_daily_domain_views_on_writer_id"

  create_table "daily_keyphrase_views", :force => true do |t|
    t.date     "date"
    t.integer  "article_id"
    t.string   "keyphrase"
    t.integer  "count"
    t.integer  "writer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_keyphrase_views", ["article_id"], :name => "index_daily_keyphrase_views_on_article_id"
  add_index "daily_keyphrase_views", ["writer_id"], :name => "index_daily_keyphrase_views_on_writer_id"

  create_table "daily_page_views", :force => true do |t|
    t.date     "date"
    t.integer  "article_id"
    t.integer  "count"
    t.integer  "writer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_page_views", ["article_id"], :name => "index_daily_page_views_on_article_id"
  add_index "daily_page_views", ["writer_id"], :name => "index_daily_page_views_on_writer_id"

  create_table "daily_total_views", :force => true do |t|
    t.integer  "total_views"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_total_views", ["date"], :name => "index_daily_total_views_on_date", :unique => true

  create_table "raw_page_views", :force => true do |t|
    t.integer  "article_id"
    t.string   "permalink"
    t.string   "title"
    t.integer  "writer_id"
    t.string   "referrer_url", :limit => 1000
    t.string   "cookie_id"
    t.datetime "date"
  end

  add_index "raw_page_views", ["article_id"], :name => "index_raw_page_views_on_article_id"
  add_index "raw_page_views", ["cookie_id"], :name => "index_raw_page_views_on_cookie_id"
  add_index "raw_page_views", ["writer_id"], :name => "index_raw_page_views_on_writer_id"

end
