class Endpoint < Base
    validates :name, presence: true,
                    length: { minimum: 2 }

    after_save do |endpoint|
        TestJob.perform_now endpoint
    end
    
end