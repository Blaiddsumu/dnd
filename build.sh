#!/bin/bash

sendto=morgan@cold.org,brandon@cold.org
#sendto=brandon@cold.org
root=/app/web/dnd.cold.org

msg() {
    local msg="$1"
    local body="$2"

    echo "msg=$msg"
    echo "body=$body"

    if [ -z "$body" ]; then
        body="$msg"
    fi

    /usr/lib/sendmail -oi -t -f 'deploy' <<END
From: deploy
To: $sendto
Subject: $msg
$body
END

}

abort() {
    msg="$1"
    body=$(cat $root/lastrun.log)

    msg "$msg" "
$body
!!! Cannot continue deploy"
    exit 1
}

docmd() {
    exc="$@"
    "$@" 2>&1 | tee -a $root/lastrun.log

    if [ $? -gt 0 ]; then
        abort "Error running '$*'"
    fi
}


rm $root/lastrun.log
cd $root/repo
docmd git clean -xdf
docmd git pull
docmd ~bjg/git/docker-jekyll/dc-jekyll /app/build-inner.sh

date=$(date +%y-%m-%d.%H.%M.%S)

if [ ! -d _site ]; then
    abort "No _site folder found!"
fi

docmd mv _site $root/$date
docmd cd $root

docmd rm -rf live
docmd ln -s $date live

msg "Site updated"

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
