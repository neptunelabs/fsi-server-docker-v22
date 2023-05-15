/events per second:/ {
	events = $4
}

END {
	printf ("%s", events)
}
