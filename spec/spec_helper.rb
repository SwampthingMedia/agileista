# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/autorun'
require 'spec/rails'

require RAILS_ROOT + '/spec/time_spec_helper'
require RAILS_ROOT + '/spec/sexy_objects'

require "#{RAILS_ROOT}/features/support/blueprints"

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  # config.include(ActiveRecordAssociationMatcher)
  # config.include(ActiveRecordValidationMatcher)

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
  def block_should_be_yielded_to
    observer = mock(:block)
    observer.should_receive(:to_be_yielded_to)
    Proc.new do
      observer.to_be_yielded_to
    end
  end

  def block_should_not_be_yielded_to
    observer = mock(:block)
    observer.should_not_receive(:yielded)
    Proc.new do
      observer.yielded
    end
  end
  
  def stub_login_and_account_setup
    @person = TeamMember.new
    @account = Account.new
    @person.account = @account
    session[:user] = 1
    session[:account] = 1
    Person.stub!(:find_by_id_and_account_id).and_return(@person)
  end
  
  def stub_iteration_length_and_create_chart
    controller.stub!(:iteration_length_must_be_specified)
    controller.stub!(:create_chart)
  end
end
