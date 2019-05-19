#!/bin/bash

echo "installing $1"
mkdir -p ~/.apps
flatpak install -y $1
PKG=$(flatpak list --app --columns=description,application | grep -i $1 | egrep -o "([^[:space:]]*)$")
printf "#!/bin/bash\nflatpak run $PKG \$@" > ~/.apps/$1
chmod +x ~/.apps/$1
