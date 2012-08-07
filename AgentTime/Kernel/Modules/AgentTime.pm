# OTRS Developer Training
# Zweites Modul

package Kernel::Modules::AgentTime;

use strict;
use warnings;

#Konstruktor
sub new
{
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;

}

sub Run
{


    my ( $Self, %Param ) = @_;
    

	my $output = $Self->{LayoutObject}->Header(
		Refresh => '5',
		#Title => 'OTRS - the timE ...'
	);

	$output .= $Self->{LayoutObject}->NavigationBar();
	
	my $thetime = $Self->{TimeObject}->SystemTime2TimeStamp(SystemTime=>$Self->{TimeObject}->SystemTime(),Type=>'Short');	
        
	$output .= $Self->{LayoutObject}->Notify(
        	Info => qq/Die aktuelle Uhrzeit: $thetime/,
        );

	

	
	$output .= $Self->{LayoutObject}->Footer();	

    return $output;
}

1;
