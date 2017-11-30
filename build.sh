#!/bin/bash

root=/app/web/dnd.cold.org

cd $root/repo
git clean -xdf
git pull
/home/svc-user/bin/jekyll build

cd $root

date=$(date +%y-%m-%d.%H.%M.%S)
mv stage $date
rm -rf live
ln -s $date live

perl -e '
	opendir(DIR, ".");
	@all = ();
	for my $f (readdir(DIR)) {
		if ($f =~ /^\d+-\d+-\d+\.\d+\.\d+\.\d+$/) {
			push(@all, $f);
		}
	}
	@all = sort(@all);
	while (@all > 2) {
		my $last = shift(@all);
		print("removing old $last\n");
		system("rm", "-rf", $last);
	}
'
