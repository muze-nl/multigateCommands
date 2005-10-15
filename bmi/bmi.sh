#! /bin/sh

if test -z $1
then
	echo "Gebruik !bmi <lengte in cm> <gewicht in kg>"
	echo "Geeft aan of je te zwaar/te licht bent"
	exit 0
fi
if test -z $2
then
	echo "Gebruik !bmi <lengte in cm> <gewicht in kg>"
	echo "Geeft aan of je te zwaar/te licht bent"
	exit 0
fi

index=$(($2 * 100000 / ($1 * $1)))
resultaat="Te mager"

if test $index -ge 200
then
	resultaat="Goed gewicht"
fi

if test $index -ge 250
then
	resultaat="Te zwaar"
fi

if test $index -ge 300
then
	resultaat="Veel te zwaar"
fi

index1=$((index/10))
index2=$((index%10))
echo BMI: $index1,$index2 \=\=\> $resultaat
