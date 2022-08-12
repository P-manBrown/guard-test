set -eu

# GitHub Packages への認証
bundle config https://rubygems.pkg.github.com/P-manBrown \
    $(cat ./docker/api/github-pkg-cred.txt)

# Solargraphの設定
## Rails 対応
cat ./.git/info/exclude | grep -q solargraph \
|| echo -e '/.solargraph.yml\n/config/solargraph.rb' \
    >> ./.git/info/exclude
cp -u ./.devcontainer/solargraph/.solargraph.yml \
      ./
mkdir -p ./config/
cp -u ./.devcontainer/solargraph/solargraph.rb \
      ./config/
## Gemのドキュメント生成
yard gems

# Lefthookの設定
lefthook install
