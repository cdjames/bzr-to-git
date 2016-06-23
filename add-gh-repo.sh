#!/bin/bash
#
# @file bzr2git.sh
#
# Shell script to add a new repository on github.com from a local git profile.
#
#
# Usage: add-gh-repo.sh ["$clientname" "$projectname" ["$description"]]
#			it will make new repo and push to github repo	
#
# @author cdjames 2015-12-24 with help from 
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

# check for git folder
if [ ! -d .git ]
then
	echo "No git repo found; add one before continuing."
	exit 1
fi

# only do if you have username AND project name (and/or description)
if [ "$2" ]
then
	echo "Is github.com/$1 ready for new repo called $2? Are we good to go for a push? Ctrl-c to cancel push"
	read

	echo "Creating new repo on github and pushing code..."
	# if there is also a description, create a new folder
	if [ "$3" ]
	then
		curl -u "$1" https://api.github.com/user/repos -d "{\"name\":\"$2\",\"description\":\"$3\"}"
	else
		curl -u "$1" https://api.github.com/user/repos -d "{\"name\":\"$2\"}"
	fi

	if [ ! -d .git ]
	then
		git init
	fi
	# add local files to github folder
	git remote add origin https://github.com/$1/$2.git
	git push origin master

	echo
	echo "Repo is on github. Please confirm."
	git remote -v
else 
	echo "You need to specify a name for the new repository, and optionally a description."
fi
