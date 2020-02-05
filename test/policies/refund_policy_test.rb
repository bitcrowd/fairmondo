#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

class RefundPolicyTest < ActiveSupport::TestCase
  include PunditMatcher
  let(:refund) { create :refund }
  subject { RefundPolicy.new(user, refund) }

  describe 'for a visitor' do
    let(:user) { nil }
    it 'should deny refund create for visitors' do
      subject.must_deny(:create)
      subject.must_deny(:new)
    end
  end

  describe 'for a logged in user' do
    describe 'who owns business_transaction' do
      let(:user) { refund.business_transaction_seller }

      describe 'that is sold' do
        describe 'and is not refunded' do
          let(:refund) do
            Refund.new business_transaction:
                         create(:business_transaction, :old)
          end

          it { subject.must_permit(:create) }
          it { subject.must_permit(:new) }
        end

        describe 'and is refunded' do
          it { subject.must_deny(:create) }
          it { subject.must_deny(:new) }
        end
      end
    end

    describe 'who does not own business_transaction' do
      let(:user) { create :user }
      it { subject.must_deny(:create) }
      it { subject.must_deny(:new) }
    end
  end
end
