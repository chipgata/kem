class Setting < Base
    belongs_to :user, :foreign_key => 'created_by', optional: true
    belongs_to :user, :foreign_key => 'updated_by', optional: true

end
