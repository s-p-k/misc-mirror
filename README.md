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

chameleon
---------
A background changer

	$ chameleon --help
	Usage: chameleon [options] <target>
	Options:
		-m|--bg-manager			# Specify a bg manager to use. The default is feh.
		-M|--bg-mode			# Specify the bg mode.
		-C|--color				# Specify a color for the background. If used without a target image, fills the background with the color. Needs imagemagick for that though.
		-d|--daemon				# Daemon mode: sets the background periodically. Useful if the taget is a dir.
		-D|--daemon-delay		# Delay for periodic bg changing, in seconds (default: 900).
		-r|--recursive			# If the target is a dir, search for files recursively.
		-v|--verbose			# Be verbose.
		-h|--help				# Show this message.
	Modes:
		feh: center, fill, max, scale, tile.
