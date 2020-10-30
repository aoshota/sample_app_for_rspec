require 'rails_helper'

RSpec.describe Task, type: :model do

  let(:user) { FactoryBot.create(:user) }
  let(:task) { FactoryBot.create(:task) }

  describe 'バリデーションは' do
    it '全ての属性が有効であること' do
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'タイトルがなければ無効であること' do
      task.title = nil
      expect(task).to_not be_valid
      expect(task.errors[:title]).to eq ["can't be blank"]
    end

    it '状態がなければ無効であること' do
      task.status = nil
      expect(task).to_not be_valid
      expect(task.errors[:status]).to eq ["can't be blank"]
    end

    it '重複したタイトルならば無効であること' do
      task = FactoryBot.create(:task, user: user, title: "Same Title")
      other_task = FactoryBot.build(:task, user: user, title: "Same Title")
      expect(other_task).to_not be_valid
      expect(other_task.errors[:title]).to eq ["has already been taken"]
    end

    it '別のタイトルならば有効であること' do
      task = FactoryBot.create(:task, user: user, title: "Same Title")
      other_task = FactoryBot.build(:task, user: user, title: "Another Title")
      expect(other_task).to be_valid
      expect(other_task.errors).to be_empty
    end
  end
end
