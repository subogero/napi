#!/usr/bin/perl
sub napi; sub tegnapi; sub keres; sub mutat; sub statu;
# Header
print <<HEADER;
Content-type: text/html

<!DOCTYPE html>
<html><head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>subogero napi</title></head><body>
<a href="?napi">napi</a>
<a href="?tegnapi">tegnapi</a>
<a href="?keres">keres</a>
<a href="napi.rss"><img src="rss.gif"></a>
HEADER

# Find working directory (uhttpd runs this in docroot)
($PWD = $0) =~ s/^(.+)index\.pl$/$1/;
chdir $PWD;
push @INC, $PWD;
require Percent2Utf8 or die;

# Store direcory URL upon first use
$dir_url = 'http://' . $ENV{HTTP_HOST} . $ENV{REQUEST_URI};
$dir_url =~ s:/$::;
unless (-f "dir_url.txt") {
    open URL, ">dir_url.txt";
    print URL "$dir_url\n";
    close URL;
}

# Read and sanitize POSTed query from stdin
my $query = $ENV{QUERY_STRING};
@query = split /&/, Percent2Utf8::p2u($query);
if    ($query[0] =~ /keres/  ) { keres   @query }
elsif ($query[0] =~ /tegnapi/) { tegnapi @query }
elsif ($query[0] =~ /mutat/  ) { mutat   @query }
else                           { napi           }

# Footer
if (open MOLINO, "molino") {
    print while <MOLINO>;
    close MOLINO;
}
print <<FOOTER;
<small><hr> (c) CC - Mer&eacute;nyi D&aacute;niel
<br>Eredeti: h t t p : / / n a p i r a j z . h u ----
h t t p : / / i n d e x . h u / n a p i r a j z ----
h t t p : / / c o m e d y c e n t r a l . h u
<br>Ez az oldal azok számára készült, akiket a céges internet proxy megfosztott
a napi rajz nyújtotta inspirációtól.<hr>
<a href="http://github.com/subogero">github.com/subogero</a>
<a href="statu.csv">statisztika</a>
</small>
</body></html>
FOOTER

####### Show pics from last 31 days
sub napi {
    my $after = time / (24 * 60 * 60) - 31;
    open MINE, "mine.csv" or print "Could not find database.\n" and return;
    my @hits;
    while (<MINE>) {
        my ($name, $date, $src, $add) = split /[;\n]/;
        my @time = split /_0?/, $date;
        my $time = ($time[0] - 1970) * 365.25
                 + ($time[1] -    1) *  30.44
                 + ($time[2] -    1);
        push @hits, { name => $name, src => $src, date => $date, add => $add } if $time > $after;
    }
    print "<hr><h3 align=\"center\">subogero napi</h3><hr>";
    foreach (reverse @hits) {
        (my $basename = $_->{name}) =~ s/^(.+)\..+$/$1/;
        my $link = "?mutat=$_->{name}&honnan=$_->{src}&mikor=$_->{date}";
        my $info = join ". ", $_->{src}, $_->{add};
        print "<a href=\"$link\">$basename</a> $info<br>\n";
    }
}

####### Archives by month
sub tegnapi {
    (my $month = $_[0]) =~ s/tegnapi=?(.*)/$1/;
    my $last_month = '';
    my $result = '';
    open MINE, "mine.csv" or print "Could not find database.\n" and return;
    while (<MINE>) {
        if ($month) {
            if (/^((.+)\.jpe?g);($month.*);(.*)(;(.+))$/i) {
                $result = "<a href=\"?mutat=$1&honnan=$4&mikor=$3\">$2</a> $4. $6<br>\n" . $result;
            }
        } else {
            /^.+;(\d{4}_\d{2}).+/;
            if ($1 ne $last_month) {
                $result = "<a href=\"?tegnapi=$1\">$1</a><br>\n" . $result;
                $last_month = $1;
            }
        }
    }
    close MINE;
    print "<hr><h3 align=\"center\">subogero tegnapi</h3><hr>";
    print $result;
}

####### Try to find pattern among jpg filenames in dir, print links to them
sub keres {
    my (@lines, %srcs);
    open MINE, "mine.csv" or print "Could not find database.\n" and return;
    while (<MINE>) {
        s/\r|\n//g;
        push @lines, $_;
        /^[^;]+;[^;]+;([^;]+)/;
        my $src = $1;
        $srcs{$src} = 1 if $src;
    }
    close MINE;
    print <<FORM;
<hr><h3 align="center">subogero napi keresés</h3><hr>
<form method="GET" action="?keres">
Forrás:
<select name="keres">
<option value="">mind</option>
FORM
    print "<option value=\"$_\">$_</option>\n" foreach (keys %srcs);
    print <<FORM;
<option value="nincs">ismeretlen</option>
</select>
<input type="text" name="rajz"/>
Keresés rajz nevére. <small>Tipp: üres minta!</small>
</form>
FORM
    (my $src = $_[0]) =~ s/keres=(.*)/$1/;
    $src =~ s/^$/.*/;
    $src =~ s/^nincs$//;
    (my $rajz = $_[1]) =~ s/rajz=(.*)/$1/;
    foreach (@lines) {
        if (/^((.*$rajz.*)\.jpe?g);(.+);($src)(;(.+))$/i) {
            print "<a href=\"?mutat=$1&honnan=$4&mikor=$3\">$2</a> $4. $6<br>\n"
        }
    }
}

####### Show a picture and update usage statistics
sub mutat {
    (my $pic = shift) =~ s/mutat=//;
    (my $title = $pic) =~ s/\..+//;
    $title =~ s/_/ /g;
    (my $src = shift) =~ s/honnan=//;
    $src = $src || 'mittomén';
    (my $day = shift) =~ s/mikor=//;
    $day =~ s/_/./g;
    print "<hr><h3 align=\"center\">$src <a href=\"$pic\">$title</a> $day</h3><hr>";
    print "<img src=\"$pic\"><br>\n";
    statu;
}

# Update user statistics
sub statu {
    my $remote_host = $ENV{REMOTE_HOST} || $ENV{REMOTE_ADDR};
    return unless $remote_host;
    my $remote_host_found = 0;
    open STATU_NEW, ">statu.csv~" or return;
    open STATU, "statu.csv";
    while (<STATU>) {
        if (/^$remote_host;(\d+)/) {
            $remote_host_found = 1;
            my $num = $1 + 1;
            print STATU_NEW "$remote_host;$num\n";
        } else {
            print STATU_NEW;
        }
    }
    print STATU_NEW "$remote_host;1\n" unless $remote_host_found;
    close STATU;
    close STATU_NEW;
    rename "statu.csv~", "statu.csv";
}
