set -e

sed -i "s/inherit_from:/# inherit_from:/g" ./.rubocop.yml

set +e

BRANCH_NAME=`git symbolic-ref --short HEAD`
bundle exec rubocop --force-exclusion
  $(git show --name-only HEAD)
if [ $? != 0 ] ; then
  sed -i "s/# inherit_from:/inherit_from:/g" ./.rubocop.yml
  exit 1
else
  sed -i "s/# inherit_from:/inherit_from:/g" ./.rubocop.yml
fi
