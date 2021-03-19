@echo off
D:
cd D:\PersonalFile\HexoBlog
echo 'start git sync'
git add .
git add -A
git add -u
git commit -m "update..."
git pull HexoBlog master
git push HexoBlog master

echo 'start generate'
call hexo g

echo 'start deploy'
call hexo d