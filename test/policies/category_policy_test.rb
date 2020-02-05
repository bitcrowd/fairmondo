#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

class CategoryPolicyTest < ActiveSupport::TestCase
  include PunditMatcher

  it { subject.must_permit(:select_category) }
  it { subject.must_permit(:show) }
end
