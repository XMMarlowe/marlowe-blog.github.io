@echo off
D:
cd D:\PersonalFile\HexoBlog
echo 'start git sync'
git add .
git add -A
git add -u
git commit -m "update..."
git pull --rebase origin master
git push origin master

call hexo g
hexo d