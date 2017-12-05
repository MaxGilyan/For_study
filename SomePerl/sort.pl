use 5.016;
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

my @month = qw(jan feb mar apr may jun jul aug sep oct nov dec);
my %monthHash = map { $month[$_] => $_ } 0..$#month;

sub getSubStr #функция для того, чтобы вытащить из строки столбец
{
	my ($string, $N)=@_;#на вход получаем строку и номер столбца
	$string =~ s/^\s+//;#r  к сожалению, если не убрать пробелы в начале, следующая регулярка в числе результатов выдавала пустую строку
	my @words = split /[^\w]+/, $string;
	return $words[$N-1];
}

sub getMonthNumber #функция для того, чтобы получить номер месяца
{
	my $strMonth=$_[0];

	return $monthHash{$strMonth};
}

my %availability = ( #хеш для проверки наличия флагов
	"-r" => 0,
	"-n" => 0,
	"-k" => 0,
	"-u" => 0,
	"-c" => 0,
	"-M" => 0,
);

my @queue=qw(-u -n -k -M -r -c); #очередь приоритета исполнения операций

my %func = ( #хеш для вызова анонимных функций
	'-r'=> (sub { 
			my $string=$_[0];
			@$string = reverse @$string;
		}),
	'-n'=> (sub { 
			my $string=$_[0]; #ссылка на массив строк
			my $kFlag=$_[3];
			@$string = sort {fc($a) <=> fc($b) || fc($a) cmp fc($b)} @$string unless($kFlag);
		}),
	'-k'=> (sub {
			my ($strings, $number, $nFlag)=@_; #ссылка на массив строк, номер столбца, наличие  флага n
			@$strings = sort { fc(getSubStr($a, $number)) cmp fc(getSubStr($b, $number))} @$strings unless ($nFlag);
			@$strings = sort { getSubStr($a, $number) <=> getSubStr($b, $number) || fc(getSubStr($a, $number)) cmp fc(getSubStr($b, $number))} @$strings if ($nFlag);
		}),
	'-u'=> (sub {
			my $string=$_[0]; #ссылка на массив строк
			my %uniq;
			@$string = grep { !$uniq{$_}++ } @$string;
		}),
	'-c'=> (sub {
			my $stringNew = $_[0]; #ссылка на массив строк после сортировки 
			my $stringsOld = $_[4]; #ссылка на массив строк перед сортировкой
			for my $i (@$stringNew)
			{
				unless ($stringNew->[$i] eq $stringsOld->[$i] or $stringNew->[$i]==$stringsOld->[$i])
				{
					print "Unsorted\n";
					return;
				}
			}

			print "Sorted\n";
		}),
	'-M'=> (sub {
			my $string=$_[0]; #ссылка на массив строк
			@$string = sort {getMonthNumber(getSubStr($a, 1)) <=> getMonthNumber(getSubStr($b, 1))} @$string;#в слаке Монс писал, что для месяца берем только первые 3 буквы :)		
		}),
);

GetOptions(
    'n!' => \$availability{'-n'},
    'k=i' => \$availability{'-k'},
    'u!' => \$availability{'-u'},
    'r!' => \$availability{'-r'},
    'c!' => \$availability{'-c'},
    'M!' => \$availability{'-M'}
) or die "Incorrect usage!\n";

my @strings=<STDIN>;

@strings = sort @strings unless ($availability{'-K'}||$availability{'-n'}||$availability{'-k'});

for (@queue)
{
	$func{$_}->(\@strings, $availability{$_}, $availability{'-n'}, $availability{'-k'}, \<STDIN>) if ($availability{$_});
}

print @strings;