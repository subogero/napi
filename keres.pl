#!/usr/bin/perl
print <<EOF;
Content-type: text/html

<head><title>keress a napiban</title></head>
<body>
<hr><h1 align="center">keress a napiban</h1><hr>
<form method="POST" action="keres.pl">
<input type="text" name="rajz"/>
</form><hr>
EOF
$query .= $_ while (<>);
($PWD = $0) =~ s/^(.+)keres\.pl$/$1/;
if ($query =~ /^rajz=(\w{1,40}).*$/) {
    my $minta = $1;
    open LS, "ls -1 $PWD |" or die "$!";
    while (<LS>) {
        if (/^(\w*$minta\w*)\.[jpeg]{3,4}/i) {
            print "<a href=\"$_\">$1</a><br>";
        }
    }
}
print <<EOF;
</body></html>
EOF
