package Spreadsheet::WriteExcel::FromXML::Worksheet;
use strict;
use warnings;

our $VERSION = '1.00';

use Carp qw(confess cluck);

=head1 NAME

Spreadsheet::WriteExcel::FromXML::Worksheet

=head1 SYNOPSIS

  # inner class for use by FromXML

=head1 DESCRIPTION

Workbook object for FromXML.

=head1 API REFERENCE

=cut

sub new
{
  my $this  = shift;
  my $class = ref($this) || $this;
  my $self  = {};
  bless $self,$class;
  $self->_init( @_ );
  return $self;
}

sub _init
{
  my($self,$excelWorksheet) = @_;
  unless( $excelWorksheet && UNIVERSAL::isa($excelWorksheet,'Spreadsheet::WriteExcel::Worksheet') ) {
    confess "Must pass a Spreadsheet::WriteExcel::Worksheet to constructor\n";
  }
  $self->{'_excelWorksheet'} = $excelWorksheet;
  $self->cells( [[]] );
  $self->dataTypeMethods( [] );
  $self->formats( [] );
}

=head2 addDataType

Supported data types from Speadsheet::WriteExcel:

  write()
  write_number()
  write_string()
  write_blank()
  write_row()
  write_col()
  write_url()
  write_url_range()
  write_formula()
  
=cut
sub addDataType
{
  my($self,$datatype,$x,$y) = @_;
  if( 'string' eq $datatype )
  {
    $self->dataTypeMethods->[$x][$y] = 'write_string';
  }
  elsif( 'number' eq $datatype )
  {
    $self->dataTypeMethods->[$x][$y] = 'write_number';
  }
  elsif( 'url' eq $datatype )
  {
    $self->dataTypeMethods->[$x][$y] = 'write_url';
  }
  elsif( 'formula' eq $datatype )
  {
    $self->dataTypeMethods->[$x][$y] = 'write_formula';
  }
  elsif( 'blank' eq $datatype )
  {
    $self->dataTypeMethods->[$x][$y] = 'write_blank';
  }
  else
  {
    cluck "unknown data type '$datatype' defaulting to write.\n";
    $self->dataTypeMethods->[$x][$y] = 'write_string';
  }
}

sub addFormat
{
  my($self,$format,$x,$y) = @_;
  $self->formats->[$x][$y] = undef;
  $self->formats->[$x][$y] = $format if ( $format );
}

sub addCell
{
  my($self,$data,$datatype,$x,$y,$format) = @_;
  # print STDERR "Adding '",($data||''),"' to cell $$x $$y\n";
  $self->cells->[$$x][$$y] = $data||'';
  $self->addDataType( $datatype,$$x,$$y );
  $self->addFormat( $format,$$x,$$y );
}

sub buildWorksheet
{
  my($self,$excelFormats) = @_;
  for( my $i = 0; $i < @{ $self->cells }; ++$i ) {
    if( $self->cells->[$i] ) {
      for( my $j = 0; $j < @{ $self->cells->[$i] }; ++$j ) {
        my $formatName = $self->formats->[$i][$j];
	my $format = undef;
	if( $formatName ) {
	  unless( exists $excelFormats->{ $formatName } )
	  {
	    cluck "format '$formatName' does not exist!  Ignoring.\n";
	  } else
	  {
	    $format = $excelFormats->{ $formatName };
	  }
	}

        # print "writing $i x  $j - '",$self->cells->[$i][$j],"'\n";
	my $dataTypeMethod = $self->dataTypeMethods->[$i][$j];
        $self->excelWorksheet->$dataTypeMethod( $i, $j, $self->cells->[$i][$j], $format );
      }
    # blank row
    } else {
      $self->excelWorksheet->write_string( $i, 0, '' );
    }
  }
}

sub excelWorksheet  { @_>1 ? $_[0]->{'_excelWorksheet'} = $_[1] : $_[0]->{'_excelWorksheet'}; }
sub cells           { @_>1 ? $_[0]->{'_cells'} = $_[1] : $_[0]->{'_cells'}; }
sub dataTypeMethods { @_>1 ? $_[0]->{'_dataTypeMethods'} = $_[1] : $_[0]->{'_dataTypeMethods'}; }
sub formats         { @_>1 ? $_[0]->{'_formats'} = $_[1] : $_[0]->{'_formats'}; }

1;

=head1 SEE ALSO

SpreadSheet::WriteExcel::FromXML

=head1 AUTHORS

W. Justin Bedard juice@lerch.org

Kyle R. Burton mortis@voicenet.com, krburton@cpan.org

=cut
