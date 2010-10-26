package FieldDay::FieldType;

use strict;

use FieldDay::YAML qw( types object_type );
use FieldDay::Util qw( require_type mtlog );
use Data::Dumper;

our $type_tmpls;

sub label {
    return 'Unknown';
}

sub options {
    return {};
}

# code to go into html_head of template
sub html_head {
    return '';
}

# before FieldDay displays the config screen
sub pre_edit_options {
}

# before FieldDay saves a field's settings
sub pre_save_options {
}

# before FieldDay displays the Default Values config screen
sub pre_edit_default {
}

# before FieldDay saves the default value
sub pre_save_default {
}

# before the field is rendered in the CMS
sub pre_render {
    my $class = shift;
    my ($param) = @_;
}

# before the field value is output on a template
sub pre_publish {
    my $class = shift;
    my ($ctx, $args, $value, $field) = @_;
    return $value;
}

# before the CMS saves a value from the editing screen
sub pre_save_value {
    my $class = shift;
    my ($app, $field_name) = @_;
    return $app->param($field_name);
}

# after the CMS saves a value
sub post_save_value {
    my $class = shift;
    my ($app, $value_obj, $obj, $field) = @_;
}

# before a template tag displays the field value
sub pre_display_value {
}

# the field type that contains the options template, used for subclasses
sub options_tmpl_type {
}

# the field type that contains the render template, used for subclasses
sub render_tmpl_type {
}

sub html_head_type {
}

sub type_tmpls {
    my ($plugin, $app, $tmpl_type) = @_;
    $type_tmpls ||= {};
    return $type_tmpls->{$tmpl_type} if $type_tmpls->{$tmpl_type};
    my $field_types = types('field');
    my %options = ();
    my $ft_path = $app->{'cfg'}->pluginpath . '/FieldDay/field_types';
    for my $key (keys %$field_types) {
        require_type($app, 'field', $key);
        my $yaml = $field_types->{$key}->[0];
        next if ($yaml->{'abstract'});
        my $meth = $tmpl_type . '_tmpl_type';
        my $tmpl_dir = $yaml->{'class'}->$meth || $key;
        my $tmpl_path = "$ft_path/$tmpl_dir/tmpl";
        my $tmpl = $plugin->load_tmpl("$tmpl_path/$tmpl_type.tmpl");
        die Dumper($yaml) unless $tmpl;
        $options{$yaml->{'field_type'}} = $tmpl->text;
    }
    $type_tmpls->{$tmpl_type} = \%options;
    return \%options;
}

# any type-specific publishing tags
sub tags {
}

sub field_options {
    my ($tag_name, $ctx, $args) = @_;
    require FieldDay::Setting;
    my $tag = $ctx->stash('tag');
    $tag =~ /^(.+)$tag_name/i;
    my $ot = FieldDay::YAML->object_type(lc($1));
    my $object_type = $ot->{'object_mt_type'} || $ot->{'object_type'};
    my %terms = (
        'type' => 'field',
        'object_type' => $object_type,
        'name' => $args->{'field'},
    );
    if ($ot->{'has_blog_id'} && $ctx->stash('blog')) {
        $terms{'blog_id'} = $ctx->stash('blog')->id;
    }
    my $setting = FieldDay::Setting->load(\%terms);
    return {} unless $setting;
    return $setting->data->{'options'};
}

1;
