require File.dirname(__FILE__) + '/../spec_helper'

describe Sprint do
  
  before(:each) do
    @it = Sprint.new
    
    # stub out sweepers
    sweeper = mock_model(SprintAuditSweeper)
    sweeper.stub!(:update)
    SprintElement.instance_variable_set(:@observer_peers, [sweeper])
  end
  
  it {should have_many(:sprint_changes)}

  context "auto setting end time" do
    it "should set it on save based on account's iteration length" do
      start = 1.day.from_now
      account = Account.make(:iteration_length => 1)
      sprint = Sprint.create!(:name => "Disco dance prep", :account => account, :start_at => start)
      account.iteration_length.weeks.from_now(1.day.ago(start)).end_of_day.should == sprint.end_at
    end
    
    it "should set it to end of day on subsequent saves" do
      start = 19.days.from_now
      account = Account.make(:iteration_length => 1)
      sprint = Sprint.create!(:name => "Disco dance prep", :account => account, :start_at => start)
      finish = account.iteration_length.weeks.from_now(1.day.ago(start))
      initial_finish = sprint.end_at
      sprint.end_at = finish
      sprint.save!
      sprint.reload
      sprint.end_at.should.to_s == initial_finish.to_s
    end
  end
  
  describe "#velocity" do
    before(:each) do
      us1 = UserStory.new(:story_points => 3)
      us2 = UserStory.new(:story_points => 12)
      us3 = UserStory.new(:story_points => 5)
      us4 = UserStory.new(:story_points => 8)
      us5 = UserStory.new(:story_points => 13)
      us6 = UserStory.new(:story_points => nil)
      us7 = UserStory.new(:story_points => 20)
      us8 = UserStory.new(:story_points => 40)
      
      us1.stub!(:complete?).and_return(true)
      us2.stub!(:complete?).and_return(true)
      us3.stub!(:complete?).and_return(false)
      us4.stub!(:complete?).and_return(true)
      us5.stub!(:complete?).and_return(true)
      us6.stub!(:complete?).and_return(false)
      us7.stub!(:complete?).and_return(true)
      us8.stub!(:complete?).and_return(false)
      
      @sprint = Sprint.new(:name => "sprint a")
      @sprint.stub!(:user_stories).and_return([us1, us2, us3, us4, us5, us6, us7, us8])
      @sprint.start_at = 3.months.ago
      @sprint.end_at = 2.months.ago
      @sprint.stub!(:account_id).and_return(19)
    end
    
    it "should return the total story points for all the complete user stories" do
      @sprint.calculated_velocity.should == 56
      @sprint.velocity.should == 56
    end
  end

  describe "#upcoming?" do
    it "should return true if starts in the future" do
      @it.start_at = 1.weeks.from_now
      @it.end_at = 2.weeks.from_now
      @it.upcoming?.should be_true
    end
    
    it "should return false if already started" do
      @it.start_at = 1.weeks.ago
      @it.end_at = 2.weeks.from_now
      @it.upcoming?.should be_false
    end
    
    it "should return false if already complete" do
      @it.start_at = 2.weeks.ago
      @it.end_at = 1.weeks.ago
      @it.upcoming?.should be_false
    end
  end
  
  describe "#current?" do
    it "should return true if active sprint" do
      @it.start_at = 1.weeks.ago
      @it.end_at = 2.weeks.from_now
      @it.current?.should be_true
    end

    it "should return false if complete" do
      @it.start_at = 2.weeks.ago
      @it.end_at = 1.weeks.ago
      @it.current?.should be_false
    end
    
    it "should return false if upcoming" do
      @it.start_at = 1.weeks.from_now
      @it.end_at = 2.weeks.from_now
      @it.current?.should be_false
    end
  end
  
  describe "#destroy" do
    describe "with user stories" do
      before(:each) do
        @it.name = "Alpha"
        @it.start_at = 1.months.ago
        @it.end_at = 1.months.from_now
        @it.account_id = 8
        @it.save!
        @us1 = @it.user_stories.new(:definition => 'As a wabbit I would like a carrot', :account_id => 8)
        @us2 = @it.user_stories.new(:definition => 'As a carrot I would like to avoid wabbits', :account_id => 8)
        @us1.save!
        @us2.save!
        se = SprintElement.new(:user_story => @us1, :sprint => @it)
        se.save!
        se = SprintElement.new(:user_story => @us2, :sprint => @it)
        se.save!
      end
      
      it "should remove sprint_id reference" do
        UserStory.find_all_by_sprint_id(@it.id).length.should == 2
        @it.destroy
        UserStory.find_all_by_sprint_id(@it.id).should be_blank
      end
      
      it "should remove sprint_elements" do
        SprintElement.count.should == 2
        @it.destroy
        SprintElement.count.should == 0
      end
    end
  end
  
  describe "named_scope(s)" do
    describe "current" do
      it "should correctly generate conditions for current sprint" do
        Timecop.freeze do
          Sprint.current.proxy_options.should == {:conditions => ["start_at < ? AND end_at > ?", Time.now, 1.days.ago]}
        end
      end
    end
  end
end