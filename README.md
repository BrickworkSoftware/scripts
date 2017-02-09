## Setup

1. Clone (`git clone https://github.com/BrickworkSoftware/scripts.git`) or otherwise download this repository.
1. Copy config_sample.yml to config.yml and edit appropriate keys.
1. On the command line:
  1. If necessary install bundler: `gem install bundler`
  1. Change directory to where you cloned or downloaded this repository and execute bundler: `bundle install`
1. Run your script

## Pivotal Sprint Task Cards

1. Your Pivotal API Token can be found at the bottom of your profile page on Pivotal. Take that token add it to your config.yml beside `pivotal_api_key` overwriting the boilerplate text.
1. Execute script passing a `project` parameter and a `label` parameter.
  1. The first parameter, `project` can be either "dev" or "asiago".
  2. The second parameter, `label`, defines the label used to filter stories for inclusion. e.g. "sprint 5"
1. Open `cards.pdf` created in the same directory as your script.
1. Print
  1. In the print dialog, set your paper to `4x6 borderless`
  1. Make sure 4x6 index cards have been placed in the paper tray of the printer and the printer settings have been updated to reflect the 4x6 index cards.


```
./pivotal_task_cards.rb PROJECT LABEL
./pivotal_task_cards.rb (dev|asiago) "sprint 5"
```



## Special Hours

*This script requires the inclusion of Brickwork API keys for all environments one intends to utilize this for.*

```
./special_hours_update.rb domain csv_file
./special_hours_update.rb katespade-staging ksny_holiday_hours.csv
```

#### Common Errors
* "you must login" -> your api key is wrong
* "an error has occurred" -> check if a store with that id exists in that env
* "start time and end time cannot be blank" -> possible it's a closed time slot and they omitted the boolean
