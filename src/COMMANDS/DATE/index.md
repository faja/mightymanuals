# linux
```bash
date -u +%s                        # timestamp in UTC
date -u +%Y%m%d                    # year month day, in UTC
date -u +%Y%m%d -d "15 days ago"   # year month day, in UTc, 15 days ago
```

# macos
```bash
date -v -21d         # print date 21 days ago
date -v -6w -v +mon  # print date 6 weeks ago, next Monday
```
