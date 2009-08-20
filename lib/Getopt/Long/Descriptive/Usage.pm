package Getopt::Long::Descriptive::Usage;
use strict;
use warnings;

use List::Util qw(max);

=head1 NAME

Getopt::Long::Descriptive::Usage - the usage description for GLD

=head1 SYNOPSIS

  use Getopt::Long::Descriptive;
  my ($opt, $usage) = describe_options( ... );

  $usage->text; # complete usage message

  $usage->die;  # die with usage message

=head1 DESCRIPTION

This document only describes the methods of the Usage object.  For information
on how to use L<Getopt::Long::Descriptive>, consult its documentation.

=head1 METHODS

=head2 new

  my $usage = Getopt::Long::Descriptive::Usage->new(\%arg);

You B<really> don't need to call this.  GLD will do it for you.

Valid arguments are:

  options     - an arrayref of options
  leader_text - the text that leads the usage; this may go away!

=cut

sub new {
  my ($class, $arg) = @_;

  my @to_copy = qw(options leader_text);

  my %copy;
  @copy{ @to_copy } = @$arg{ @to_copy };

  bless \%copy => $class;
}

=head2 text

This returns the full text of the usage message.

=cut

sub text {
  my ($self) = @_;

  return join qq{\n}, $self->leader_text, $self->option_text;
}

=head2 leader_text

This returns the text that comes at the beginning of the usage message.

=cut

sub leader_text { $_[0]->{leader_text} }

=head2 option_text

This returns the text describing the available options.

=cut

sub option_text {
  my ($self) = @_;

  my @options  = @{ $self->{options} || [] };
  my $string   = q{};

  # a spec can grow up to 4 characters in usage output:
  # '-' on short option, ' ' between short and long, '--' on long
  my @specs = map { $_->{spec} } grep { $_->{desc} ne 'spacer' } @options;
  my $length   = (max(map { length } @specs) || 0) + 4;
  my $spec_fmt = "\t%-${length}s";

  while (@options) {
    my $opt  = shift @options;
    my $spec = $opt->{spec};
    my $desc = $opt->{desc};
    if ($desc eq 'spacer') {
      $string .= sprintf "$spec_fmt\n", $opt->{spec};
      next;
    }

    $spec = Getopt::Long::Descriptive->_strip_assignment($spec);
    $spec = join " ", reverse map { length > 1 ? "--$_" : "-$_" }
                              split /\|/, $spec;
    $string .= sprintf "$spec_fmt  %s\n", $spec, $desc;
  }

  return $string;
}

=head2 warn

This warns with the usage message.

=cut

sub warn { warn shift->text }

=head2 die

This throws the usage message as an exception.

=cut

sub die  { 
  my $self = shift;
  my $arg  = shift || {};

  die(
    join(
      "", 
      grep { defined } $arg->{pre_text}, $self->text, $arg->{post_text},
    )
  );
}

use overload (
  q{""} => "text",

  # This is only needed because Usage used to be a blessed coderef that worked
  # this way.  Later we can toss a warning in here. -- rjbs, 2009-08-19
  '&{}' => sub {
    my ($self) = @_;
    return sub { return $_[0] ? $self->text : $self->warn; };
  }
);

=head1 AUTHOR

Hans Dieter Pearcey, C<< <hdp@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-getopt-long-descriptive@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Getopt-Long-Descriptive>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Hans Dieter Pearcey, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;