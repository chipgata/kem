class Endpoint < Base
    belongs_to :category

    validates :name, presence: true,
                    length: { minimum: 2 }

    after_save :clear_cache

    private
    def clear_cache
        $redis.del "endpoints"
    end
    
end