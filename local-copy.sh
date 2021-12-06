for d in local_computers/*/
do
    rm -r $d
    mkdir $d
    cp -R build/* $d
done