# grip
NOTE! I figured out that grip sends entire file content to gitlab api:(   
Originaly, I thought it is doing the rendering offline.

```bash
pip install grip
cd path/to/directory/with/md/files
grip -b                                 # -b opens a new browser tab for you
```
