require 'test_helper'

module Synapse
  module ProcessManager
    describe CorrelationSet do

      should 'track correlation additions' do
        correlation = Correlation.new :order_id, '512d5467-d319-481e-ab5e-4d6f7445bcff'

        set = CorrelationSet.new
        set.add correlation
        set.add correlation

        assert set.include? correlation
        assert_equal 1, set.count
        assert_equal 1, set.additions.count

        set.commit

        set.delete correlation
        set.add correlation

        assert_equal 1, set.count
        assert_equal 0, set.additions.count
        assert_equal 0, set.deletions.count
      end

      should 'track correlation deletions' do
        correlation = Correlation.new :order_id, '512d5467-d319-481e-ab5e-4d6f7445bcff'

        set = CorrelationSet.new
        set.add correlation
        set.delete correlation

        assert_equal 0, set.count
        assert_equal 0, set.additions.count
        assert_equal 0, set.deletions.count

        set.add correlation
        set.commit

        set.delete correlation
        assert_equal 0, set.count
        assert_equal 1, set.deletions.count
      end

    end
  end
end
