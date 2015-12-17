#!/bin/bash
#
# @file bzr2git.sh
#
# Shell script to convert bzr repo to git. Requires the bzr fastimport module.
#
#
# Usage: bz2git.sh ["$clientname" "$projectname"]
#			without params it will just convert to git	
#			with params it will convert, make new repo, and push to github repo	
#
# @author cdjames 2015-12-17 with help from 
# http://stackoverflow.com/questions/2423777/is-it-possible-to-create-a-remote-repo-on-github-from-the-cli-without-ssh
# @modifying bzr2git.sh by programming@dbswebsite.com 2012-11-13
#
# LICENSE
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

# sanity checks
if [ ! -d .bzr ]
then
	echo "Is this a bzr repo or not?"
	exit 1
fi

# normalize $client. TODO
#client=$(echo "$1" |  sed  -e 's/ /-/g' |tolower.sh)
#project=$(echo "$2" |  sed  -e 's/ /-/g' |tolower.sh)

echo starting git conversion, making sure bzr is up to date ....
# make sure all the bzr stuff is up to date & committed
bzr update
#bzr add
#bzr commit -m 'Final bzr commit, if needed ...'

# git does not handle empty directories (bzr does)
find -type d -empty -exec touch {}/.ignore \;

# starting git import
git init

# if bzrignore, copy it to gitignore
if [ -e .bzrignore ]
then 
	cp .bzrignore .gitignore
fi

# do actual export and import
bzr fast-export --plain . | git fast-import
# remove traces of bzr
#rm -rfv .bzr*
# git add .
git checkout -f master
# git commit -m "Converting to git"  
 
echo
echo "Conversion complete."

# only do if you have username and project name
if [ "$2" ]
then
	echo "Is github.com/$1 ready for new repo? Are we good to go for a push? Ctrl-c to cancel push"
	read

	echo "Creating repo on github and pushing code..."

	curl -u "$1" https://api.github.com/user/repos -d "{\"name\":\"$2\"}"
	if [ ! -d .git ]
	then
		git init
	fi
	git remote add origin git@github.com:$1/$2.git
	git push origin master

	echo
	echo "Repo is on github. Please confirm."
fi
