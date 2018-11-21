require 'test_helper.rb'

module Query
  class TransactionsToBeBilledTest < ActiveSupport::TestCase
    def setup
      @regime = regimes(:cfd)
      @user = users(:billing_admin)
    end

    def test_returns_unbilled_transactions
      assert @regime.transaction_details.unbilled.count.positive?

      transactions = TransactionsToBeBilled.call(regime: @regime)
      assert_equal @regime.transaction_details.unbilled, transactions
    end
  end
end