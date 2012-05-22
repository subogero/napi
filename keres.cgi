#!/bin/sh
# Header and query form
cat <<HEADER
Content-type: text/html

<html><head><title>keress a napiban</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="komedia.html">kom&eacute;dia</a>
<a href="keres.cgi">keres</a>
<hr><h3 align="center">keress a napiban</h3><hr>
<form method="POST" action="keres.cgi">
<input type="text" name="rajz"/>
Keres&eacute;s rajz nev&eacute;re. <small>Tipp: &uuml;res minta!</small>
</form>
HEADER

# Find working directory (uhttpd runs this in docroot)
PWD=`echo $0 | sed -r 's/^(\.\/)?(.*)keres.cgi$/\2/'`

# Read and sanitize POSTed query from stdin
# Try to find pattern among jpg filenames in dir, print links to them
read input
if [ -n "$input" ]; then
  pattern=`echo $input | sed -rn 's/^rajz=([A-Za-z0-9_]{0,40})/\1/p'`
  for line in `ls -1 $PWD`; do
    comic=`echo $line | grep -iE ${pattern}'[a-z0-9_]*\.jpe?g'`
    echo "<a href=\"mutat.pl?rajz=${comic}\">${comic}</a> "
    grep -li $comic ${PWD}[k2]*html \
    | sed -r 's:^([a-z0-9_/]*/)?([^/]+)$:<small><small><a href="\2">\2</a></small></small>:'
    [ -n "$comic" ] && echo '<br>'
  done
fi

# Footer
cat <<FOOTER
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
