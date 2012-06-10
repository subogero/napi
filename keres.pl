#!/usr/bin/perl
# Header and query form
print <<HEADER;
Content-type: text/html

<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>keress a napiban</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="komedia.html">kom&eacute;dia</a>
<a href="aindex.html">aindex</a>
<a href="keres.pl">keres</a>
<hr><h3 align="center">keress a napiban</h3><hr>
<form method="POST" action="keres.pl">
<input type="text" name="rajz"/>
Keres&eacute;s rajz nev&eacute;re. <small>Tipp: &uuml;res minta!</small>
</form>
HEADER

# Find working directory (uhttpd runs this in docroot)
($PWD = $0) =~ s/^(.+)keres\.pl$/$1/;
push @INC, $PWD;
require Percent2Utf8 or die;

# Read and sanitize POSTed query from stdin
# Try to find pattern among jpg filenames in dir, print links to them
$query = Percent2Utf8::p2u(<>);
if ($query =~ /^rajz=(.{0,40})$/) {
    my $pattern = $1;
    opendir LS, $PWD or die "$!";
    foreach (readdir LS) {
        s/\r|\n//g;
        next unless (/^(.*$pattern.*)\.jpe?g/i);
        print "<a href=\"mutat.pl?rajz=$_\">$1</a> ";
        open GREP, "grep -i \\\"mutat.pl\?rajz=$_ $PWD/[ki2]*html |" or die "$!";
        while (<GREP>) {
            /^.+\/(\w+)(\.html):.+$/;
            print "<a href=\"$1$2\"><small><small>$1</small></small></a> ";
        }
        print "<br>";
    }
    closedir LS;
}

# Footer
print <<FOOTER;
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
