class Endpoint < Base
    belongs_to :category
    belongs_to :creater, :class_name => 'User', :foreign_key => 'created_by', optional: true
    belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by', optional: true
    #has_many :settings, through: :creater

    validates :name, presence: true,
                    length: { minimum: 2 }
    validates :response_timeout, :check_interval, :unhealthy_threshold, :healthy_threshold, numericality: { only_integer: true }
    validates :path, :port, :response_timeout, :check_interval, :unhealthy_threshold, :healthy_threshold, :check_protocol, :status, presence: true
    
    before_validation :default_values 
    after_save  :clear_cache
    after_destroy :clear_check, :clear_cache
    
    def clear_cache
        $redis.del "endpoints"
    end

    def clear_check
        $redis.del "endpoint_check:#{self.id}"
        $redis.srem "fail_check_endpoints", self.id
    end

    def default_values
        self.response_timeout ||= 10 
        self.check_interval   ||= 60
        self.unhealthy_threshold ||= 2
        self.healthy_threshold ||= 3
        if self.check_protocol == 'http' or self.check_protocol == 'https'
            if self.check_extend['http_code_expect'].to_i == 0
                self.check_extend = {"http_code_expect" => 200}
            else
                self.check_extend = {"http_code_expect" => self.check_extend['http_code_expect'].to_i}
            end
        end
    end

    private :clear_cache, :clear_check, :default_values
    
end