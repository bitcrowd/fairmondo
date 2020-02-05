#   Copyright (c) 2012-2017, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

class ArticlePolicyTest < ActiveSupport::TestCase
  include ::PunditMatcher
  subject { ArticlePolicy.new(user, article)  }
  let(:article) { create :preview_article }
  let(:cloned) { build :preview_article, original: original_article }
  let(:original_article) { create :locked_article, seller: user }
  let(:user) { nil }

  describe 'for a visitor' do
    it { subject.must_permit(:index)           }

    it { subject.must_ultimately_deny(:new)    }
    it { subject.must_ultimately_deny(:create) }
    it { subject.must_deny(:edit)              }
    it { subject.must_deny(:update)            }
    it { subject.must_deny(:activate)          }
    it { subject.must_deny(:deactivate)        }
    it { subject.must_deny(:report)            }
    it { subject.must_deny(:destroy)           }
    # it { subject.must_deny(:show)              }

    describe 'on an active article' do
      before do
        article.tos_accepted = '1'
        article.activate
      end
      it { subject.must_permit(:show)          }
      it { subject.must_permit(:report)        }
    end
  end

  describe 'for a random logged-in user' do
    let(:user) { create :user }

    it { subject.must_permit(:index)           }
    it { subject.must_permit(:new)             }
    it { subject.must_permit(:create)          }
    it { subject.must_deny(:edit)              }
    it { subject.must_deny(:update)            }
    it { subject.must_deny(:activate)          }
    it { subject.must_deny(:deactivate)        }
    it { subject.must_ultimately_deny(:report) }
    it { subject.must_deny(:destroy)           }

    describe 'on a cloned article' do
      it { ArticlePolicy.new(user, cloned).must_deny(:create) }
    end
  end

  describe 'for the article owning user' do
    let(:user) { article.seller }

    describe 'on all articles' do
      it { subject.must_permit(:index)      }
      it { subject.must_permit(:new)        }
      it { subject.must_permit(:create)     }

      it { subject.must_deny(:report)       }
    end

    describe 'on an active article' do
      before  do
        article.tos_accepted = '1'
        article.activate
      end
      it { subject.must_permit(:deactivate) }
      it { subject.must_permit(:destroy)      }
      it { subject.must_deny(:activate)     }
    end

    describe 'on an inactive article' do
      it { subject.must_deny(:deactivate)   }
      it { subject.must_permit(:activate)   }
      it { subject.must_permit(:destroy)    }
    end

    describe 'on a locked article' do
      before do
        article.tos_accepted = '1'
        article.activate
        article.deactivate
      end
      it { subject.must_deny(:edit)        }
      it { subject.must_deny(:update)      }
      it { subject.must_permit(:destroy)   }
    end

    describe 'on an unlocked article' do
      it { subject.must_permit(:edit)       }
      it { subject.must_permit(:update)     }
      it { subject.must_permit(:destroy)    }
    end

    describe 'on a clone of a locked article' do
      let(:cloned) { build :preview_article, original: original_article, seller: original_article.seller }
      it { ArticlePolicy.new(cloned.seller, cloned).must_permit(:create) }
    end

    describe 'on a clone of an active article' do
      let(:original_article) { create :article, seller: user }
      it { ArticlePolicy.new(cloned.seller, cloned).must_deny(:create) }
    end
  end
end
