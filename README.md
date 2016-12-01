# scripts
Automation scripts

1. copy config_sample.yml to config.yml
1. edit config.yml to include your environment specific api keys

## Special Hours

```
./special_hours_update.rb domain csv_file
./special_hours_update.rb katespade-staging ksny_holiday_hours.csv
```

### Common Errors
* "you must login" -> your api key is wrong
* "an error has occurred" -> check if a store with that id exists in that env
* "start time and end time cannot be blank" -> possible it's a closed time slot and they omitted the boolean
