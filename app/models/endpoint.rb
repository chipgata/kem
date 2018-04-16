class Endpoint < Base
    validates :name, presence: true,
                    length: { minimum: 2 }
end
