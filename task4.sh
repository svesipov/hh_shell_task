grep -E '\s+12:[0-9:,]+\s+.+\s+/resume\S*\s+2[0-9]{2}\s+' $1 | awk '{print $8}' | awk '{ sub(/ms/, ""); print }' | awk '{ x+=$1; } ; END { print "To /resume. Only success from 12 to 13:"; print "Sum:", x, "ms\n"; }'

grep -E '\s+/resume\S*\s+' $1 | awk '{print $8}' | awk '{ sub(/ms/, ""); print }' | sort -n | awk '{ x+=$1; N+=1; arr[N-1] = $1 } ; END { arr[N] = arr[N-1]; K1 = int(0.95 * (N-1)); K2 = int(0.99 * (N-1));  if ( (K1+1) < 0.95 * N ) q1 = arr[K1+1]; else if ( (K1+1) == 0.95 * N ) q1 = (arr[K1] + arr[K1+1])/2; else q1 = arr[K1]; if ( (K2+1) < 0.99 * N ) q2 = arr[K2+1]; else if ( (K2+1) == 0.99 * N ) q2 = (arr[K2] + arr[K2+1])/2; else q2 = arr[K2]; print "To /resume. All:"; print "Average:", x/N, "ms"; print "Quantile 95%:", q1; print "Quantile 99%:", q2, "\n"; }'

grep -E '^'$2'\s+.*\s+/resume\?.*id=43(&|\s)+.*\s+' $1 | awk '{print $8}' | awk '{ sub(/ms/, ""); x = 0; N = 0; print }' | sort -n | awk '{ x+=$1; N+=1; arr[N-1] = $1; } ; END { arr[N] = arr[N-1]; K = int(0.5 * (N-1)); if ( (K+1) < 0.5 * N ) q = arr[K+1]; else if ( (K+1) == 0.5 * N ) q = (arr[K] + arr[K+1])/2; else q = arr[K]; print "To /resume. With id=43. During '$2':"; print "Average:", x/N, "ms"; print "Median (quantile 50%):", q, "\n";}'

for page in `echo "resume"; echo "vacancy"; echo "user"`
do
	rm -f $page'.dat' 
	touch $page'.dat'
	for i in `grep -E '^'$3'\s+.*\s+/'$page'.*' $1 | awk '{print $2}' | sort`
	do
	    grep -E '^'$3'\s+.*\s+/'$page'.*' $1 | awk '{ if ($2 <= "'$i'") print $8}' | awk '{ sub(/ms/, ""); x = 0; N = 0; print }' | sort -n | awk '{ N+=1; arr[N-1] = $1; } ; END { arr[N] = arr[N-1]; K = int(0.95 * (N-1)); if ( (K+1) < 0.95 * N ) q = arr[K+1]; else if ( (K+1) == 0.95 * N ) q = (arr[K] + arr[K+1])/2; else q = arr[K]; print "'$i'", q;}' | awk '{gsub (/(:|,)/, " "); print}' | awk '{print ($1+($2/60)+($3/3600)+($4/3600000)), $5}' >> $page'.dat' 
	done
done

gnuplot -e "set terminal png; set output \"plot.png\"; plot [0:24] [t=0:] \"resume.dat\" using 1:2 with lines, \"user.dat\" using 1:2 with lines, \"vacancy.dat\" using 1:2 with lines;"   
