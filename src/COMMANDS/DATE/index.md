# linux
```bash
date -u -d @${TIMESTAMP}           # convert timestamp to date in UTC
date -u +%s                        # print current timestamp in UTC
date -u +%Y%m%d                    # year month day, in UTC
date -u +%Y%m%d -d "15 days ago"   # year month day, in UTc, 15 days ago
```

# macos
```bash
date -ur ${TIMESTAMP}  # convert timestamp to date in UTC
date -v -21d           # print date 21 days ago
date -v -6w -v +mon    # print date 6 weeks ago, next Monday
```
