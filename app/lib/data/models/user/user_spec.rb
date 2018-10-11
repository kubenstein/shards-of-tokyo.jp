describe SoT::User do
  let(:user_repo) { APP_COMPONENTS[:user_repository] }

  it 'properly report itself as Me' do
    expect(user_repo.new_user(email: 'test@test.pl').me?).to eq false
    expect(user_repo.new_user(email: SoT::User::ME_EMAIL).me?).to eq true
  end
end
