class Endpoint < Base
    belongs_to :category
    belongs_to :creater, :class_name => 'User', :foreign_key => 'created_by', optional: true
    belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by', optional: true
    #has_many :settings, through: :creater

    validates :name, presence: true,
                    length: { minimum: 2 }

    after_save :clear_cache

    private
    def clear_cache
        $redis.del "endpoints"
    end
    
end