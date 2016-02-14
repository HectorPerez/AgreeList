require 'spec_helper'

feature 'voting', js: true do
  attr_reader :statement

  before do
    seed_data
  end

  context 'logged user' do
    before do
      login
      visit statement_path(statement)
    end

    scenario "agree" do
      click_link "Agree"
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("Who agrees (1)")
    end

    scenario "disagree" do
      click_link "Disagree"
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("Who disagrees (1)")
    end

    scenario 'adds someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'

      click_button "Disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'adds someone who disagrees with its twitter' do
      fill_in 'name', with: "@arpahector"
      click_button "Disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end
  end

  context 'non logged user' do
    before do
      visit statement_path(statement)
    end

    scenario "agree" do
      click_link "Agree"
      click_link "vote-twitter-login"
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("Who agrees (1)")
    end

    scenario "disagree" do
      click_link "Disagree"
      click_link "vote-twitter-login"
      expect(page).to have_content("Hector Perez")
      expect(page).to have_content("Who disagrees (1)")
    end

    scenario 'adds someone who disagrees' do
      fill_in 'name', with: 'Hector Perez'

      click_button "Disagree"
      expect(Agreement.last.disagree?).to eq(true)
    end

    scenario 'comment' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'comment', with: 'Because...'

      click_button "Disagree"
      expect(Agreement.last.reason).to eq "Because..."
    end

    scenario 'bio' do
      fill_in 'name', with: "Hector Perez"
      fill_in 'biography', with: "Hero"
      click_button "Agree"
      expect(page).to have_text('Hero')
    end

    scenario 'should create two users when adding someone else' do
      fill_in 'name', with: 'Hector Perez'
      fill_in 'source', with: 'http://...'
      fill_in 'email', with: 'hhh@jjj.com'

      expect{ click_button "Agree" }.to change{ Individual.count }.by(2)
    end

    scenario 'adds someone who disagrees with its twitter' do
      fill_in 'name', with: "@arpahector"
      click_button "Disagree"
      expect(Individual.last.twitter).to eq "arpahector"
    end

    scenario 'adds two times the same @user' do
      fill_in 'name', with: "@arpahector"
      click_button "Agree"
      fill_in 'name', with: "@arpahector"
      click_button "Agree"
      expect(Individual.count).to eq 1
    end
  end

  private

  def seed_data
    @statement = create(:statement)
  end

  def login
    visit "/auth/twitter"
  end
end
