#!/usr/bin/perl
# Header and query form
print <<EOF;
Content-type: text/html

<head><title>keress a napiban</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="keres.pl">keres</a>
<hr><h3 align="center">keress a napiban</h3><hr>
<form method="POST" action="keres.pl">
<input type="text" name="rajz"/> Keres&eacute;s rajz filen&eacute;vre
</form>
EOF

# Find working directory (uhttpd runs this in docroot)
($PWD = $0) =~ s/^(.+)keres\.pl$/$1/;

# Read and sanitize POSTed query from stdin
# Try to find pattern among jpg filenames in dir, print link to them
$query .= $_ while (<>);
if ($query =~ /^rajz=(\w{1,40}).*$/) {
    my $pattern = $1;
    open LS, "ls -1 $PWD |" or die "$!";
    while (<LS>) {
        if (/^(\w*$pattern\w*)\.jpe?g/i) {
            print "<a href=\"$_\">$1</a><br>";
        }
    }
}

# Footer
print "</body></html>";
