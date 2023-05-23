/transferred \(/ {
    gsub(/\(/, "" , $4)
	mib = $4
}

END {
	printf ("%s", mib)
}
