require 'rails_helper'

RSpec.describe "Tasks", type: :system do

  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do
    describe 'タスク新規作成' do
      context 'ログインしていない状態' do
        it '新規作成ページへのアクセスが失敗する' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end
    end

    describe 'タスク編集' do
      context 'ログインしていない状態' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_task_path(task)
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end
    end
  end

  describe 'ログイン後' do
    describe 'タスク新規作成' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          sign_in_as user

          task = build(:task,
            title: 'Sample title',
            content: 'Sample content',
            status: :doing,
            deadline: 1.week.from_now)

          click_link 'New Task'
          fill_in 'task_title', with: task.title
          fill_in 'task_content', with: task.content
          select 'doing', from: 'Status'
          fill_in 'task_deadline', with: task.deadline
          click_button 'Create Task'

          expect(current_path).to eq '/tasks/1'
          expect(page).to have_content('Task was successfully created.')
          expect(page).to have_content(task.title)
          expect(page).to have_content(task.content)
          expect(page).to have_content(task.status)
          expect(page).to have_content(task.deadline.strftime("%Y/%-m/%-d %-H:%-M"))
        end
      end
    end
  end

end
