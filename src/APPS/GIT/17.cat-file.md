```bash
###############################################################################
# cat-file -p ${SHA} - figures out what the SHA is, and prints the appropriate
# thig, eg if sha is the :
#   - blob sha   - it prints the file content
#   - commit sha - it prints the commit info
#   - tree sha   - it prints the tree/directory structure
#   - ...etc  
git cat-file -p ${SHA}
git cat-file -p 123abc...
```