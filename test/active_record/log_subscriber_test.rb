require "active_support/log_subscriber/test_helper"
require "test_helper"

class ARecordLogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  def setup
    super
    Widget.create
    RailsLogstasher::ActiveRecord::LogSubscriber.attach_to :active_record
    RailsLogstasher.log_entries[Thread.current] = LogStash::Event.new
    @log_entry = RailsLogstasher.log_entries[Thread.current]
  end

  # TODO
  #def test_schema_statements_are_ignored
  #end

  def test_mandatory_fields_present
    Widget.find(1)
    wait
    assert_present @log_entry.fields['sql']
    assert_present @log_entry.fields['sql'].first['duration']
  end

  def test_sql_fields_present
    Widget.find(1)
    wait

    assert_present sql_entry['name']
    assert_present sql_entry['sql']
    assert sql_entry['duration'].to_f >= 0, "sql_duration was not a positive number"
  end

  def test_basic_query_logging
    Widget.all
    wait

    assert_equal 'Widget Load', sql_entry['name']
    assert_match(/SELECT .*?FROM .?widgets.?/i, sql_entry['sql'])
  end

  def test_exists_query_logging
    Widget.exists? 1
    wait
    assert_equal 'Widget Exists', sql_entry['name']
    assert_match(/SELECT .*?FROM .?widgets.?/i, sql_entry['sql'])
  end


  def test_cached_queries
    ActiveRecord::Base.cache do
      Widget.all
      Widget.all
    end
    wait
    assert_equal 'CACHE', sql_entry['name']
    assert_match(/SELECT .*?FROM .?widgets.?/i, sql_entry['sql'])
  end

=begin
  #TODO Get these done when the new logger is written
  def test_basic_query_doesnt_log_when_level_is_not_debug
    @logger.level = Logger::INFO
    Widget.all
    wait
    assert_blank @log_entry.fields['sql']
  end


  def test_cached_queries_doesnt_log_when_level_is_not_debug
    @logger.level = INFO
    ActiveRecord::Base.cache do
      Widget.all
      Widget.all
    end
    wait
    assert_blank @log_entry.fields['sql']
  end
=end
  private

  def sql_entry
    @sql_entry ||= @log_entry.fields['sql'].last
  end

end
