class Endpoint < Base
    belongs_to :category
    belongs_to :creater, :class_name => 'User', :foreign_key => 'created_by', optional: true
    belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by', optional: true
    #has_many :settings, through: :creater

    validates :name, presence: true,
                    length: { minimum: 2 }
    validates :port, :response_timeout, :check_interval, :unhealthy_threshold, :healthy_threshold, presence: true, numericality: { only_integer: true }
    validates :path, :response_timeout, :check_interval, :unhealthy_threshold, :healthy_threshold, :check_protocol, :status, presence: true
    
    after_save :clear_cache
    after_destroy :clear_check, :clear_cache
    
    def clear_cache
        $redis.del "endpoints"
    end

    def clear_check
        $redis.del "endpoint_check:#{self.id}"
        $redis.srem "fail_check_endpoints", self.id
    end

    private :clear_cache, :clear_check
    
end