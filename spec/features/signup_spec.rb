require 'rails_helper'

RSpec.feature 'Signup process', type: :feature do

  it "signs me up" do
    visit '/people/sign_up'
    fill_in 'Name', :with => 'Levent Ali'
    fill_in 'Email', :with => 'lebreeze@gmail.com'
    fill_in 'person_password', :with => 'pa55word'
    fill_in 'Password confirmation', :with => 'pa55word'
    click_button 'Sign up'
    expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please open the link to activate your account.'
  end
end
