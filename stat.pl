#!/usr/bin/perl
($PWD = $0) =~ s/^(.+)stat\.pl$/$1/;
print <<HEADER;
Content-type: text/html

<!DOCTYPE html>
<html><head>
<title>napi statisztika</title>
</head><body>
<a href="index.html">napi</a>
<a href="tegnapi.html">tegnapi</a>
<a href="komedia.html">kom&eacute;dia</a>
<a href="aindex.html">aindex</a>
<a href="keres.pl">keres</a>
<hr><h3 align="center">napi statisztika</h3><hr>
HEADER

open STATM, "$PWD/stat.txt";
$statm{ehavi} = <STATM>;
$max = $statm{ehavi  };
open STATM, "$PWD/statm.txt";
while (<STATM>) {
    /^(.+) (.+)\n$/;
    $statm{$1} = $2;
    $max = $2 if ($max < $2);
}
close STATM;
$h = keys(%statm) * 10;
$max += 70;

print <<CANVAS1;
<canvas id="vaszon" width="$max" height="$h">
Ez egy html5 canvas. Ainternetekszplorered meg egy elavult szar.
</canvas>
<script type="text/javascript">
var c=document.getElementById("vaszon");
var ctx=c.getContext("2d");
ctx.font="8px monospace";
CANVAS1

$i = 0;
foreach (reverse sort keys %statm) {
print <<LINE;
ctx.textAlign='start'; ctx.fillText("$_"        ,  0, $i*10+7);
ctx.textAlign='right'; ctx.fillText("$statm{$_}", 60, $i*10+7);
ctx.fillRect(70, $i*10, $statm{$_}, 8);
LINE
$i++;
}

print <<CANVAS2;
</script>
CANVAS2

print <<FOOTER;
<br><small><a href="http://github.com/subogero">github.com/subogero</a></small>
</body></html>
FOOTER
