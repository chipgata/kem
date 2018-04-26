class Category < Base
    belongs_to :category, :foreign_key => 'parent_id', optional: true
    belongs_to :creater, :class_name => 'User', :foreign_key => 'created_by', optional: true
    belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by', optional: true

    validates :name, presence: true,
                    length: { minimum: 2 }
end
