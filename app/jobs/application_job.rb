class ApplicationJob < ActiveJob::Base
    def set_check_info(endpoint_id, check_info)
        $redis.set "endpoint_check:" + endpoint_id.to_s, check_info.to_json
        #$redis.expire "endpoint_check:" + endpoint_id.to_s, 1800
    end

    private :set_check_info
end
