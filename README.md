LICENSE
=======
All scripts here are released uder the BSD 2-Clause open license (http://opensource.org/licenses/BSD-2-Clause).
It basically says that you can do whatever you like with the code as long as you credit the author and provide the license with it.
Also see LICENSE in the repo.

Support
=======
I do not promise any support for any of the provided scripts. That said, I'll do what I can for you if I'm not too busy and/or drunk.

General information
===================
The paths are all configurable of course.
The help information that the scripts give is dynamic and is provided here only for reference.

Scripts
=======

gb
--

Gelbooru/Danbooru tag browser/downloader script.

Danbooru requires you to log in to use the API, so gb supports authorization and using your username and/or password hash from a configuration file:

	$ cat ~/.gbrc
	danbooru_username='myusername'
	danbooru_pwhash='mypwhash'

It is, for obvious reasons, not recommended to store your hash in a file that is readable by anyone except you:
	$ chmod 600 ~/.gbrc

sup
---
A simple file upload script for [ZFH](https://zfh.so)

	Usage: /home/fbt/bin/sup [-c title] [-t tags] [-RsF] [-D num] [file/url]
		-c          Comment/title (deprecated, optional)
		-t          File tags
		-R          Set to remove file after uploading (local fs only, obviously)
		-s          Grab a screenshot to upload instead of a file/url
		-F          Make a fullscreen shot instead of a selected window/area
		-D [num]    Delay the screenshot for [num] seconds
		-h          Show this message

aur
---
Yet another AUR wrapper

	$ aur -h
	/home/fbt/bin/aur [options] [package]

	SYNC (-S):
	-s     Search for a package.
	-i     Install a package after building it.
	-d     Download a package and don't build it. Implies no -i.

	OTHER:
	-h     Show this message

ait
---
Arch Install Tool: a simple install script for Arch Linux.
Since AIF is considered obsolete and is not included in the new install images, I've used this as an excuse to write another shitty script. What's the killer
feature? Well, it can install openrc and confugure it for you somewhat. It even adds a bootloader entry :3

It makes more sense to download it from the livecd:

	# dhcpcd
	# wget zfh.so/ait.sh
	# bash ait.sh

scotch
------
A wine helper designed mostly for games and apps that need specific configuration that potentially conflicts with others.

	$ scotch -h
	Scotch — a wine helper script
	Usage: scotch [-lnks] <app>
	Flags:
		-l          Launch the app (default).*
		-n          Create a new app dir in /home/trash/wine.d.**
		-k          Kill all processes in the wine prefix of an app.
		-s          Get a shell with all environment variables ready to work with the wine prefix.
	
	* Scotch takes the app binary from /home/trash/wine.d/${app}/.app_bin. The path is relative to the app dir.
	** You should really create /home/trash/wine.d/.template for scotch to copy it into new prefixes.
