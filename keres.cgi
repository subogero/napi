#!/bin/sh
# Header and query form
cat <<HEADER
Content-type: text/html

<html><head><title>keress a napiban</title></head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="keres.cgi">keres</a>
<hr><h3 align="center">keress a napiban</h3><hr>
<form method="POST" action="keres.cgi">
<input type="text" name="rajz"/>
Keres&eacute;s rajz nev&eacute;re. <small>Tipp: &uuml;res minta!</small>
</form>
HEADER

# Find working directory (uhttpd runs this in docroot)
PWD=`echo $0 | sed -r 's/^(\.\/)?(.*)keres.cgi$/\2/'`
echo DEBUG PRG $0 '<br>' DEBUG PWD $PWD '<br>'
# Read and sanitize POSTed query from stdin
# Try to find pattern among jpg filenames in dir, print links to them
pattern=`sed -rn 's/^rajz=([A-Za-z0-9_]{0,40})/\1/p'`
echo DEBUG PTR $pattern '<br>'
for line in `ls -1 $PWD`; do
  comic=`echo $line | sed -rn "s/^[a-z0-9_]*${pattern}[a-z0-9_]*\.jpe?g$/&/pi"`
  echo -n "<a href=\"${comic}\">${comic}</a> "
  grep -li $comic ${PWD}2*html \
  | sed -r 's:^([a-z0-9_/]*/)?([^/]+)$:<small><small><a href="\2">\2</a></small></small>:'
  [ -n "$comic" ] && echo '<br>'
done

# Footer
cat <<FOOTER
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
