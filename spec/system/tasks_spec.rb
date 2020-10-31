require 'rails_helper'

RSpec.describe "Users", type: :system do

  let(:user) { create(:user) }

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
        it '新規作成したタスクが表示される'
      end
    end
  end
end

RSpec.describe "UserSessions", type: :system do

  let(:user) { create(:user) }

  describe 'ログイン前' do
    context 'フォームの入力値が正常' do
      it 'ログイン処理が成功する' do
        sign_in_as user
        expect(current_path).to eq root_path
        expect(page).to have_content('Login successful')
      end
    end
    context 'フォームが未入力' do
      it 'ログイン処理が失敗する' do
        visit login_path
        click_button 'Login'
        expect(current_path).to eq login_path
        expect(page).to have_content('Login failed')
      end
    end
  end

  describe 'ログイン後' do
    context 'ログアウトボタンをクリック' do
      it 'ログアウト処理が成功する' do
        sign_in_as user
        click_link 'Logout'
        expect(current_path).to eq root_path
        expect(page).to have_content('Logged out')
      end
    end
  end
end
