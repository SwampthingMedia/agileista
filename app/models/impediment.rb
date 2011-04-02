class Impediment < ActiveRecord::Base
  validates_presence_of :description
  validates_presence_of :person_id
  validates_presence_of :account_id
  belongs_to :team_member, :class_name => "TeamMember", :foreign_key => "person_id"
  belongs_to :account
  
  named_scope :unresolved, :conditions => {:resolved_at => nil}
  named_scope :resolved, :conditions => "resolved_at IS NOT NULL"
  
  def resolve!
    self.resolved_at = Time.now
    self.save
  end
  
  def to_s
    if status == "Resolved"
      "#{status} at #{resolved_at.strftime('%T %d/%m/%y')}"
    elsif status == "Active"
      "#{status} since #{created_at.strftime('%T %d/%m/%y')}"
    else
      description
    end
  end
  
  protected
  
  def status
    return "New" if self.new_record?
    resolved_at.nil? ? "Active" : "Resolved"
  end
end
