# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Js
    module Renderers
      module Data
        module Shared
          class LanguagesRenderer < TwitterCldr::Js::Renderers::Base

            def language_data
              TwitterCldr.get_locale_resource(@locale, :languages)[@locale][:languages]
            end

            def rtl_data
              TwitterCldr.supported_locales.inject({}) do |ret, locale|
                ret[locale] = TwitterCldr.get_locale_resource(locale, :layout)[locale][:layout][:orientation][:character_order] == "right-to-left"
                ret
              end
            end

            def get_data
              {
                :Languages => {
                  :all => language_data(),
                  :rtl_data => rtl_data()
                }
              }
            end

          end
        end
      end
    end
  end
end
