for file in $(find build -type f)
do
  castl $file -o ${file%".js"}.lua --babel --node --mini -g
done