class Category < Base
    validates :name, presence: true,
                    length: { minimum: 5 }
end
