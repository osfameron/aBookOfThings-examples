package Dancer::Serializer::Text;
 
use strict;
use warnings;
use Carp;
use Dancer::ModuleLoader;
use Dancer::Deprecation;
use Dancer::Config 'setting';
use Dancer::Exception qw(:all);
use base 'Dancer::Serializer::Abstract';
 
 
# helpers
 
# class definition
 
 
sub init {
    my ($self) = @_;
}
 
sub serialize {
    my $self   = shift;
    my $entity = shift;
 
    if (ref $entity) {
        return ($entity->{id} || $entity->{status} || 'unknown') . "\n";
    }
    else {
        return $entity;
    }
}
 
sub deserialize {
    my $self   = shift;
    my $entity = shift;
    return $entity;
}
 
sub content_type {'text/plain'}
 
1;
