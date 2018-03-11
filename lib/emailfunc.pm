package emailfunc;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP qw();
use Email::Simple;
use Email::Simple::Creator;
use Email::MIME::CreateHTML;
use Try::Tiny;

use strict;
use Exporter;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);
our @EXPORT_OK   = qw(post_plain_email post_html_email);
our %EXPORT_TAGS = (
    DEFAULT => [qw()],
    ALL     => [qw(post_plain_email post_html_email)],
);

sub post_plain_email {
    my $emaildata = shift;

    my $email = Email::Simple->create(
        header  => [
                From            => $emaildata->{'From'},
                To              => $emaildata->{'To'},
                Cc              => $emaildata->{'Cc'},
                Subject         => $emaildata->{'Subject'},
                'Content-Type'  => "text/plain\; charset=\"utf-8\"",
            ],
        body    => $emaildata->{'Plain'}
    );

    my $response = 0;
    try {
        my $transport = Email::Sender::Transport::SMTP->new({
            host => config->{email}{host},
        });
        $response = sendmail($email, { transport => $transport });
        return $response;
    } catch {
        debug("Sending failed: $_ / $response");
        return "Sending failed: $_ / $response";
    };

    return;
}

sub post_html_email {
    my $emaildata = shift;

    my $email = Email::MIME->create_html(
        header    => [
            From    => $emaildata->{'From'},
            To      => $emaildata->{'To'},
            Cc      => $emaildata->{'Cc'},
            Subject => $emaildata->{'Subject'},
            'Content-Type'  => "text/plain\; charset=\"utf-8\"",
        ],
        body            => $emaildata->{'HTML'},
        text_body       => $emaildata->{'Plain'},
        embed           => 0,
    );

    my $response = 0;
    try {
        my $transport = Email::Sender::Transport::SMTP->new({
            host => config->{email}{host},
        });
        $response = sendmail($email, { transport => $transport });
        return $response;
    } catch {
        debug("Sending failed: $_ / $response");
        return "Sending failed: $_ / $response";
    };

}

sub debug {
    my $message = shift;
    print $message, "\n";
}

1;
