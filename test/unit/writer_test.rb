require 'test_helper'

class WriterTest < ActiveSupport::TestCase
  context "on inserting writer ids" do
    
    setup do
      @writer = Writer.create(:com)
      @writer.writer_ids_set << '12345'
      @writer.writer_ids_set << '23456'
    end
    
    should "return if a given writer id exists" do
      assert @writer.exists?('12345')
      assert @writer.exists?('23456')
    end
        
  end
  
end