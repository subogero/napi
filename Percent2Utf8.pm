package Percent2Utf8;

# Change a string from html percent-encoding to utf8
sub p2u {
    my $p = shift;
    my $u;
    while ($p) {
        $p =~ s/^([^%]+|%.{2})(.*)$/$2/;
        my $part = $1;
        $part = chr hex $1 if $part =~ /%(.{2})/;
        $u .= $part;
    }
    $u;
}

1;
