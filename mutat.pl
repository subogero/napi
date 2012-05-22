#!/usr/bin/perl
# Header and query form
print <<HEADER;
Content-type: text/html

<html><head><title>keress a napiban</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="komedia.html">kom&eacute;dia</a>
<a href="keres.pl">keres</a><hr>
HEADER

# Find working directory (uhttpd runs this in docroot)
($PWD = $0) =~ s/^(.+)mutat\.pl$/$1/;

# Read picture name from QUERY_STRING env var (GET method)
my $query = $ENV{QUERY_STRING};
if ($query =~ /^rajz=([\w.]{5,40})$/) {
    my $filename = $1;
    if (-f "$PWD$filename") {
        print "<img src=\"$filename\" alt=\"$filename\"/>\n";
    } else {
        print "Itt bizony nincs $filename.\n";
    }
}

# Footer
print <<FOOTER;
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
