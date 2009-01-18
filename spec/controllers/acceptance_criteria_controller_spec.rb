require File.dirname(__FILE__) + '/../spec_helper'

describe AcceptanceCriteriaController do
  before(:each) do
    request.env["HTTP_REFERER"] = "http://test.host"
  end
  
  it "should be an abstract_security_controller" do
    controller.is_a?(AbstractSecurityController).should be_true
  end
  
  describe 'before_filters' do
    before(:each) do
      stub_login_and_account_setup
      @user_story = UserStory.new
      @acceptance_criterion = AcceptanceCriterium.new
    end
    
    AcceptanceCriteriaController.instance_methods(false).each do |action|
      it "should only allow team members on '#{action}" do
        controller.should_receive(:must_be_team_member).and_return(false)
        get action.to_sym
      end
    end
    
    # Still some legacy actions
    # TasksController.instance_methods(false).each do |action|
    %w(update destroy create).each do |action|
      it "should set_user_story on '#{action}'" do
        controller.stub!(:must_be_team_member).and_return(true)
        controller.should_receive(:set_user_story).and_return(@user_story)
        controller.stub!(:set_acceptance_criterion)
        get action.to_sym
      end
    end
    
    %w(update destroy).each do |action|
      it "should set_acceptance_criterion on '#{action}'" do
        controller.stub!(:must_be_team_member).and_return(true)
        controller.stub!(:set_user_story)
        controller.should_receive(:set_acceptance_criterion)
        get action.to_sym
      end
    end
  end

  describe 'create' do
    before(:each) do
      stub_login_and_account_setup
      @user_story = UserStory.new
      @acceptance_criterion = AcceptanceCriterium.new
      @user_story.stub!(:id).and_return(1)
      @user_story.stub!(:sprint_id).and_return(1)
      @account.user_stories.should_receive(:find).and_return(@user_story)
    end
    
    it "should create acceptance criterium and render partial" do
      @user_story.acceptance_criteria.should_receive(:new).with('hash').and_return(@acceptance_criterion)
      @acceptance_criterion.should_receive(:save).and_return(true)
      controller.expect_render(:partial => 'user_stories/acceptance_criteria')
      post :create, :acceptance_criterion => 'hash'
    end
  end
  
  describe 'destroy' do
    before(:each) do
      stub_login_and_account_setup
      @user_story = UserStory.new
      @acceptance_criterion = AcceptanceCriterium.new
      @user_story.stub!(:id).and_return(1)
      @user_story.stub!(:sprint_id).and_return(1)
      @account.user_stories.should_receive(:find).and_return(@user_story)
      @user_story.acceptance_criteria.stub!(:find).and_return(@acceptance_criterion)
    end
    
    it "should find the acceptance criterion" do
      @user_story.acceptance_criteria.should_receive(:find).with("17").and_return(@acceptance_criterion)
      delete :destroy, :user_story_id => "23", :id => "17"
    end
    
    it "should destroy acceptance criterion and render partial" do
      @acceptance_criterion.should_receive(:destroy)
      controller.expect_render(:partial => 'user_stories/acceptance_criteria')
      delete :destroy, :user_story_id => "23", :id => "17"
    end
  end
  # 
  # describe 'update' do
  #   before(:each) do
  #     stub_login_and_account_setup
  #     @user_story = UserStory.new
  #     @task = Task.new
  #     @user_story.stub!(:id).and_return(1)
  #     @task.stub!(:id).and_return(1)
  #     @account.user_stories.should_receive(:find).and_return(@user_story)
  #     @user_story.tasks.should_receive(:find).and_return(@task)
  #   end
  #   
  #   it "should update task and redirect on success" do
  #     @task.should_receive(:update_attributes).with('hash').and_return(true)
  #     put :update, :task => 'hash'
  #     response.should be_redirect
  #     response.should redirect_to('http://test.host/user_stories/1/tasks/1')
  #   end
  #   
  #   it "should update task and redirect to taskboard on success with parameter" do
  #     sprint = Sprint.new
  #     sprint.stub!(:id).and_return(123)
  #     @account.sprints.should_receive(:current).and_return([sprint])
  #     @task.should_receive(:update_attributes).with('hash').and_return(true)
  #     put :update, :task => 'hash', :from => 'tb'
  #     response.should be_redirect
  #     response.should redirect_to('http://test.host/sprints/123')
  #   end
  #   
  #   it "should update task and redirect on fail" do
  #     @task.should_receive(:update_attributes).with('hash').and_return(false)
  #     controller.expect_render(:action => 'edit')
  #     put :update, :task => 'hash'
  #   end
  # end
  # 
  # describe 'new' do
  #   before(:each) do
  #     stub_login_and_account_setup
  #     @user_story = UserStory.new
  #     @task = Task.new
  #     @user_story.stub!(:id).and_return(1)
  #     @task.stub!(:id).and_return(1)
  #     @account.user_stories.should_receive(:find).and_return(@user_story)
  #     # @user_story.tasks.should_receive(:find).and_return(@task)
  #   end
  # 
  #   it "should instantiate object" do
  #     @user_story.tasks.should_receive(:new).and_return(@task)
  #     get :new
  #     assigns(:task).should == @task
  #   end
  # end
  # 
  # describe "route recognition" do
  #   it "should generate params from POST /sprints correctly" do
  #     params_from(:post, '/user_stories/8/tasks').should == {:controller => 'tasks', :action => 'create', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from GET /tasks correctly" do
  #     params_from(:get, '/user_stories/8/tasks').should == {:controller => 'tasks', :action => 'index', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from POST /tasks/7/claim correctly" do
  #     params_from(:post, '/user_stories/8/tasks/7/claim').should == {:controller => 'tasks', :action => 'claim', :id => '7', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from POST /tasks/7/release correctly" do
  #     params_from(:post, '/user_stories/8/tasks/7/release').should == {:controller => 'tasks', :action => 'release', :id => '7', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from POST /tasks/7/move_up correctly" do
  #     params_from(:post, '/user_stories/8/tasks/7/move_up').should == {:controller => 'tasks', :action => 'move_up', :id => '7', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from POST /tasks/7/move_down correctly" do
  #     params_from(:post, '/user_stories/8/tasks/7/move_down').should == {:controller => 'tasks', :action => 'move_down', :id => '7', :user_story_id => '8'}
  #   end
  #   
  #   it "should generate params from DELETE /tasks/7 correctly" do
  #     params_from(:delete, '/user_stories/8/tasks/7').should == {:controller => 'tasks', :action => 'destroy', :id => '7', :user_story_id => '8'}
  #   end
  # end
end