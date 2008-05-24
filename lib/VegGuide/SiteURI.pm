package VegGuide::SiteURI;

use strict;
use warnings;

use Exporter qw( import );
use URI::FromHash qw( uri );
use VegGuide::Validate qw( validate VENDOR_TYPE LOCATION_TYPE USER_TYPE
                           NEWS_ITEM_TYPE VENDOR_IMAGE_TYPE
                           SCALAR_TYPE HASHREF_TYPE BOOLEAN_TYPE );

our @EXPORT_OK = qw( entry_uri entry_image_uri entry_review_uri
                     news_item_uri region_uri user_uri site_uri
                     static_uri );


{
    my $spec = { vendor    => VENDOR_TYPE,
                 path      => SCALAR_TYPE( optional => 1 ),
                 fragment  => SCALAR_TYPE( optional => 1 ),
                 query     => HASHREF_TYPE( default => {} ),
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub entry_uri
    {
        my %p = validate( @_, $spec );

        my $path = '/';
        $path .= join '/', 'entry', $p{vendor}->vendor_id(), ( $p{path} || () );

        my @fragment;
        @fragment = ( fragment => $p{fragment} )
            if $p{fragment};

        return uri( _with_host( $p{with_host} ),
                    path => $path,
                    @fragment,
                    query => $p{query} );
    }
}

{
    my $spec = { image     => VENDOR_IMAGE_TYPE,
                 path      => SCALAR_TYPE( optional => 1 ),
                 fragment  => SCALAR_TYPE( optional => 1 ),
                 query     => HASHREF_TYPE( default => {} ),
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub entry_image_uri
    {
        my %p = validate( @_, $spec );

        my $path = '/';
        $path .= join '/',( 'entry', $p{image}->vendor_id(),
                            'image', $p{image}->display_order(), ( $p{path} || () ) );

        my @fragment;
        @fragment = ( fragment => $p{fragment} )
            if $p{fragment};

        return uri( _with_host( $p{with_host} ),
                    path => $path,
                    @fragment,
                    query => $p{query} );
    }
}

{
    my $spec = { vendor    => VENDOR_TYPE,
                 user      => USER_TYPE,
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub entry_review_uri
    {
        my %p = validate( @_, $spec );

        my $user = delete $p{user};

        return entry_uri( %p,
                          fragment => 'user-id-' . $user->user_id(),
                        );
    }
}

{
    my $spec = { location => LOCATION_TYPE,
                 path     => SCALAR_TYPE( optional => 1 ),
                 fragment => SCALAR_TYPE( optional => 1 ),
                 query    => HASHREF_TYPE( default => {} ),
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub region_uri
    {
        my %p = validate( @_, $spec );

        my $path = '/';
        $path .= join '/', 'region', $p{location}->location_id(), ( $p{path} || () );

        my @fragment;
        @fragment = ( fragment => $p{fragment} )
            if $p{fragment};

        return uri( _with_host( $p{with_host} ),
                    path => $path,
                    @fragment,
                    query => $p{query} );
    }
}

{
    my $spec = { user     => USER_TYPE,
                 path     => SCALAR_TYPE( optional => 1 ),
                 fragment => SCALAR_TYPE( optional => 1 ),
                 query    => HASHREF_TYPE( default => {} ),
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub user_uri
    {
        my %p = validate( @_, $spec );

        my $path = '/';
        $path .= join '/', 'user', $p{user}->user_id(), ( $p{path} || () );

        my @fragment;
        @fragment = ( fragment => $p{fragment} )
            if $p{fragment};

        return URI::FromHash::uri( _with_host( $p{with_host} ),
                                   path => $path,
                                   @fragment,
                                   query => $p{query} );
    }
}

{
    my $spec = { item      => NEWS_ITEM_TYPE,
                 path      => SCALAR_TYPE( optional => 1 ),
                 fragment  => SCALAR_TYPE( optional => 1 ),
                 query     => HASHREF_TYPE( default => {} ),
                 with_host => BOOLEAN_TYPE( default => 0 ),
               };
    sub news_item_uri
    {
        my %p = validate( @_, $spec );

        my $path = '/';
        $path .= join '/', 'site', 'news', $p{item}->item_id(), ( $p{path} || () );

        my @fragment;
        @fragment = ( fragment => $p{fragment} )
            if $p{fragment};

        return URI::FromHash::uri( _with_host( $p{with_host} ),
                                   path => $path,
                                   @fragment,
                                   query => $p{query} );
    }
}

sub site_uri
{
    my %p = @_;

    if ( delete $p{with_host} )
    {
        %p = ( %p, _with_host(1) );
    }

    return uri(%p);
}

{
    my $Prefix = VegGuide::Config->StaticPrefix();
    sub static_uri
    {
        my %p = @_;

        if ( delete $p{with_host} )
        {
            %p = ( %p, _with_host(1) );
        }

        $p{path} = q{/} . $Prefix . $p{path}
            if $Prefix;

        return uri(%p);
    }
}

sub _with_host
{
    return unless $_[0];

    return ( scheme => 'http',
             host   => VegGuide::Config->CanonicalWebHostname(),
           );
}

if ( VegGuide::Config->IsProduction() )
{
    no warnings 'redefine';

    *validate = sub (\@$) { return ( query => {}, @{ $_[0] } ) };
}


1;
