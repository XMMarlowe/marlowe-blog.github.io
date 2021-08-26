@echo off
D:
cd D:\PersonalFile\HexoBlog
echo 'start git sync'
git status
git add -A
git commit -m "update..."
git pull HexoBlog master
git push HexoBlog master

echo 'start clean'
call hexo clean

echo 'start generate'
call hexo g

echo 'start deploy'
call hexo d