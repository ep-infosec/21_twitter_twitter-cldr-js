# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Js
    module Renderers
      module Data
        module Shared
          class CalendarRenderer < TwitterCldr::Js::Renderers::Base

            def calendar
              TwitterCldr::DataReaders::CalendarDataReader.new(@locale).calendar.calendar_data
            end

            def get_data
              {
                :Calendar => {
                  :calendar => calendar()
                }
              }
            end

          end
        end
      end
    end
  end
end
