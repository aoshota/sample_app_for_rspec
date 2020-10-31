require 'rails_helper'

RSpec.describe "Users", type: :system do

  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe 'ログイン前' do

    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          visit sign_up_path
          fill_in 'user_email', with: 'test@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'SignUp'
          expect(current_path).to eq login_path
          expect(page).to have_content('User was successfully created.')
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'SignUp'
          expect(current_path).to eq '/users'
          expect(page).to have_content("Email can't be blank")
        end
      end

      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          fill_in 'user_email', with: 'test@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'SignUp'

          # 同じメールアドレスでユーザーの新規作成
          visit sign_up_path
          fill_in 'user_email', with: 'test@example.com'
          fill_in 'user_password', with: 'password'
          fill_in 'user_password_confirmation', with: 'password'
          click_button 'SignUp'

          expect(current_path).to eq '/users'
          expect(page).to have_content('Email has already been taken')
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit '/users/1'
          expect(current_path).to eq login_path
          expect(page).to have_content('Login required')
        end
      end
    end
  end

  describe 'ログイン後' do
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          sign_in_as user
          click_link 'Mypage'
          click_link 'Edit'
          fill_in 'user_email', with: 'change@example.com'
          click_button 'Update'

          expect(current_path).to eq user_path(user)
          expect(page).to have_content('User was successfully updated.')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          sign_in_as user
          click_link 'Mypage'
          click_link 'Edit'
          fill_in 'user_email', with: nil
          click_button 'Update'

          expect(current_path).to eq user_path(user)
          expect(page).to have_content("Email can't be blank")
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          create(:user, email: 'test@example.com')
          sign_in_as user
          click_link 'Mypage'
          click_link 'Edit'
          fill_in 'user_email', with: 'test@example.com'
          click_button 'Update'

          expect(current_path).to eq user_path(user)
          expect(page).to have_content('Email has already been taken')
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          user1 = create(:user)
          user2 = create(:user)

          sign_in_as user1
          # ログインしていないuser2の編集ページへアクセス
          visit "/users/#{user2.id}/edit"

          expect(current_path).to eq user_path(user1)
          expect(page).to have_content('Forbidden access.')
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
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
