require File.join(File.dirname(__FILE__), '../test_helper.rb')

class StringTest < Test::Unit::TestCase
  def test_should_extract_multiple_net_ids_that_are_comma_separated
    assert_equal ['ate2','aro4'], "ate2,aro4".to_net_ids
  end

  def test_should_extract_multiple_net_ids_that_are_slash_separated
    assert_equal ['abc1','def2'], "abc1/def2".to_net_ids
  end

  def test_should_extract_multiple_net_ids_that_are_space_separated
    assert_equal ['abc1','def2'], "abc1 def2".to_net_ids
  end

  def test_should_extract_multiple_net_ids_that_are_semi_colon_separated
    assert_equal ['abc1','def2'], "abc1;def2".to_net_ids
  end

  def test_should_extract_a_net_id_from_a_cornell_email_address
    assert_equal ['abc1'], "abc1@cornell.edu".to_net_ids
  end

  def test_should_not_extract_a_net_id_from_a_non_cornell_email_address
    assert_equal [], "abc1@other.com".to_net_ids
  end
end