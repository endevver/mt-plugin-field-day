
package FieldDay::FieldType::File;
use strict;

use base qw( FieldDay::FieldType );

sub label {
	return 'File';
}

sub options {
	return {
		'upload_path' => undef,
		'url_path' => undef,
		'overwrite' => 0,
		'filenames' => 'dirify',
	};
}

sub html_head {
	return <<"HTML";
<script type="text/javascript">
womAdd('fdFileFixForm()');
function fdFileFixForm() {
document.getElementById('<mt:var name="object_form_id">').enctype = 'multipart/form-data';
}
</script>
HTML
}

sub pre_render {
# before the field is rendered in the CMS
	my $class = shift;
	my ($param) = @_;
	$param->{'can_upload'} = MT->instance->permissions->can_upload;
	if ($param->{'value'} && $param->{'value'} =~ /\.(jpg|gif|bmp|png|jpeg)$/) {
		$param->{'image'} = 1;
	}
}

sub pre_edit_options {
# before FieldDay displays the config screen
	my $class = shift;
	my ($param) = @_;
	$param->{$param->{'filenames'} . '_selected'} = 1;
}

sub pre_save_value {
# before the CMS saves a value from the editing screen
	my $class = shift;
	my ($app, $field_name, $obj, $options) = @_;
		# if they entered a value in the actual field, use that;
		# if not, use name of uploaded file
	my $upload_field = $field_name . '_upload';
	my $upload_file;
	my $q = $app->{'query'};
	if (!$q->param($upload_field)) {
		return $q->param($field_name);
	}
	if ($q->param($field_name)) {
		$upload_file = $q->param($field_name);
	} else {
		$upload_file = $q->param($upload_field);
			# IE/Win sends full path as filename
		if ($upload_file =~ m#[/\\]#) {
			$upload_file =~ s#.*[/\\]([^/\\]+)$#$1#;
		}
		if ($options->{'filenames'} ne 'keep') {
			$upload_file =~ s/\.(\w+)$//;
			my $ext = $1;
			if (!$ext) {
				(undef, $ext) = split(m#/#, 
					$q->uploadInfo($q->param($upload_field))->{'Content-Type'});
				$ext = 'jpg' if ($ext eq 'jpeg');
				$ext = 'txt' if ($ext eq 'text');
			}
			if ($options->{'filenames'} eq 'dirify') {
				require MT::Util;
				$upload_file = MT::Util::dirify($upload_file);
			} elsif ($options->{'filenames'} eq 'id') {
				$upload_file = $obj->id;
			} elsif ($options->{'filenames'} eq 'basename') {
				$upload_file = $obj->basename;
			}
			$field_name =~ s/-instance-/_/;
			$upload_file .= "_${field_name}.$ext";
		}
	}
	
	return save_upload($q->upload($upload_field),
		$options->{'upload_path'}, $upload_file, $options->{'overwrite'});
}

sub save_upload {
	my ($fh, $path, $file, $overwrite) = @_;
	$path =~ s#/$##;
		# if no path, don't add a slash before filename
		# (i.e., filename itself is absolute path)
	$path = "$path/" if $path;
	my $filename = "$path$file";
	my $newfile;
		# generate unique filename (add number if it exists)
	unless ($overwrite) {
		my $i = 0;
		while (-e $filename) {
			$i++;
			$newfile = $file;
			$newfile =~ s/\.(\w+)$/_$i.$1/;
			$filename = "$path$newfile";
		}
	}
	seek($fh, 0, 0);
	open(UPLOAD, ">$filename");
	binmode(UPLOAD);
	while (<$fh>) {
		print UPLOAD;
	}
	close UPLOAD;
	return $newfile ? $newfile : $file;
}

1;
