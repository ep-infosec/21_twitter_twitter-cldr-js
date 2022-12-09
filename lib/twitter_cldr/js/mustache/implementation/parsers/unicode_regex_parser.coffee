# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

class TwitterCldr.UnicodeRegexParser extends TwitterCldr.Parser

  constructor : ->
    # Types that are allowed to be used in character ranges.
    @character_class_token_types = [
      "variable", "character_set", "negated_character_set", "unicode_char",
      "multichar_string", "string", "escaped_character", "character_range"
    ]

    @negated_token_types = [
      "negated_character_set"
    ]

    @binary_operators = [
      "pipe", "ampersand", "dash", "union"
    ]

    @unary_operators = [
      "negate"
    ]

  parse : (tokens, options = {}) ->
    super(@preprocess(@substitute_variables(tokens, options.symbol_table)), options)

  make_token : (type, value) ->
    new TwitterCldr.Token ({"type": type, "value" : value})

  # Identifies regex ranges and makes implicit operators explicit
  preprocess : (tokens) ->
    result = []
    i = 0

    while i < tokens.length
      # Character class entities side-by-side are treated as unions. So
      # are side-by-side character classes. Add a special placeholder token
      # to help out the expression parser.
      add_union = (@is_valid_character_class_token(result[result.length-1]) and tokens[i].type != "close_bracket") ||
            (result[result.length-1]? and result[result.length-1].type == "close_bracket" and tokens[i].type == "open_bracket")
      result.push(@make_token("union")) if add_union

      is_range = @is_valid_character_class_token(tokens[i]) and
            @is_valid_character_class_token(tokens[i + 2]) and
            tokens[i + 1].type == "dash"
      if is_range
        initial = @[tokens[i].type](tokens[i])
        final = @[tokens[i+2].type](tokens[i+2])
        result.push(@make_character_range(initial, final))
        i += 3
      else
        if @is_negated_token(tokens[i])
          result = result.concat [
            @make_token("open_bracket")
            @make_token("negate")
            tokens[i]
            @make_token("close_bracket")
          ]
        else
          result.push(tokens[i])

        i += 1

    result

  substitute_variables : (tokens, symbol_table) ->
    return tokens unless symbol_table?

    result = []
    for i in [0...tokens.length] by 1
      token = tokens[i]
      if token.type == "variable" and (sub = symbol_table.fetch(token.value))?
        # variables can themselves contain references to other variables
        # note: this could be cached somehow
        result = result.concat(@substitute_variables(sub, symbol_table))
      else
        result.push token

    result

  make_character_range : (initial, final) ->
    new TwitterCldr.CharacterRange(initial, final)

  is_negated_token : (token) ->
    token? and token.type in @negated_token_types

  is_valid_character_class_token : (token) ->
    token? and token.type in @character_class_token_types

  is_unary_operator : (token) ->
    token? and token.type in @unary_operators

  is_binary_operator : (token) ->
    token? and token.type in @binary_operators

  do_parse : (options) ->
    elements = []
    while @current_token()
      switch @current_token().type
        when "open_bracket"
          elements.push(@character_class())
        when "union"
          @next_token("union")
        else
          elements.push (@[@current_token().type](@current_token()))
          @next_token(@current_token().type)
    elements

  character_set : (token) ->
    new TwitterCldr.CharacterSet(token.value.replace(/^\\p/g, "").replace(/[\{\}\[\]:]/g, ""))

  negated_character_set : (token) ->
    new TwitterCldr.CharacterSet(token.value.replace(/^\\[pP]/g, "").replace(/[\{\}\[\]:^]/g, ""))

  unicode_char : (token) ->
    new TwitterCldr.UnicodeString([parseInt(token.value.replace(/^\\u/g, "").replace(/[\{\}]/g, ""), 16)])

  string : (token) ->
    new TwitterCldr.UnicodeString(TwitterCldr.Utilities.unpack_string(token.value))

  multichar_string : (token) ->
    new TwitterCldr.UnicodeString(TwitterCldr.Utilities.unpack_string(token.value.replace(/[\{\}]/g, "")))

  escaped_character : (token) ->
    new TwitterCldr.Literal(token.value)

  special_char : (token) ->
    new TwitterCldr.Literal(token.value)

  negate : (token) ->
    @special_char(token)

  pipe : (token) ->
    @special_char(token)

  ampersand : (token) ->
    @special_char(token)


  # current_token is already a CharacterRange object
  character_range : (token) ->
    token

  character_class : ->
    operator_stack = []
    operand_stack = []
    open_count = 0

    while true
      if @current_token().type in TwitterCldr.CharacterClass.closing_types()
        last_operator = @peek(operator_stack)
        open_count -= 1
        while last_operator.type isnt TwitterCldr.CharacterClass.opening_type_for(@current_token().type)
          operator = operator_stack.pop()
          node = if @is_unary_operator(operator)
            @unary_operator_node(operator.type, operand_stack.pop())
          else
            @binary_operator_node(operator.type, operand_stack.pop(), operand_stack.pop())

          operand_stack.push(node)
          last_operator = @peek(operator_stack)

        operator_stack.pop()

      else if @current_token().type in TwitterCldr.CharacterClass.opening_types()
        open_count += 1
        operator_stack.push(@current_token())

      else if @current_token().type in @unary_operators.concat(@binary_operators)
        operator_stack.push(@current_token())

      else
        operand_stack.push(@[@current_token().type](@current_token()))

      @next_token(@current_token().type)

      break if operator_stack.length is 0 and open_count is 0

    new TwitterCldr.CharacterClass(operand_stack.pop())

  peek : (array) ->
    array[array.length-1]

  binary_operator_node : (operator, right, left) ->
    new TwitterCldr.CharacterClass.BinaryOperator(operator, left, right)

  unary_operator_node : (operator, child) ->
    new TwitterCldr.CharacterClass.UnaryOperator(operator, child)
