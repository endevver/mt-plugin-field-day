
package FieldDay::FieldType::Checkbox;
use strict;

use base qw( FieldDay::FieldType );

sub label {
    return 'Text';
}

sub options {
    return {
    };
}

sub pre_render {
# before the field is rendered in the CMS
    my $class = shift;
    my ($param) = @_;
    
}

1;
