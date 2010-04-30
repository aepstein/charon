Time::DATE_FORMATS[:us_ordinal] = lambda { |time| time.strftime "%B #{ActiveSupport::Inflector.ordinalize time.day}, %Y %I:%M%P	" }

