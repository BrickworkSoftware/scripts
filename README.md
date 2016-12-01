# scripts
Automation scripts

copy config_sample.yml to config.yml
edit config.yml to include your environment specific api keys

./special_hours_update.rb _domain_ _csv_file_
./special_hours_update.rb katespade-staging ksny_holiday_hours.csv

common errors
"you must login" -> your api key is wrong
"an error has occurred" -> check if a store with that id exists in that env
"start time and end time cannot be blank" -> possible it's a closed time slot and they omitted the boolean
