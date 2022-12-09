# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Js
    module Renderers
      module Implementation
        module Tokenizers

          class NumberTokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/numbers/number_tokenizer.coffee"
          end

          class RBNFTokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/numbers/rbnf_tokenizer.coffee"
          end

          class UnicodeRegexTokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/unicode_regex/unicode_regex_tokenizer.coffee"
          end

          class CompositeTokenRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/composite_token.coffee"
          end

          class PatternTokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/pattern_tokenizer.coffee"
          end

          class SegmentationTokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/segmentation_tokenizer.coffee"
          end

          class TokenRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/token.coffee"
          end

          class TokenizerRenderer < TwitterCldr::Js::Renderers::Base
            set_template "mustache/implementation/tokenizers/tokenizer.coffee"
          end

        end
      end
    end
  end
end
