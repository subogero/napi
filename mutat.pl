#!/usr/bin/perl
# Find working directory (uhttpd runs this in docroot)
($PWD = $0) =~ s/^(.+)mutat\.pl$/$1/;

# Read picture name from QUERY_STRING env var (GET method)
my $query = $ENV{QUERY_STRING};
if ($query =~ /^rajz=(([\w]{5,40})\.jpe?g)$/) {
    ($filename, $basename) = ($1, $2);
    if (-f "$PWD$filename") {
        $stuff  = "<a href=\"$filename\">$basename</a>";
        $stuff .= "<hr><img src=\"$filename\" alt=\"$filename\"/>\n";
    } else {
        $stuff = "<hr>404 - Itt nincs semmilyen $filename.\n";
    }
} else {
    $stuff = "<hr>Mit mutassak?";
}

# Header
print <<HEADER;
Content-type: text/html

<html><head><title>napi $basename</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="komedia.html">kom&eacute;dia</a>
<a href="keres.pl">keres</a>
HEADER

print $stuff;

# Footer
print <<FOOTER;
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
