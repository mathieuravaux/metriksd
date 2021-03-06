require 'test_helper'
require 'metriksd/librato_metrics_reporter'

class LibratoMetricsReporterTest < Test::Unit::TestCase
  def setup
    @registry = Metriksd::Registry.new(:ignore_current_timeslice => false)
    @reporter = Metriksd::LibratoMetricsReporter.new(@registry, :email => 'x', :api_key => 'y')
    @reporter.client.persistence = :test
  end
  
  def test_empty_flush
    assert !@reporter.flush
  end

  def test_flush
    data = Metriksd::Data.new(:client_id => $$, :time => Time.now.to_i, :type => 'meter', :name => 'b', :source => 'a', :one_minute_rate => 3.4)
    @registry.push(data)

    # There is something to flush the first time
    assert @reporter.flush

    # There is nothing to flush the next time
    assert !@reporter.flush
  end

  def test_start
    @reporter = Metriksd::LibratoMetricsReporter.new(@registry, :email => 'x', :api_key => 'y', :interval => 0.1)
    @reporter.client.persistence = :test

    @reporter.start

    data = Metriksd::Data.new(:client_id => $$, :time => Time.now.to_i, :type => 'meter', :name => 'b', :source => 'a', :one_minute_rate => 3.4)
    @registry.push(data)

    @reporter.stop
    @reporter.join

    assert @reporter.queue.persister.persisted.length == 1, @reporter.queue.persister.persisted.inspect
  end
end
