#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

class FeedbackTest < ActiveSupport::TestCase
  subject { Feedback.new }

  describe 'attributes' do
    it { subject.must_respond_to :id }
    it { subject.must_respond_to :from }
    it { subject.must_respond_to :subject }
    it { subject.must_respond_to :text }
    it { subject.must_respond_to :to }
    it { subject.must_respond_to :variety }
    it { subject.must_respond_to :user_id }
    it { subject.must_respond_to :article_id }
    it { subject.must_respond_to :feedback_subject }
    it { subject.must_respond_to :help_subject }
    it { subject.must_respond_to :source_page }
    it { subject.must_respond_to :user_agent }
    it { subject.must_respond_to :forename }
    it { subject.must_respond_to :lastname }
    it { subject.must_respond_to :organisation }
    it { subject.must_respond_to :phone }
    it { subject.must_respond_to :created_at }
    it { subject.must_respond_to :updated_at }
  end

  describe 'associations' do
    it { subject.must belong_to :user }
    it { subject.must belong_to :article }
  end

  describe 'validations' do
    it { subject.must validate_presence_of(:text) }
    it { subject.must validate_presence_of :variety }
    it { subject.wont allow_value('test@').for :from }
    it { subject.wont allow_value('@test.').for :from }
    it { subject.wont allow_value('test.com').for :from }
    it { subject.must allow_value('test@test.museum').for :from }
    it { subject.must allow_value('test@test.co.uk').for :from }

    describe 'when validating send_feedback' do
      before { subject.variety = 'send_feedback' }
      it { subject.must validate_presence_of :feedback_subject }
      it { subject.must validate_presence_of :subject }
    end

    describe 'when validating get_help' do
      before { subject.variety = 'get_help' }
      it { subject.must validate_presence_of :help_subject }
      it { subject.must validate_presence_of :subject }
    end
  end

  describe 'methods' do
    describe '#put_user_id(current_user)' do
      it 'should set the user_id when signed a user is given' do
        user = create :user
        f = Feedback.new
        f.put_user_id user
        f.user_id.must_equal user.id
      end

      it 'should not set the user_id when signed out' do
        f = Feedback.new
        f.put_user_id nil
        assert_nil f.user_id
      end
    end
  end
end
