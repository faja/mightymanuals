- copy paste example, ok, this one actually uses grafonnet function
```
local panelScrapingTextPanel = grafana.text.new(
  '', // name
  mode="markdown",
  content="# good to know\n- metric = a single \"word\" without any labels (dimension) attached to it\n- series = metric + uniq labels (hence, a single metric can have hundred of series)\n- sample = series + timestamp + value\n\n# handy queries\n- top 10 metrics with the biggest number of series\n    ```\n    topk(10, count by (__name__) ({__name__=~\".+\"}))\n    ```\n- top 10 jobs with the biggest number of series\n    ```\n    topk(10, sum by (job) (scrape_samples_scraped))\n    ```",
  transparent=true,
);
```
