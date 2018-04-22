class Endpoint < Base
    belongs_to :category
    belongs_to :user, :foreign_key => 'created_by', optional: true
    belongs_to :user, :foreign_key => 'updated_by', optional: true

    validates :name, presence: true,
                    length: { minimum: 2 }

    after_save :clear_cache

    private
    def clear_cache
        $redis.del "endpoints"
    end
    
end