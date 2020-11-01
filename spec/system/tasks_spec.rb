require 'rails_helper'

RSpec.describe "Tasks", type: :system do

  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do
    describe 'ページ遷移確認' do
      context 'タスクの新規登録ページにアクセス' do
        it '新規作成ページへのアクセスが失敗する' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end

      context 'タスクの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_task_path(task)
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細情報が表示される' do
          visit task_path(task)
          expect(current_path).to eq task_path(task)
          expect(page).to have_content(task.title)
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

    describe 'タスク編集' do
      context 'フォームの入力が正常' do
        it 'タスクの編集が成功する' do
          sign_in_as task.user

          visit edit_task_path(task)
          fill_in 'task_title', with: 'change'
          click_button 'Update Task'

          expect(current_path).to eq task_path(task)
          expect(page).to have_content('Task was successfully updated.')
        end
      end

      context '他ユーザーのタスク編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          task1 = create(:task)
          task2 = create(:task)

          sign_in_as task1.user
          visit edit_task_path(task2)

          expect(current_path).to eq root_path
          expect(page).to have_content('Forbidden access.')
        end
      end
    end

    describe 'タスク削除' do
      it 'タスクの削除が成功する' do
        sign_in_as task.user

        click_link 'Destroy'
        page.accept_confirm
        expect(current_path).to eq tasks_path
        expect(page).to have_content('Task was successfully destroyed.')
      end
    end
  end

end
