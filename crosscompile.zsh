#!/bin/zsh
lw=('darwin/386' 'darwin/amd64' 'freebsd/386' 'freebsd/amd64' 'freebsd/arm' 'linux/386' 'linux/amd64' 'linux/arm' 'windows/386' 'windows/amd64')

eval "$(go env)"

function go-alias {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	eval "function go-${GOOS}-${GOARCH} { ( GOOS=${GOOS} GOARCH=${GOARCH} go \$@ ) }"
}

function go-crosscompile-build {
	GOOS=${1%/*}
	GOARCH=${1#*/}
	cd ${GOROOT}/src ; GOOS=${GOOS} GOARCH=${GOARCH} ./make.bash --no-clean 2>&1
}

function go-crosscompile-build-all {
	FAILURES=""
	for PLATFORM in $lw;do
		CMD="go-crosscompile-build ${PLATFORM}"
		eval $CMD || FAILURES="$FAILURES $PLATFORM"
	done
	if [ "$FAILURES" != "" ]; then
	    echo "*** go-crosscompile-build-all FAILED on $FAILURES ***"
	    return 1
	fi
}	

function go-all {
	FAILURES=""
	for PLATFORM in $lw;do
		GOOS=${PLATFORM%/*}
		GOARCH=${PLATFORM#*/}
		CMD="go-${GOOS}-${GOARCH} $@"
		eval $CMD || FAILURES="$FAILURES $PLATFORM"
	done
	if [ "$FAILURES" != "" ]; then
	    echo "*** go-all FAILED on $FAILURES ***"
	    return 1
	fi
}

function go-build-all {
	FAILURES=""
	for PLATFORM in $lw;do
		GOOS=${PLATFORM%/*}
		GOARCH=${PLATFORM#*/}
		OUTPUT=`echo $@ | sed 's/\.go//'` 
		CMD="go-${GOOS}-${GOARCH} build -o $OUTPUT-${GOOS}-${GOARCH} $@"
		echo "$CMD"
		$CMD || FAILURES="$FAILURES $PLATFORM"
	done
	if [ "$FAILURES" != "" ]; then
	    echo "*** go-build-all FAILED on $FAILURES ***"
	    return 1
	fi
}
for PLATFORM in $lw;do
  go-alias $PLATFORM;
done

unset -f go-alias