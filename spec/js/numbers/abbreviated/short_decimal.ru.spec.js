// Copyright 2012 Twitter, Inc
// http://www.apache.org/licenses/LICENSE-2.0


var TwitterCldr = require('../../../../lib/assets/javascripts/twitter_cldr/core.js');
var data = require('../../../../lib/assets/javascripts/twitter_cldr/ru.js');

describe("ShortDecimalFormatter", function() {
  var formatter;
  beforeEach(function() {
    TwitterCldr.set_data(data);
    formatter = new TwitterCldr.ShortDecimalFormatter();
  });

  describe("#format", function() {
    it("formats a number with a literal period in the pattern", function() {
      expect(formatter.format(1000)).toEqual("1 тыс.");
    });
  });
});
