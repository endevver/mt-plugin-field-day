
package FieldDay::FieldType::LinkedObject::LinkedEntry;
use strict;
use Data::Dumper;

use base qw( FieldDay::FieldType::LinkedObject );

sub tags {
	return {
		'per_type' => {
			'block' => {
				'LinkedEntries' => sub { __PACKAGE__->hdlr_LinkedObjects('entry', @_) },
				'IfLinkedEntries?' => sub { __PACKAGE__->hdlr_LinkedObjects('entry', @_) },
				'LinkingEntries' => sub { __PACKAGE__->hdlr_LinkingObjects('entry', @_) },
				'IfLinkingEntries?' => sub { __PACKAGE__->hdlr_LinkingObjects('entry', @_) },
			},
		},
	};
}

sub options {
	return {
		'linked_blog_id' => undef,
		'category_ids' => undef,
		'lastn' => undef,
		'search' => undef,
		'published' => 1,
	};
}

sub label {
	return 'Linked Entry';
}

sub object_type {
	return 'entry';
}

sub render_tmpl_type {
# the field type that contains the render template, used for subclasses
	return 'LinkedObject';
}

sub load_objects {
	my $class = shift;
	my ($param) = @_;
	require MT::Entry;
	return () unless ($param->{'linked_blog_id'});
	my $terms = {
		 blog_id => $param->{'linked_blog_id'},
	};
	if ($param->{'published'}) {
		$terms->{'status'} = MT::Entry::RELEASE();
	}
	my $args = {};
	if ($param->{'lastn'}) {
		$args = {
			'sort' => 'authored_on',
			'direction' => 'descend',
			'limit' => $param->{'lastn'},
		};
	} else {
		$args = {
			'sort' => 'title',
			'direction' => 'ascend',
		};
	}
	if ($param->{'category_ids'}) {
		my $cat_ids = [ split(/,/, $param->{'category_ids'}) ];
		require MT::Placement;
		$args->{'join'} =  MT::Placement->join_on(
				'entry_id',
				{ category_id => $cat_ids,
				  class => 'category',
				},
				{ unique => 1 }
			);
	}
	return MT::Entry->load($terms, $args)
}

sub object_label {
	my $class = shift;
	my ($obj) = @_;
	require MT::Util;
	return $obj->title ? MT::Util::remove_html($obj->title) : '[untitled]';
}


1;
