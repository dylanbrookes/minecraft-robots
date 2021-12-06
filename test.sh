for FILE in $(find ./build -name "*.lua")
do
    echo "${FILE:1}"
done