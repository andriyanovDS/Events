#!/bin/sh

#  addEnvironment.sh
#  Events
#
#  Created by Dmitry on 28.03.2020.
#  Copyright © 2020 Дмитрий Андриянов. All rights reserved.

envFile="$SRCROOT/Events/environment.swift"

# Enter your key here:
googleApiKey=""

function _generateEnvFile() {
	cat > "$envFile" <<EOF

struct Environment {
	static let googleApiKey = "$googleApiKey"
}
EOF
}

if [ ! -f "$envFile" ];
then
	_generateEnvFile
fi
